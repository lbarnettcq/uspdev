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
                Annual_Quota_Config__c.LastModifiedDate
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
}