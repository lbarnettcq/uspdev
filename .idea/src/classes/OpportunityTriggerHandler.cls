public without sharing class OpportunityTriggerHandler {
    private static Boolean debugOn = Test.isRunningTest();

    public static void Execute() {
        if (!Trigger.isExecuting) { return; }
        Trigger_Config__c triggerConfig = Trigger_Config__c.getInstance();
        if (triggerConfig != null && triggerConfig.Disable_Opportunity_Trigger__c == true) { return; }

        if (Trigger.isBefore) {
            beforeInsertUpdate();
        }

        if (Trigger.isAfter) {
            afterInsertUpdate();
        }
    }

    private static void beforeInsertUpdate() {
        /*
        List<Opportunity> newRecords = (List<Opportunity>) Trigger.new;

        for (Opportunity opp : newRecords) {
            if (opp.Contract_PO_Start_Date__c == null
                    || opp.Contract_PO_Duration__c == null
                    || opp.Amount == null) { continue; }
            Date startDate = opp.Contract_PO_Start_Date__c;

            Integer duration = opp.Contract_PO_Duration__c.intValue();
            Decimal monthlyRevenue = opp.Monthly_Revenue__c;
            Decimal amount = opp.Amount;


            if (duration == 0
                    || duration == null) {
                monthlyRevenue = amount;
                opp.Contract_PO_End_Date__c = startDate;
                System.debug('no duration revenue: ' + monthlyRevenue);
                System.debug('no duration end date ' + opp.Contract_PO_End_Date__c);
            }else{
                monthlyRevenue = amount/duration;
                opp.Contract_PO_End_Date__c = startDate.addMonths(duration);
                System.debug('Calculated revenue ' + monthlyRevenue);
                System.debug('Calculated end date ' + opp.Contract_PO_End_Date__c);
            }

            //opp.Contract_PO_End_Date__c = endDate;
            opp.Monthly_Revenue__c = monthlyRevenue;
            System.debug('opportunity : ' + opp);
        }

         */


    }

    private static void afterInsertUpdate() {
        Map<Id, Opportunity> newRecords = (Map<Id, Opportunity>) Trigger.newMap;
        Map<Id, Opportunity> oldRecords = Trigger.isInsert ? new Map<Id, Opportunity>() : (Map<Id, Opportunity>) Trigger.oldMap;

        List<Period> allPeriods = [
                SELECT Id, StartDate, EndDate, Number FROM Period
                WHERE IsForecastPeriod = true AND Type = 'Month'
        ];
        List<FunnelAdditionTarget__c> allFats = [
                SELECT Id, Seller__c, PeriodId__c, PeriodFunnel__c, FunnelAdditionTarget__c
                FROM FunnelAdditionTarget__c
        ];

        List<FunnelAdditionTarget__c> fats = new List<FunnelAdditionTarget__c>();
        Set<Id> calculatedOwners = new Set<Id>();
        Map<Id, Period> usefulPeriods = new Map<Id, Period>();
        for (Id key : newRecords.keySet()) {
            Opportunity no = newRecords.get(key);
            Opportunity oo = oldRecords.containsKey(key) ? oldRecords.get(key) : newRecords.get(key);
            if (!calculatedOwners.contains(no.OwnerId)) { calculatedOwners.add(no.OwnerId); }
            if (!calculatedOwners.contains(oo.OwnerId)) { calculatedOwners.add(oo.OwnerId); }
            for (Period p : allPeriods) {
                if (p.StartDate <= no.CreatedDate && p.EndDate >= no.CreatedDate) {
                    if (!usefulPeriods.containsKey(p.Id)) { usefulPeriods.put(p.Id, p); }
                }
                if (p.StartDate <= oo.CreatedDate && p.EndDate >= oo.CreatedDate) {
                    if (!usefulPeriods.containsKey(p.Id)) { usefulPeriods.put(p.Id, p); }
                }
            }
            if (debugOn) {
                System.debug('[][OpportunityTriggerHandler][Execute][] Opportunity new => '+no);
                System.debug('[][OpportunityTriggerHandler][Execute][] Opportunity old => '+oo);
            }
        }
        if (debugOn) {
            System.debug('[][OpportunityTriggerHandler][Execute][] calculatedOwners => ' + calculatedOwners);
            System.debug('[][OpportunityTriggerHandler][Execute][] usefulPeriods => ' + usefulPeriods);
        }

        List<Opportunity> allOpps = [
                SELECT Id, OwnerId, CloseDate, Amount, StageName, Probability, Estimated_Monthly_Amount__c, CreatedDate
                FROM Opportunity
                WHERE OwnerId IN :calculatedOwners AND Amount!= null
        ];

        for (Id seller : calculatedOwners) {
            List<FunnelAdditionTarget__c> ufats = calculateFATPeriodFunnel(seller, usefulPeriods.values(), allfats, allOpps);
            if (ufats != null && !ufats.isEmpty()) { fats.addAll(ufats); }
        }
        if (fats != null && !fats.isEmpty()) { update fats; }
    }

    private static List<FunnelAdditionTarget__c> calculateFATPeriodFunnel(Id seller, List<Period> periods
            , List<FunnelAdditionTarget__c> allFats, List<Opportunity> allOpps) {
        List<FunnelAdditionTarget__c> fatsToReturn = new List<FunnelAdditionTarget__c>();
        for (Period p : periods) {
            FunnelAdditionTarget__c fat = null;
            for (FunnelAdditionTarget__c f : allFats) {
                if (f.Seller__c != seller || f.PeriodId__c != p.Id) { continue; }
                fat = f;
                break;
            }
            if (fat == null) { continue; }
            Decimal totalAmount = 0.0;
            for (Opportunity opp : allOpps) {
                if (opp.OwnerId != seller) { continue; }
                if (p.StartDate <= opp.CreatedDate && p.EndDate >= opp.CreatedDate) {
                    if (opp.StageName.startsWith('0') || opp.StageName.equals('Closed Lost')) { continue; }
                    totalAmount += opp.Amount;
                }
            }
            if (totalAmount > 0) { fat.PeriodFunnel__c = totalAmount; }
            fatsToReturn.add(fat);
        }
        return fatsToReturn;
    }
}