/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class FunnelAdditionTargetSelector extends SObjectSelector{

    public FunnelAdditionTargetSelector(){
        super(Funnel_Addition_Target__c.SObjectType);
    }


    public override Set<SObjectField> GetDefaultFields() {
        return new Set<SObjectField>{
                Funnel_Addition_Target__c.Id,
                Funnel_Addition_Target__c.Name,
                Funnel_Addition_Target__c.Period__c
        };
    }

    public List<Funnel_Addition_Target__c> GetById(Set<Id> keyset) {
        return queryById(keyset);
    }

    public List<Funnel_Addition_Target__c> GetBYName(String name) {
        return queryByName(name);
    }

    public List<Funnel_Addition_Target__c> GetAll() {
        return queryAll();
    }

    public List<Funnel_Addition_Target__c> GetByPeriod(String key) {
        return GetQueryFactory().WithCriteria(Criteria.Equals(Funnel_Addition_Target__c.Period__c, key)).Execute();
    }
}