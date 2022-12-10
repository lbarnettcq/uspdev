public without sharing class AccuracyAndTargetCalculator {

    @TestVisible private static final String C_PREVIOUS = 'previous';
    @TestVisible private static final String C_CURRENT = 'current';
    @TestVisible private static final String C_NEXT = 'next';
    @TestVisible private static final String C_PERIODS = 'periods';
    @TestVisible private final static String C_SELLER_CLASSIFICATION = 'Seller';
    @TestVisible private final static String C_REGION_ROLLUP_CLASSIF = 'Region Roll-up';
    public static Date M_TODAY = Date.today();

    private static Boolean debugOn = Test.isRunningTest();

    public static void Execute(Mode process, State operation) {
        Map<Id, Period> periods = loadPeriods();
        Map<String, Object> data = new Map<String, Object>();
        if (process == Mode.EndOfPeriod || process == Mode.EndAndStart) {
            data = calculateEndOfPeriod(operation, periods);
        }
        if (process == Mode.StartOfPeriod || process == Mode.EndAndStart) {
            calculateStartOfPeriod(operation, periods, data);
        }
    }

    private static Map<String, Object> calculateEndOfPeriod(State operation, Map<Id, Period> periods) {
        Map<String, Object> response = new Map<String, Object>();
        Map<String, Period> found = parsePeriods(periods);
        response.put(C_PERIODS, found);
        if (found == null || found.values().isEmpty()) { return response; }
        Period previous = found.containsKey(C_PREVIOUS) ? found.get(C_PREVIOUS) : null;
        Period current = found.containsKey(C_CURRENT) ? found.get(C_CURRENT) : null;
        Period next = found.containsKey(C_NEXT) ? found.get(C_NEXT) : null;

        if (current.EndDate != M_TODAY && operation != State.IgnoreCurrentDate) { return response; }

        Period endCalculationPeriod = (current.StartDate <= M_TODAY && current.EndDate > M_TODAY)
                ? previous : current.EndDate == M_TODAY ? current : null;
        Period nextCalculationPeriod = (current.StartDate <= M_TODAY && current.EndDate > M_TODAY)
                ? current : current.EndDate == M_TODAY ? next : null;

        if (endCalculationPeriod == null || nextCalculationPeriod == null) { return response; }

        // pull CommitCaseAccuracy__c for last period (1 soql)
        String soql = 'SELECT Id, Name, Opp__c, Seller__c, Opp__r.Estimated_Monthly_Amount__c, Opp__r.Amount, Opp__r.CloseDate, Opp__r.StageName, Opp__r.Probability,' +
                ' AmountAtEnd__c, CloseDateAtEnd__c, StageAtEnd__c, ProbabilityAtEnd__c, PeriodId__c' +
                ' FROM CommitCaseAccuracy__c' +
                ' WHERE PeriodId__c = \'' + endCalculationPeriod.Id + '\'';
        if (debugOn) {
            System.debug('[][AccuracyAndTargetCalculator][calculateEndOfPeriod][] QUERY END OF MONTH CCAs => '+soql);
        }
        List<CommitCaseAccuracy__c> ccas = (List<CommitCaseAccuracy__c>)Database.query(soql);

        //if (ccas == null || ccas.isEmpty()) { return response; }

        List<Id> sellers = loadPotentialSellers();

        // update CCA records to add AtEnd values from relevant Opp
        for (CommitCaseAccuracy__c cca : ccas) {
            cca.AmountAtEnd__c = cca.Opp__r.Amount;
            cca.StageAtEnd__c = cca.Opp__r.StageName;
            cca.CloseDateAtEnd__c = cca.Opp__r.CloseDate;
            cca.ProbabilityAtEnd__c = cca.Opp__r.Probability;
        }

        List<CommitCaseHistory__c> existing_cchs = [
                SELECT Id FROM CommitCaseHistory__c
                WHERE PeriodId__c = :endCalculationPeriod.Id AND Seller__c IN :sellers
        ];

        List<FunnelAdditionTarget__c> existing_fats = [
                SELECT Id FROM FunnelAdditionTarget__c
                WHERE PeriodId__c = :nextCalculationPeriod.Id AND Seller__c IN :sellers
        ];

        List<Opportunity> opps = [SELECT Id, OwnerId, Estimated_Monthly_Amount__c, CloseDate, StageName, CreatedDate, Chemical_Global__c, Amount
                                FROM Opportunity WHERE Amount != null];

        List<CommitCaseHistory__c> cchs = new List<CommitCaseHistory__c>();
        List<FunnelAdditionTarget__c> fats = new List<FunnelAdditionTarget__c>();

        for (Id seller : sellers) {
            Integer relevantCCA = 0;
            Integer countClosed = 0;
            for (CommitCaseAccuracy__c cca : ccas) {
                if (cca.Seller__c != seller) { continue; }
                if (cca.PeriodId__c != endCalculationPeriod.Id) { continue; }
                relevantCCA ++;
                if (cca.Opp__r.StageName.startsWith('5')) {
                    countClosed ++;
                }
            }

            Decimal calculatedAccuracy = (relevantCCA == 0)
                    ? 0
                    : (((countClosed + 0.0) / relevantCCA) * 100.0).setScale(2);

            // calculate CCA result and create CommitCaseHistory__c record
            CommitCaseHistory__c cch = new CommitCaseHistory__c(
                    Period__c = periodLabel(endCalculationPeriod),
                    PeriodId__c = endCalculationPeriod.Id,
                    PeriodStart__c = endCalculationPeriod.StartDate,
                    PeriodEnd__c = endCalculationPeriod.EndDate,
                    OppsAtStart__c = ccas.size(),
                    OppsAtEnd__c = countClosed,
                    Accuracy__c = calculatedAccuracy,
                    Seller__c = seller,
                    OwnerId = seller
            );
            cchs.add(cch);

            Decimal defaultQuota = 15000000.00;
            quotaGageSettings__c settings = quotaGageSettings__c.getInstance(seller);
            Decimal quota = settings != null
                    ? settings.Quota_Amount__c != null
                            ? settings.Quota_Amount__c
                            : defaultQuota
                    : defaultQuota;
            Decimal staticFunnelTarget = settings != null
                    ? settings.Static_Funnel_Addition_Target__c != null
                            ? settings.Static_Funnel_Addition_Target__c
                            : null
                    : null;
            Decimal staticNewProductTarget = settings != null
                    ? settings.Static_New_Product_Target__c != null
                        ? settings.Static_New_Product_Target__c
                            : null
                    : null;
            Boolean useCalculated = settings != null
                    ? settings.Use_Calculated_Funnel_Addition_Target__c != null
                            ? settings.Use_Calculated_Funnel_Addition_Target__c
                            : false
                    : false;

            CommitCaseAccuracyConfig__c ccaConfig = CommitCaseAccuracyConfig__c.getInstance();
            Decimal minFunnelTarget = ccaConfig != null
                    ? ccaConfig.Minimum_Funnel_Target__c != null
                            ? ccaConfig.Minimum_Funnel_Target__c
                            : 1
                    : 1;
            Decimal maxFunnelTarget = ccaConfig != null
                    ? ccaConfig.Maximum_Funnel_Target__c != null
                            ? ccaConfig.Maximum_Funnel_Target__c
                            : 3
                    : 3;

            Decimal target = (calculatedAccuracy/100) <= 0 ? 0.01 : (calculatedAccuracy/100);
            if (target > 1) { target = 1; }

            Decimal periodFunnel = 0.0;
            for (Opportunity opp : opps) {
                if (opp.OwnerId != seller) { continue; }
                if (nextCalculationPeriod.StartDate <= opp.CreatedDate && nextCalculationPeriod.EndDate >= opp.CreatedDate) {
                    if (opp.StageName == 'Closed Lost') { continue; }
                    periodFunnel += opp.Amount;
                }
            }

            Decimal newProductFunnel = 0.0;
            //Change here to edit newProduct Funnel
            for (Opportunity opp : opps) {
                opp.Chemical_Global__c = 'Hydrogen Peroxide';
                if (opp.OwnerId != seller) { continue; }
                if (nextCalculationPeriod.StartDate <= opp.CreatedDate && nextCalculationPeriod.EndDate >= opp.CreatedDate) {
                    if (opp.StageName == 'Closed Lost') { continue; }
                    if (opp.Chemical_Global__c != null) { continue; }
                    if (opp.Chemical_Global__c.contains('Sulfelox') || opp.Chemical_Global__c.contains('OptiCal')) { continue; }
                    newProductFunnel += opp.Amount;

                }
            }

            Decimal actualTarget = quota / target;
            if (actualTarget > (maxFunnelTarget*3)) { actualTarget = maxFunnelTarget*3; }
            if (actualTarget < (minFunnelTarget*quota)) { actualTarget = minFunnelTarget*quota; }

            if (useCalculated && staticFunnelTarget != null) { actualTarget = staticFunnelTarget; }

            Decimal newProductActualTarget = quota / target;
            if (newProductActualTarget > (maxFunnelTarget*3)) { newProductActualTarget = maxFunnelTarget*3; }
            if (newProductActualTarget < (minFunnelTarget*quota)) { newProductActualTarget = minFunnelTarget*quota; }

            if (useCalculated && staticNewProductTarget != null) { newProductActualTarget = staticNewProductTarget; }



            // calculate FAT value and create FunnelAdditionTarget__c record
            FunnelAdditionTarget__c fat = new FunnelAdditionTarget__c(
                    Period__c = periodLabel(nextCalculationPeriod),
                    PeriodId__c = nextCalculationPeriod.Id,
                    PeriodStart__c = nextCalculationPeriod.StartDate,
                    PeriodEnd__c = nextCalculationPeriod.EndDate,
                    PreviousPeriodCCAccuracy__c = calculatedAccuracy,
                    FunnelAdditionTarget__c = actualTarget/12,
                    PeriodFunnel__c = periodFunnel,
                    Seller__c = seller,
                    OwnerId = seller,
                    New_Product_Funnel__c = newProductFunnel,
                    New_Product_Funnel_Target__c = newProductActualTarget/12
            );
            fats.add(fat);
        }

        update ccas;
        if (existing_cchs != null && existing_cchs.size() > 0) {
            delete existing_cchs;
        }
        insert cchs;
        if (existing_fats != null && existing_fats.size() > 0) {
            delete existing_fats;
        }
        insert fats;

        return response;
    }

    private static void calculateStartOfPeriod(State operation, Map<Id, Period> periods, Map<String, Object> data) {
        Map<String, Period> found = convertToPeriodMap(
                (Map<String, Object>) (data.containsKey(C_PERIODS) ? data.get(C_PERIODS) : null)
        );
        if (found == null || found.isEmpty()) { found = parsePeriods(periods); }
        if (found == null || found.isEmpty()) { return; }
        Period current = found.containsKey(C_CURRENT) ? found.get(C_CURRENT) : null;

        if (current.StartDate != M_TODAY && operation != State.IgnoreCurrentDate) { return; }

        Period calculationPeriod = current;

        //List<Id> sellers = loadPotentialSellers();

        Decimal defaultProbability = 70;
        CommitCaseAccuracyConfig__c settings = CommitCaseAccuracyConfig__c.getInstance();
        Decimal targetProbability = settings != null
                ? settings.ProbabilityThreshold__c != null
                    ? settings.ProbabilityThreshold__c
                    : defaultProbability
                : defaultProbability;

        // pull all opps of appropriate stage & probability
        List<Opportunity> opps = [
                SELECT Id, Estimated_Monthly_Amount__c, OwnerId, StageName, Probability, CloseDate, CreatedDate, Amount
                FROM Opportunity
                WHERE StageName = '4 - Proposal' AND Probability >= :targetProbability AND CloseDate != null
                    AND CloseDate >= :calculationPeriod.StartDate AND CloseDate <= :calculationPeriod.EndDate
        ];

        List<Id> sellers = new List<Id>();
        List<CommitCaseAccuracy__c> ccas = new List<CommitCaseAccuracy__c>();
        // create new CommitCaseAccuracy__c record for each
        for (Opportunity opp : opps) {
            sellers.add(opp.OwnerId);
            ccas.add(new CommitCaseAccuracy__c(
                    Seller__c = opp.OwnerId,
                    ProbabilityAtStart__c = opp.Probability,
                    AmountAtStart__c = opp.Amount,
                    CloseDateAtStart__c = opp.CloseDate,
                    StageAtStart__c = opp.StageName,
                    PeriodId__c = calculationPeriod.Id,
                    Period__c = periodLabel(calculationPeriod),
                    PeriodStart__c = calculationPeriod.StartDate,
                    PeriodEnd__c = calculationPeriod.EndDate,
                    Opp__c = opp.Id,
                    OwnerId = opp.OwnerId
            ));
        }

        List<CommitCaseAccuracy__c> existing_ccas = [
                SELECT Id, Seller__c, Opp__c
                FROM CommitCaseAccuracy__c
                WHERE Seller__c IN :sellers
                    AND PeriodId__c = :calculationPeriod.Id
        ];

        List<CommitCaseAccuracy__c> ccas_to_insert = new List<CommitCaseAccuracy__c>();
        for (CommitCaseAccuracy__c cca : ccas) {
            Boolean insertable = true;
            for (CommitCaseAccuracy__c ecca : existing_ccas) {
                if (cca.Seller__c == ecca.Seller__c && cca.Opp__c == ecca.Opp__c) {
                    insertable = false;
                }
            }
            if (insertable) { ccas_to_insert.add(cca); }
        }

        if (ccas_to_insert != null && !ccas_to_insert.isEmpty()) {
            insert ccas_to_insert;
            if (debugOn) {
                System.debug('[][AccuracyAndTargetCalculator][calculateStartOfPeriod][] - CCAs INSERTED ////////');
                System.debug(ccas_to_insert);
            }
        }
    }

    private static List<Id> loadPotentialSellers() {
        List<Id> sellers = new List<Id>();
        List<User> users = [SELECT Id, FirstName, LastName, User_Classification__c
                            FROM User
                            WHERE User_Classification__c <> NULL
                                AND User_Classification__c IN (:C_SELLER_CLASSIFICATION, :C_REGION_ROLLUP_CLASSIF)
                            ORDER BY User_Classification__c, FirstName, LastName];
        for (User u : users) {
            sellers.add(u.Id);
        }
        return sellers;
    }

    private static Map<String, Period> convertToPeriodMap(Map<String, Object> inbound) {
        if (inbound == null || inbound.isEmpty()) { return new Map<String, Period>(); }
        Map<String, Period> outbound = new Map<String, Period>();
        for (String key : inbound.keySet()) {
            outbound.put(key, (Period) inbound.get(key));
        }
        return outbound;
    }

    private static Map<String, Period> parsePeriods(Map<Id, Period> inPeriods) {
        Map<Id, Period> periods = inPeriods;
        Period previous = null;
        Period current = null;
        Period next = null;
        for (Period p : periods.values()) {
            if (current != null) { next = p; break; }
            if (p.StartDate <= M_TODAY && p.EndDate >= M_TODAY) {
                current = p;
            }
            if (current == null) { previous = p; }
        }
        Map<String, Period> returnPeriods = new Map<String, Period> {
                C_PREVIOUS => previous,
                C_CURRENT => current,
                C_NEXT => next
        };

        if (debugOn) {
            System.debug('[][AccuracyAndTargetCalculator][parsePeriods][] - RETURN PERIODS ////////');
            System.debug(returnPeriods);
        }

        return returnPeriods;
    }

    private static Map<Id, Period> testPeriods = null;
    private static Map<Id, Period> loadPeriods() {
        if (Test.isRunningTest()) {
            if (testPeriods == null) {
                testPeriods = new Map<Id, Period>(TestDataFactory.loadPeriods());
            }

            if (debugOn) {
                System.debug('[][AccuracyAndTargetCalculator][loadPeriods][] - TEST PERIODS ////////');
                System.debug(testPeriods);
            }

            return testPeriods;
        }
        return new Map<Id, Period>([
                SELECT Id, FullyQualifiedLabel, StartDate, EndDate, Number
                FROM Period
                WHERE IsForecastPeriod = TRUE AND Type = 'Month'
                    AND StartDate >= :M_TODAY.addMonths(-6)
                ORDER BY StartDate
        ]);
    }

    private static String periodLabel(Period p) {
        String year = '' + String.valueOf(p.StartDate.year());
        String n = String.valueOf(p.Number);
        if (n.length() == 1) { n = '0'+n; }
        String retVal = 'P' + n + '-' + year;
        switch on p.Number {
            when 1 { return retVal+'/Jan'; }
            when 2 { return retVal+'/Feb'; }
            when 3 { return retVal+'/Mar'; }
            when 4 { return retVal+'/Apr'; }
            when 5 { return retVal+'/May'; }
            when 6 { return retVal+'/Jun'; }
            when 7 { return retVal+'/Jul'; }
            when 8 { return retVal+'/Aug'; }
            when 9 { return retVal+'/Sep'; }
            when 10 { return retVal+'/Oct'; }
            when 11 { return retVal+'/Nov'; }
            when 12 { return retVal+'/Dec'; }
        }
        return p.FullyQualifiedLabel;
    }

    public enum Mode {
        StartOfPeriod,
        EndOfPeriod,
        EndAndStart
    }

    public enum State {
        Standard,
        IgnoreCurrentDate
    }
}