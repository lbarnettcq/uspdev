/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class AnnualQuotaSelector extends SObjectSelector {
    public AnnualQuotaSelector() {
        super(Annual_Quota_Config__c.SObjectType);
    }

    private static AnnualQuotaSelector m_instance;
    public static AnnualQuotaSelector Instance{
        get {
            if(m_instance != null){ return m_instance;}
            m_instance = new AnnualQuotaSelector();
            return m_instance;
        }
    }


    public override Set<SObjectField> GetDefaultFields() {
        return new Set<SObjectField> {
                Annual_Quota_Config__c.Id,
                Annual_Quota_Config__c.Name,
                Annual_Quota_Config__c.IsSeller__c,
                Annual_Quota_Config__c.AnnualTarget__c,
                Annual_Quota_Config__c.Period_Target__c,
                Annual_Quota_Config__c.Rep__c,
                Annual_Quota_Config__c.CreatedById,
                Annual_Quota_Config__c.CreatedDate,
                Annual_Quota_Config__c.LastModifiedById,
                Annual_Quota_Config__c.LastModifiedDate ,
                Annual_Quota_Config__c.Fiscal_Year__c,
                Annual_Quota_Config__c.Territory__c,
                Annual_Quota_Config__c.UseCustomPeriod__c,
                Annual_Quota_Config__c.Name__c
        };
    }

    public List<Annual_Quota_Config__c> GetById(Set<id> idset) {
        return queryById(idset);
    }

    public List<Annual_Quota_Config__c> GetByName(String name) {
        return queryByName(name);
    }

    public List<Annual_Quota_Config__c> GetAll() {
        return queryAll();
    }

    public List<Annual_Quota_Config__c> GetSellerConfig() {
        return GetQueryFactory().WithCriteria(Criteria.Equals(Annual_Quota_Config__c.IsSeller__c, true)).Execute();
    }

    public List<Annual_Quota_Config__c> GetBySeller(Set<Id> idset) {
        return GetQueryFactory().WithCriteria(Criteria.ValueIn(Annual_Quota_Config__c.Rep__c, idset)).Execute();
    }

    public List<Annual_Quota_Config__c> GetOneBySeller(Id key) {
        return GetQueryFactory().WithCriteria(Criteria.Equals(Annual_Quota_Config__c.Rep__c, key)).Execute();
    }

    public List<Annual_Quota_Config__c> GetByTargetConfig(Id key){
        return GetQueryFactory().WithCriteria(Criteria.Equals(Annual_Quota_Config__c.Annual_Funnel_Addition_Target_Config__c, key)).Execute();
    }

    public List<Annual_Quota_Config__c> GetByLabel(String key) {
        return GetQueryFactory().WithCriteria(Criteria.Equals(Annual_Quota_Config__c.Name__c, key)).Execute();
    }

    public List<Annual_Quota_Config__c> GetByFiscalYear(String key) {
        return GetQueryFactory().WithCriteria(Criteria.Equals(Annual_Quota_Config__c.Fiscal_Year__c, key)).Execute();
    }
}