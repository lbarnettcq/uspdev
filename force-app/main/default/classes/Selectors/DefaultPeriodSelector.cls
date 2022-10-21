/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class DefaultPeriodSelector extends SObjectSelector{

    public DefaultPeriodSelector(){
        super(Period.SObjectType);
    }


    public override Set<SObjectField> GetDefaultFields() {
        return new Set<SObjectField>{
                Period.Id,
                Period.FullyQualifiedLabel,
                Period.StartDate,
                Period.EndDate,
                Period.Type,
                Period.FiscalYearSettingsId,
                Period.IsForecastPeriod,
                Period.PeriodLabel,
                Period.QuarterLabel,
                Period.Number
        };
    }

    public List<Period> GeyById(Set<Id> keyset) {
        return queryById(keyset);
    }

    public List<Period> GeyByLabel(String key) {
        return GetQueryFactory().WithCriteria(Criteria.Equals(Period.FullyQualifiedLabel, key)).Execute();
    }

    public List<Period> GetWhereDateIn(Date  dateValue) {
        List<Period> periods = [SELECT Id, FullyQualifiedLabel, StartDate, EndDate, Type,FiscalYearSettingsId,Number FROM
                Period WHERE StartDate
                <=: dateValue AND EndDate >=: dateValue AND Type = 'Month'];
        return periods;
    }
}