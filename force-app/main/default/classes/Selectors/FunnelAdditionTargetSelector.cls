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

    private static FunnelAdditionTargetSelector m_instance;
    public static FunnelAdditionTargetSelector Instance {
        get {
            if(m_instance != null) { return m_instance; }
            System.debug('##New Funnel Addition Target Selector Instance Create');
            m_instance = new FunnelAdditionTargetSelector();
            return m_instance;
        }
    }


    public override Set<SObjectField> GetDefaultFields() {
        return new Set<SObjectField>{
                Funnel_Addition_Target__c.Id,
                Funnel_Addition_Target__c.Name,
                Funnel_Addition_Target__c.Period__c ,
                Funnel_Addition_Target__c.Fiscal_Year__c,
                Funnel_Addition_Target__c.Territory__c,
                Funnel_Addition_Target__c.Amount_at_Start__c,
                Funnel_Addition_Target__c.Current_Amount__c,
                Funnel_Addition_Target__c.Quote_Config__c,
                Funnel_Addition_Target__c.Rep__c
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

    public List<Funnel_Addition_Target__c> GetByQuotaConfig(Id key) {
        return GetQueryFactory().WithCriteria(Criteria.Equals(Funnel_Addition_Target__c.Quote_Config__c, key))
                .Execute();
    }
}