/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class OpportunityService {

    private static OpportunityService  m_instance;
    public static OpportunityService Actions {
        get {
            if(m_instance != null) {return m_instance; }
            m_instance = new OpportunityService();
            return m_instance;
        }
    }

    public LogHandling Logger = LogHandling.Instance;

    public void AfterInsertServices(Map<Id, Opportunity> newRecords, Map<Id, Opportunity> oldRecords) {

        List<Funnel_Addition__c> additionsToUpdate = new List<Funnel_Addition__c>();
        List<Funnel_Addition__c> additionsToInsert = new List<Funnel_Addition__c>();
        FunnelAdditionSelector funnelAdditionSelector = new FunnelAdditionSelector();
        Map<Id, Funnel_Addition__c> currentFunnelAdditions = new Map<Id, Funnel_Addition__c>();
        currentFunnelAdditions.putAll(funnelAdditionSelector.GetAll());
        Map<String, String> iFunnelAdditionMap = new Map<String, String>();
        for(Id key : oldRecords.keySet()) {
            Opportunity oldOpp = oldRecords.get(key);
            for(Funnel_Addition__c addition : currentFunnelAdditions.values()) {
                if (addition.Opportunity__c == oldOpp.Id) {
                    if (newRecords.containsKey(key)) {
                        Opportunity newOpp = newRecords.get(key);
                        if(newOpp.CloseDate != oldOpp.CloseDate) {
                            if(AnnualTargetUtils.Utils.IsMovedOutOfCurrentPeriod(addition,newOpp,false)) {
                                additionsToInsert.add(AnnualTargetUtils.Utils.CreateNewFunnelAddition(newOpp));
                                AnnualTargetUtils.Utils.UpdateAmountForCurrentFunnelAddition(addition,oldOpp);
                                additionsToUpdate.add(addition);
                            }else {
                                addition.Close_Date_at_End__c = newOpp.CloseDate;
                                AnnualTargetUtils.Utils.UpdateAmountForCurrentFunnelAddition(addition, newOpp);
                                additionsToUpdate.add(addition);
                            }
                        }
                        if (addition.Current_Amount__c != newOpp.Amount) {
                            addition.Current_Amount__c = newOpp.Amount;
                        }
                    }
                }
            }
        }
        Database.UpsertResult[] upsertResults = Database.upsert(additionsToUpdate, Funnel_Addition__c.Id, false);
        for(Database.UpsertResult result : upsertResults) {
            if(result.isSuccess()) { }else if(result.isCreated()) { }
            else {
                for (Database.Error error : result.getErrors()) {
                    System.debug(error.getStatusCode() + ':' + error.getMessage());
                }
            }
        }


        Database.SaveResult[] insertResults = Database.insert(additionsToInsert, false);
        for (Database.SaveResult result : insertResults) {
            if (result.isSuccess()) { }
            else {
                for(Database.Error err : result.getErrors()) {
                    //System.debug('Index of ' + insertResults.indexOf(result) + ' ' + 'Failed');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }

    }

    private List<SObjectType> OppServUnitOfWork() {
        return new List<SObjectType> {
                Opportunity.SObjectType,
                Funnel_Addition__c.SObjectType,
                Annual_Funnel_Addition_Target_Config__c.SObjectType,
                Annual_Quota_Config__c.SObjectType,
                Funnel_Addition_Target__c.SObjectType
        };
    }
}