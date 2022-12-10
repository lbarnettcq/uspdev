/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class CustomPeriodSelector extends SObjectSelector {

    public CustomPeriodSelector() {
        super(Period_Config__c.SObjectType);
    }

    public override Set<SObjectField> GetDefaultFields() {
        return new Set<SObjectField>{
                Period_Config__c.Id,
                Period_Config__c.Name,
                Period_Config__c.Annual_Funnel_Addition_Target_Config__c,
                Period_Config__c.IsDeleted
        };
    }

    public List<Period_Config__c> GetAll() {
        return queryAll();
    }

    public List<Period_Config__c> GetById(Set<Id> keyset) {
        return queryById(keyset);
    }

    public List<Period_Config__c> GetById(Id key) {
        Set<Id> keyset = new Set<Id>();
        keyset.add(key);
        return queryById(keyset);
    }

    public List<Period_Config__c> GeyByName(String name) {
        return queryByName(name);
    }

    public List<Period_Config__c> GetByAnnualConfigs(Id key) {
        return GetQueryFactory().WithCriteria(Criteria.Equals(Period_Config__c.Annual_Funnel_Addition_Target_Config__c, key)).Execute();
    }

}