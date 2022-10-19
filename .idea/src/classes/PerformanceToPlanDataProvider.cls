public with sharing class PerformanceToPlanDataProvider {
    public Map<Id, Opportunity> ForecastOpportunities { get; set; }
    public Map<Id, ForecastingFact> Forecasts { get; set; }
    public Map<Id, Period> Periods { get; set; }
    private static Boolean debugOn = Test.isRunningTest();
    
    public PerformanceToPlanDataProvider LoadPerformanceToPlanData(Id currentUser, List<Date> periodDates
            , String viewLevel, List<SelectOption> viewablePeople) {
        loadPeriods(periodDates);
        loadForecasts(currentUser, viewLevel, viewablePeople);
        loadForecastOpportunities();
        return this;
    }

    public static String generatePeriodQuery(List<Date> periodDates) {
        String query = 'SELECT Id, Type, StartDate, EndDate, FullyQualifiedLabel '
                + 'FROM Period '
                + 'WHERE IsForecastPeriod = TRUE AND Type = \'Month\' ';
        if (periodDates != null && !periodDates.isEmpty()) {
            query += 'AND ( ';
            String periodWhere = '';
            for (Date dt : periodDates) {
                if (periodWhere.length() > 0) { periodWhere += ' OR '; }
                periodWhere += '(StartDate <= ' + String.valueOf(dt) + ' AND EndDate >= ' + String.valueOf(dt) + ')';
            }
            query += periodWhere + ') ';
        }
        query += 'ORDER BY StartDate ASC';
        if (debugOn) { System.debug('[][PerformanceToPlanDataProvider][loadPeriods][] QUERY => ' + query); }
        return query;
    }

    private void loadPeriods(List<Date> periodDates) {
        String query = generatePeriodQuery(periodDates);
        Periods = new Map<Id, Period>((List<Period>)Database.query(query));
    }

    private void loadForecasts(Id currentUser, String viewLevel, List<SelectOption> viewablePeople) {
        String query = 'SELECT Id, OwnerId, PeriodId, ForecastCategoryName, ForecastingItem.Id, '
                + 'ForecastingItem.ForecastAmount, OpportunityId '
                + 'FROM ForecastingFact WHERE ForecastingTypeId IN '
                + '(SELECT Id FROM ForecastingType WHERE MasterLabel = \'Opportunity Revenue\')';
        if (viewLevel == 'All') {
            String users = '';
            Boolean foundMe = false;
            Integer myDepth = 0;
            for (SelectOption person : viewablePeople) {
                String thisPerson = String.valueOf(person.getValue());
                Integer thisPersonDepth = person.getLabel().countMatches(' .');
                if (!foundMe && thisPerson == String.valueOf(currentUser)) {
                    myDepth = person.getLabel().countMatches(' .');
                    foundMe = true;
                    if (users.length() > 1) { users += ','; }
                    users += '\'' + thisPerson + '\'';
                } else if (foundMe) {
                    if (thisPersonDepth <= myDepth) {
                        break;
                    } else {
                        if (users.length() > 1) { users += ','; }
                        users += '\'' + thisPerson + '\'';
                    }
                }
            }
            query += ' AND OwnerId IN (' + users + ')';
        } else {
            query += ' AND OwnerId = \'' + currentUser + '\'';
        }
        query += ' AND PeriodId IN ' + idSetQuery(Periods.keySet());
        if (debugOn) { System.debug('[][PerformanceToPlanDataProvider][loadForecasts][] QUERY => ' + query); }
        if (Test.isRunningTest()) {
            Forecasts = TestDataFactory.loadMockForecasts(currentUser, Periods.keySet());
            return;
        }
        Forecasts = new Map<Id, ForecastingFact>((List<ForecastingFact>)Database.query(query));
    }

    private void loadForecastOpportunities() {
        Map<Id, Id> oppIds = new Map<Id, Id>();
        for (ForecastingFact fact : Forecasts.values()) {
            if (debugOn) { System.debug('[][PerformanceToPlanDataProvider][loadForecastOpportunities][] fact => ' + fact); }
            if (debugOn) { System.debug('[][PerformanceToPlanDataProvider][loadForecastOpportunities][] forecasts => ' + fact); }
            oppIds.put(fact.Id, fact.OpportunityId);
        }
        if (oppIds == null || oppIds.values() == null || oppIds.values().isEmpty()) { return; }
        String query = 'SELECT Id, StageName, Probability, IsClosed, IsWon, CreatedDate, CloseDate, LastModifiedDate, Estimated_Monthly_Amount__c, Amount '
                + 'FROM Opportunity '
                + 'WHERE Id IN ' + idSetQuery(new Set<Id>(oppIds.values()));
        if (debugOn) { System.debug('[][PerformanceToPlanDataProvider][loadForecastOpportunities][] QUERY => ' + query); }
        Map<Id, Opportunity> oppList = new Map<Id, Opportunity>((List<Opportunity>)Database.query(query));
        //if (debug) { System.debug(('### Opp List =>  ' + oppList)); }
        ForecastOpportunities = new Map<Id, Opportunity>();
        for (Id key : oppIds.keySet()) {
            ForecastOpportunities.put(key, oppList.get(oppIds.get(key)));
        }
        if (Test.isRunningTest()) {
            ForecastOpportunities = TestDataFactory.loadMockForecastOpportunities(Forecasts);
            return;
        }
    }

    private String idSetQuery(Set<Id> idSet) {
        String query = '';
        for (Id item : idSet) {
            if (query.length() > 0) { query += ','; }
            query += '\'' + item + '\'';
        }
        return '(' + query + ')';
    }
}