/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class AnnualTargetSelector extends SObjectSelector {

    public AnnualTargetSelector() {
        super(Annual_Funnel_Addition_Target_Config__c.SObjectType);
    }

    private static AnnualTargetSelector m_Instance;
    public static AnnualTargetSelector Instance {
        get {
            if(m_Instance != null) { return m_Instance; }
            m_Instance = new AnnualTargetSelector();
            return m_Instance;
        }
    }


    public override Set<SObjectField> GetDefaultFields() {
        return new Set<SObjectField>{
                Annual_Funnel_Addition_Target_Config__c.Id,
                Annual_Funnel_Addition_Target_Config__c.Name,
                Annual_Funnel_Addition_Target_Config__c.IsActive__c ,
                Annual_Funnel_Addition_Target_Config__c.Fiscal_Year__c,
                Annual_Funnel_Addition_Target_Config__c.Label__c,
                Annual_Funnel_Addition_Target_Config__c.Territory__c,
                Annual_Funnel_Addition_Target_Config__c.Annual_Config_Name__c,
                Annual_Funnel_Addition_Target_Config__c.UseCustomPeriod__c,
                Annual_Funnel_Addition_Target_Config__c.Target__c,
                Annual_Funnel_Addition_Target_Config__c.CreatedById,
                Annual_Funnel_Addition_Target_Config__c.LastModifiedById,
                Annual_Funnel_Addition_Target_Config__c.CreatedDate
        };
    }

    public List<Annual_Funnel_Addition_Target_Config__c> GetAll() {
        return queryAll();
    }

    public List<Annual_Funnel_Addition_Target_Config__c> GetById(Set<Id> keyset) {
        return queryById(keyset);
    }

    public List<Annual_Funnel_Addition_Target_Config__c> GetActive() {
        return GetQueryFactory().WithCriteria(Criteria.Equals(Annual_Funnel_Addition_Target_Config__c.IsActive__c, true)).Execute();
    }

    public  List<Annual_Funnel_Addition_Target_Config__c> GetByFiscalYear(String key) {
        return GetQueryFactory().WithCriteria(Criteria.Equals(Annual_Funnel_Addition_Target_Config__c.Fiscal_Year__c, key)).Execute();
    }

    public List<Annual_Funnel_Addition_Target_Config__c> GetByLabel(String key) {
        return GetQueryFactory().WithCriteria(Criteria.Equals(Annual_Funnel_Addition_Target_Config__c.Label__c, key)).Execute();
    }
}