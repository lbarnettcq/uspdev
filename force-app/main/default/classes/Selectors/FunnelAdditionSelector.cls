/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class FunnelAdditionSelector extends SObjectSelector {

    public FunnelAdditionSelector() {
        super(Funnel_Addition__c.SObjectType);
    }

    private static FunnelAdditionSelector m_instance;
    public static FunnelAdditionSelector Instance {
        get {
            if(m_instance != null) { return m_instance; }
            System.debug('##New Funnel Addition Selector Instance Create');
            m_instance = new FunnelAdditionSelector();
            return m_instance;
        }
    }

    public override Set<SObjectField> GetDefaultFields() {
        return new Set<SObjectField>{
                Funnel_Addition__c.Id,
                Funnel_Addition__c.Name,
                Funnel_Addition__c.Amount_at_Start__c,
                Funnel_Addition__c.Current_Amount__c,
                Funnel_Addition__c.Current_Period__c,
                Funnel_Addition__c.Current_Amount_FF__c,
                Funnel_Addition__c.Close_Date_at_End__c,
                Funnel_Addition__c.Close_Date_at_End__c,
                Funnel_Addition__c.Period__c,
                Funnel_Addition__c.Funnel_Addition_Target__c,
                Funnel_Addition__c.Opportunity__c
        };
    }

    public List<Funnel_Addition__c> GetById(Set<Id> idset) {
        List<Funnel_Addition__c> targets = queryById(idset);
        return targets;
    }

    public List<Funnel_Addition__c> GetByName(String name) {
        List<Funnel_Addition__c> targets = queryByName(name);
        return targets;
    }

    public List<Funnel_Addition__c> GetByOpportunity(Id key) {
        return GetQueryFactory().WithCriteria(Criteria.Equals(Funnel_Addition__c.Opportunity__c, key)).Execute();
    }

    public List<Funnel_Addition__c> GetByOpportunities(Set<Id> keyset) {
        return GetQueryFactory().WithCriteria(Criteria.ValueIn(Funnel_Addition__c.Opportunity__c, keyset)).Execute();
    }

    public List<Funnel_Addition__c> GeyByOpportunity(Set<Id> keyset) {
        List<Funnel_Addition__c> targets = GetQueryFactory().WithCriteria(Criteria.ValueIn(Funnel_Addition__c.Opportunity__c, keyset)).Execute();
        return targets;
    }

    public List<Funnel_Addition__c> GetAll() {
        return queryAll();
    }
}