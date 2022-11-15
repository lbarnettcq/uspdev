/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class OpportunitySelector extends SObjectSelector {
    public OpportunitySelector(){
        super(Opportunity.SObjectType);
    }

    private static OpportunitySelector m_instance;
    public static OpportunitySelector Instance {
        get {
            if(m_instance != null) { return m_instance;}
            m_instance = new OpportunitySelector();
            return m_instance;
        }
    }

    public override Set<SObjectField> GetDefaultFields(){
        return new Set<SObjectField>{
                Opportunity.Id,
                Opportunity.Name,
                Opportunity.Amount,
                Opportunity.CloseDate,
                Opportunity.StageName,
                Opportunity.Type,
                Opportunity.Chemical__c,
                Opportunity.Chemical_Global__c,
                Opportunity.Territory__c,
                Opportunity.External_Id__c,
                Opportunity.Probability,
                Opportunity.Description,
                Opportunity.AccountId,
                Opportunity.Budget_Confirmed__c,
                Opportunity.Budget_Range__c,
                Opportunity.Comments__c,
                Opportunity.ContactId,
                Opportunity.IsClosed,
                Opportunity.Estimated_Monthly_Amount__c,
                Opportunity.Estimated_Revenue_Year__c,
                Opportunity.Current_Year_Revenue__c,
                Opportunity.Drivers__c,
                Opportunity.CERCOMPLETED__c,
                Opportunity.Contract_PO_Start_Date__c,
                Opportunity.Contract_PO_End_Date__c,
                Opportunity.Contract_PO_Duration__c
        };
    }

    public List<Opportunity> GetAll(){
        return queryAll();
    }

    public List<Opportunity> GetById(Set<Id> keyset) {
        return queryById(keyset);
    }

    public List<Opportunity> GetByTerritory(String key) {
        return GetQueryFactory().WithCriteria(Criteria.Equals(Opportunity.Territory__c, key)).Execute();
    }

    public List<Opportunity> GetByExternalId(Set<String> keyset){
        return GetQueryFactory().WithCriteria(Criteria.ValueIn(Opportunity.External_Id__c, keyset)).Execute();
    }

    public List<Opportunity> GetOne() {
        return querySome(1);
    }

}