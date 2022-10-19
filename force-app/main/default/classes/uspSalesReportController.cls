@SuppressWarnings('ApexUnresolvableReference')
global with sharing class uspSalesReportController {
    private static String m_viewLevel;
    global static String ViewLevel {
        get {
            if (m_viewLevel == null) {
                m_viewLevel = 'All';
            }
            return m_viewLevel;
        }
        set {
            m_viewLevel = value;
        }
    }

    global static String Period {
        get {
            if (m_period == null) {
                m_period = '30';
            }
            return m_period;
        }
        set {
            m_period = value;
            m_periodDates = null;
        }
    }

    global static String RangeStart {
        get {
            List<Period> periodValues = periods.values();
            if (periodValues == null || periodValues.isEmpty()) {
                return StringUtil.FormatDateForUI(Date.today().toStartOfMonth());
            }
            return StringUtil.FormatDateForUI(periodValues[0].StartDate);
        }
    }

    global static String RangeEnd {
        get {
            List<Period> periodValues = periods.values();
            if (periodValues == null || periodValues.isEmpty()) {
                return StringUtil.FormatDateForUI(Date.today().toStartOfMonth().addMonths(1).addDays(-1));
            }
            return StringUtil.FormatDateForUI(periodValues[periodValues.size()-1].EndDate);
        }
    }

    private static List<Date> m_periodDates;
    global static List<Date> PeriodDates {
        get {
            if (m_periodDates != null) { return m_periodDates; }
            List<Date> allDates = new List<Date>();
            allDates.add(currentDate.addMonths(-1));
            allDates.add(currentDate);
            allDates.add(currentDate.addMonths(1));
            allDates.add(currentDate.addMonths(2));
            allDates.add(currentDate.addMonths(3));
            allDates.add(currentDate.addMonths(4));
            allDates.add(currentDate.addMonths(5));
            allDates.add(currentDate.addMonths(6));
            allDates.add(currentDate.addMonths(7));
            allDates.add(currentDate.addMonths(8));
            allDates.add(currentDate.addMonths(9));
            allDates.add(currentDate.addMonths(10));
            allDates.add(currentDate.addMonths(11));
            allDates.add(currentDate.addMonths(12));
            allDates.add(currentDate.addMonths(13));
            allDates.add(currentDate.addMonths(14));
            allDates.add(currentDate.addMonths(15));
            allDates.add(currentDate.addMonths(16));
            allDates.add(currentDate.addMonths(17));
            allDates.add(currentDate.addMonths(18));
            String query = PerformanceToPlanDataProvider.generatePeriodQuery(allDates);
            List<Period> allPeriods = (List<Period>)Database.query(query);
            List<Date> dates = new List<Date>();
            Id currentPeriod = null;
            for (Period p : allPeriods) {
                if (p.StartDate <= currentDate && p.EndDate >= currentDate) {
                    currentPeriod = p.Id;
                    break;
                }
            }
            Boolean reachedCurrentPeriod = false;
            Integer currentPlus = 0;
            for (Period p : allPeriods) {
                if (!reachedCurrentPeriod) {
                    if (p.Id == currentPeriod) {
                        reachedCurrentPeriod = true;
                    } else {
                        continue;
                    }
                }
                currentPlus ++;
                if (uspSalesReportController.Period == '30') {
                    if (p.Id != currentPeriod) { break; }
                    dates.add(p.StartDate);
                }
                if (uspSalesReportController.Period == '60') {
                    if (currentPlus == 1) { continue; }
                    if (currentPlus > 2) { break; }
                    dates.add(p.StartDate);
                }
                if (uspSalesReportController.Period == '90') {
                    if (currentPlus == 1 || currentPlus == 2) { continue; }
                    if (currentPlus > 3) { break; }
                    dates.add(p.StartDate);
                }
                if (uspSalesReportController.Period == '90 - 450') {
                    if (currentPlus == 1 || currentPlus == 2 || currentPlus == 3) { continue; }
                    if (currentPlus > 15) { break; }
                    dates.add(p.StartDate);
                }
            }
            if (dates.isEmpty()) {
                dates.add(currentDate);
            }
            m_periodDates = dates;
            return m_periodDates;
        }
    }

    global static Decimal Quota {

        get {
            Decimal defaultValue = 218000000.00;
            quotaGageSettings__c settings = config;
            if (settings == null) {
                return defaultValue;
            }
            if (settings.Quota_Amount__c == null) {
                return defaultValue;
            }
            return settings.Quota_Amount__c;
        }


    }

    global static Decimal DynamicQuota() {
        loadIfMissing();
        return Quota*periods.values().size();
    }

    global static Id CurrentUser {
        get {
            if (m_browseAs != null) { return m_browseAs; }
            return UserInfo.getUserId();
        }
        set {
            m_browseAs = value;
            lookupUserName();
        }
    }

    global static String CurrentUserName {
        get {
            if (m_displayUserName != null) { return m_displayUserName; }
            return UserInfo.getName();
        }
    }

    global static List<SelectOption> ViewablePeople {
        get {
            if (m_viewablePeople != null) { return m_viewablePeople; }
            m_viewablePeople = HeirarchyProvider.PopulateSelectOptionsFromCurrentUser();
            return m_viewablePeople;
        }
    }

    /******************************************************************************************************************/
    /**** RIGHT GAUGE PROPERTIES **************************************************************************************/
    /******************************************************************************************************************/


    global static String RangeRemaining {
        get {
            List<Period> periodValues = periods.values();
            if (periodValues == null || periodValues.isEmpty()) {
                return '0';
            }
            return String.valueOf(
                    Date.today().daysBetween(periodValues[periodValues.size()-1].EndDate)
            );
        }
    }

    global static String GaugeColors {
        get {
            String green = '#78c953,#ddd';
            String yellow = '#F0FF33,#ddd';
            String orange = '#ff6900,#ddd';
            String red = '#ff0000,#ddd';
            Decimal totalProgress = 0.0;
            for (forecastItemDTO item : ForecastItems) {
                totalProgress += item.progress;
            }
            if (totalProgress <= redThreshold) {
                return red;
            }
            if (totalProgress <= orangeThreshold) {
                return orange;
            }
            if (totalProgress <= yellowThreshold) {
                return yellow;
            }
            return green;
        }
    }

    global static Integer MaxValue {
        get {
            Integer defaultValue = 150;
            quotaGageSettings__c settings = config;
            if (settings == null) {
                return defaultValue;
            }
            if (settings.Gauge_Max_Value__c == null) {
                return defaultValue;
            }
            return settings.Gauge_Max_Value__c.intValue();
        }
    }

    global static String PercentTowardPlan {
        get {
            if (ForecastItems == null || ForecastItems.isEmpty()) { return '0'; }

            //Decimal progressValue = calculateTotal(new List<Integer>{4,5});
            Decimal progressValue = (calculateTotal(new List<Integer>{4})  * 0.7 ) + (calculateTotal(new List<Integer>{5}));
            Decimal progress = ((progressValue / DynamicQuota()) * 100).setScale(2);

            if (progress > MaxValue) {
                return String.valueOf(MaxValue);
            } else {
                return String.valueOf(progress);
            }
        }
    }


    global static List<forecastItemDTO> ForecastItems {
        get {
            loadIfMissing();
            Map<String, forecastItemDTO> results = new Map<String, forecastItemDTO>();

            // COMMENTED OUT BELOW -- old functionality, calculates based on Forecast data
            //Set<Id> calculatedOpps = new Set<Id>();
            //for (ForecastingFact item : forecasts.values()) {
            //    String key = 'Projected Sales';
            //    if (!results.containsKey(key)) {
            //        results.put(key, new forecastItemDTO(item));
            //        results.get(key).progress = 0.0;
            //    }
            //    // START - block repeated opps, and avoid stage 0, 1, 2 opps
            //    Opportunity opp = forecastOpportunities.get(item.Id);
            //    if (opp == null) { continue; }
            //    if (opp.StageName.startsWith('0') || opp.StageName.startsWith('1') || opp.StageName.startsWith('2')) { continue; }
            //    if (calculatedOpps.contains(opp.Id)) { continue; }
            //    calculatedOpps.add(opp.Id);
            //    // END - block repeated opps, and avoid stage 0, 1, 2 opps
            //    results.get(key).progress += item.ForecastingItem.ForecastAmount;
            //}
            //for (String key : results.keySet()) {
            //    System.debug('#### Forecast Results => ' + String.valueOf(results.get(key).progress));
            //    results.get(key).progress = ((results.get(key).progress / DynamicQuota()) * 100).setScale(2);
            //    if (results.get(key).progress > MaxValue) results.get(key).progress = MaxValue;
            //}
            //if (results.isEmpty()) {
            //    results.put('default', new forecastItemDTO());
            //}
            //return results.values();
            //COMMENTED OUT ABOVE -- old functionality, calculates based on Forecast data

            results.put('default', new forecastItemDTO());
            Decimal progressValue = (calculateTotal(new List<Integer>{4})  * 0.7 ) + (calculateTotal(new List<Integer>{5}));
            results.get('default').progress = ((progressValue / DynamicQuota()) * 100).setScale(2);

            for (forecastItemDTO result: results.values()) {
                if (result.progress > MaxValue) {
                    result.progress = MaxValue;
                }
            }

            return results.values();
        }
    }

    /******************************************************************************************************************/
    /**** LEFT GRID PROPERTIES ****************************************************************************************/
    /******************************************************************************************************************/

    global static String CurrentMTDBookings {
        get {
            return StringUtil.FormatDollarAmount(calculateTotal(new List<Integer>{5}));
        }
    }

    global static String StageFourOpps {
        get {
            return StringUtil.FormatDollarAmount(calculateTotal(new List<Integer>{4})  * 0.7);
        }
    }

    global static String ProjectedBookings {
        get {
            return StringUtil.FormatDollarAmount((calculateTotal(new List<Integer>{4})  * 0.7 ) + calculateTotal(new List<Integer>{5}));
        }
    }

    global static String StageThreeOpps {
        get {

            return StringUtil.FormatDollarAmount(calculateTotal(new List<Integer>{3})  * 0.5);
        }
    }

    global static String ProjectedBookingsPlusStageThree {
        get {
            return StringUtil.FormatDollarAmount((calculateTotal(new List<Integer>{3})  * 0.5) + (calculateTotal(new List<Integer>{4}) * 0.7) + calculateTotal(new List<Integer>{5}));
        }
    }

    global static String PlanCurrentPeriod {
        get {
            return StringUtil.FormatDollarAmount(DynamicQuota());
        }
    }

    global static String PlanVsBooking {
        get {
            Decimal sum = (calculateTotal(new List<Integer>{4})  * 0.7 ) + calculateTotal(new List<Integer>{5});
            return StringUtil.FormatDollarAmount(sum-DynamicQuota());
        }
    }

    global static String PlanVsBookingPlusThree {
        get {
            Decimal sum = (calculateTotal(new List<Integer>{3})  * 0.5) + (calculateTotal(new List<Integer>{4}) * 0.7) + calculateTotal(new List<Integer>{5});
            return StringUtil.FormatDollarAmount(sum-DynamicQuota());
        }
    }

    /******************************************************************************************************************/
    /**** PRIVATE PROPERTIES ******************************************************************************************/
    /******************************************************************************************************************/

    private static Map<Id, Opportunity> forecastOpportunities { get; set; }
    private static Map<Id, ForecastingFact> forecasts { get; set; }
    private static Map<Id, Period> periods { get; set; }
    private static String m_period;
    private static Id m_browseAs;
    private static String m_displayUserName;
    private static String lastLoadedPeriod = '';
    private static List<SelectOption> m_viewablePeople;

    private static quotaGageSettings__c config {
        get {
            return quotaGageSettings__c.getInstance(CurrentUser);
        }
    }

    private static Date currentDate {
        get {
            return Date.today();
        }
    }

    private static Integer redThreshold {
        get {
            Integer defaultValue = 25;
            quotaGageSettings__c settings = config;
            if (settings == null) {
                return defaultValue;
            }
            if (settings.Red_Upper_Limit__c == null) {
                return defaultValue;
            }
            return settings.Red_Upper_Limit__c.intValue();
        }
    }

    private static Integer orangeThreshold {
        get {
            Integer defaultValue = 50;
            quotaGageSettings__c settings = config;
            if (settings == null) {
                return defaultValue;
            }
            if (settings.Orange_Upper_Limit__c == null) {
                return defaultValue;
            }
            return settings.Orange_Upper_Limit__c.intValue();
        }
    }

    private static Integer yellowThreshold {
        get {
            Integer defaultValue = 75;
            quotaGageSettings__c settings = config;
            if (settings == null) {
                return defaultValue;
            }
            if (settings.Yellow_Upper_Limit__c == null) {
                return defaultValue;
            }
            return settings.Yellow_Upper_Limit__c.intValue();
        }
    }

    /******************************************************************************************************************/
    /**** PRIVATE METHODS *********************************************************************************************/
    /******************************************************************************************************************/

    private static void lookupUserName() {
        User u = [SELECT Id, FirstName, LastName FROM User WHERE Id = :CurrentUser LIMIT 1];
        if (u == null) { return; }
        m_displayUserName = u.FirstName + ' ' + u.LastName;
    }

    private static Decimal calculateTotal(List<Integer> stagesToInclude) {
        Decimal sum = 0.0;
        Boolean doCalculation = false;
        loadIfMissing();
        if (forecastOpportunities == null) { return sum; }
        System.debug('+++FORECAST OPPORTUNITIES =   + ' + forecastOpportunities);
        for (Id fact : forecastOpportunities.keySet()) {
            Opportunity opp = forecastOpportunities.get(fact);
            if (opp == null) { continue; }
            if (opp.Amount == null) { continue; }
            doCalculation = false;
            for (Integer stage : stagesToInclude) {
                if (opp.StageName.startsWith(String.valueOf(stage))) { doCalculation = true; }
            }
            if (!doCalculation) { continue; }
            sum += opp.Amount;
        }

        return sum;
    }

    private static void loadIfMissing() {
        if (lastLoadedPeriod == Period) { return; }
        PerformanceToPlanDataProvider dp = new PerformanceToPlanDataProvider()
                .LoadPerformanceToPlanData(CurrentUser, PeriodDates, ViewLevel, ViewablePeople);
        periods = dp.Periods;
        forecasts = dp.Forecasts;
        forecastOpportunities = dp.ForecastOpportunities;
        lastLoadedPeriod = Period;
    }
}