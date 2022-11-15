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
        //AnnualQuotaSelector quotaSelector = new AnnualQuotaSelector();
        List<Annual_Quota_Config__c> aConfigs =  AnnualQuotaSelector.Instance.GetByFiscalYear(String.valueOf(Date.today().year()));
        aConfigs.addAll(AnnualQuotaSelector.Instance.GetByFiscalYear(String.valueOf(Date.today().addYears(1))));

        AnnualTargetUtils.InitForOpps(oldRecords.values());
        List<Opportunity> m_NewFAOpps = new List<Opportunity>();
        for(Id key : oldRecords.keySet()) {
            Opportunity oldOpp = oldRecords.get(key);
            if(AnnualTargetUtils.Utils.HasAccessToNewFeature(oldOpp.OwnerId)) {
                if(currentFunnelAdditions.values().size() > 0) {
                    for (Funnel_Addition__c addition : currentFunnelAdditions.values()) {
                        if(Test.isRunningTest()) {
                            System.debug('Test is Running');
                        }
                        Annual_Quota_Config__c quotaConfig = new Annual_Quota_Config__c();
                        for(Annual_Quota_Config__c cfg : aConfigs) {
                            if(cfg.Rep__c == UserInfo.getUserId()) { quotaConfig = cfg; }
                        }
                        //Annual_Quota_Config__c quotaConfig = quotaSelector.GetOneBySeller(Id.valueOf(UserInfo.getUserId()))[0];
                        AnnualTargetUtils.QuotaConfig = quotaConfig;
                        AnnualTargetUtils.Period = AnnualTargetUtils.Utils.GetPeriodForOpp(oldOpp, false);
                        if (addition.Opportunity__c == oldOpp.Id) {
                            if (newRecords.containsKey(key)) {
                                Opportunity newOpp = newRecords.get(key);
                                if (newOpp.CloseDate != oldOpp.CloseDate) {
                                    if (AnnualTargetUtils.Utils.IsMovedOutOfCurrentPeriod(addition, newOpp, false)) {
                                        additionsToInsert.add(AnnualTargetUtils.Utils.CreateNewFunnelAddition(newOpp, true));
                                        AnnualTargetUtils.Utils.UpdateAmountForCurrentFunnelAddition(addition, oldOpp);
                                        additionsToUpdate.add(addition);
                                    } else {
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
                }else {
                    //additionsToInsert.addAll(FunnelAdditionService.Action.CreateNewAdditionsForNewOpps(newRecords
                    //.values()));
                    m_NewFAOpps.addAll(newRecords.values());
                }
            }
        }

        if(m_NewFAOpps.size() > 0) {
            additionsToInsert.addAll(FunnelAdditionService.Action.CreateNewAdditionsForNewOpps(m_NewFAOpps));
        }
        //System.debug(additionsToUpdate);
        if(additionsToUpdate.size() > 0) {
            Database.UpsertResult[] upsertResults = Database.upsert(additionsToUpdate, Funnel_Addition__c.Id, false);
            for(Database.UpsertResult result : upsertResults) {
                if(result.isSuccess()) { }else if(result.isCreated()) { }
                else {
                    for (Database.Error error : result.getErrors()) {
                        System.debug(error.getStatusCode() + ':' + error.getMessage());
                    }
                }
            }
        }


        //System.debug(additionsToInsert);
        if(additionsToInsert.size() > 0) {
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


    }

    public void AfterUpdateActions(Map<Id, Opportunity> newRecords, Map<Id, Opportunity> oldRecords) {
        List<Funnel_Addition__c> additionsToUpdate = new List<Funnel_Addition__c>();
        List<Funnel_Addition__c> additionsToInsert = new List<Funnel_Addition__c>();
        //FunnelAdditionSelector funnelAdditionSelector = new FunnelAdditionSelector();
        //Map<Id, Funnel_Addition__c> currentFunnelAdditions = new Map<Id, Funnel_Addition__c>();
        //currentFunnelAdditions.putAll(funnelAdditionSelector.GetAll());
        //Map<String, String> iFunnelAdditionMap = new Map<String, String>();
        AnnualQuotaSelector quotaSelector = new AnnualQuotaSelector();
        Map<Id, Annual_Quota_Config__c> annualQuotaConfigMap = new Map<Id, Annual_Quota_Config__c>();
        annualQuotaConfigMap.putAll(quotaSelector.GetAll());

        Map<String, Object> returnData = new Map<String, Object>();
        AnnualTargetUtils.InitForOpps(oldRecords.values());
        for(Id key : oldRecords.keySet()) {
            Opportunity oldOpp = oldRecords.get(key);
            if(AnnualTargetUtils.Utils.HasAccessToNewFeature(oldOpp.OwnerId)) {
                if (newRecords.containsKey(key)) {
                    Opportunity newOpp = newRecords.get(key);
                    String fy = String.valueOf(oldOpp.CloseDate.year());
                    Annual_Quota_Config__c i_config = new Annual_Quota_Config__c();
                    for(Annual_Quota_Config__c config : annualQuotaConfigMap.values()) {
                        if(Test.isRunningTest()) {
                            if(config.Name__c == 'Test Config') {
                                i_config = config;
                            }
                        }else {
                            if(config.Rep__c == UserInfo.getUserId() ) { i_config = config; }
                        }
                    }
                    if(i_config == null) {
                        Logger.Error('No Config found for You. Please Create Quota Configuration for ' + UserInfo.getUserName());
                    }else
                    {
                        AnnualTargetUtils.QuotaConfig = i_config;
                        if(AnnualTargetUtils.Utils.IsThereExistingFunnelAddition(oldOpp)) {
                            Funnel_Addition__c addition = AnnualTargetUtils.Utils.GetFunnelAddition(oldOpp);
                            Map<String, Object> data = Logic(oldOpp, newOpp, addition);
                            additionsToInsert.addAll((List<Funnel_Addition__c>) data.get('toInsert'));
                            additionsToUpdate.addAll((List<Funnel_Addition__c>) data.get('toUpdate'));
                        }else {
                            Funnel_Addition__c addition = AnnualTargetUtils.Utils.CreateNewFunnelAddition(newOpp, true);
                            Map<String, Object> data = Logic(oldOpp, newOpp, addition);
                            additionsToInsert.addAll((List<Funnel_Addition__c>) data.get('toInsert'));
                            additionsToUpdate.addAll((List<Funnel_Addition__c>) data.get('toUpdate'));
                        }
                    }

                }
            }
        }
        if(additionsToUpdate.size() > 0) {
            Database.UpsertResult[] upsertResults = Database.upsert(additionsToUpdate, Funnel_Addition__c.Id, false);
            for(Database.UpsertResult result : upsertResults) {
                if(result.isSuccess()) { }else if(result.isCreated()) { }
                else {
                    for (Database.Error error : result.getErrors()) {
                        System.debug(error.getStatusCode() + ':' + error.getMessage());
                    }
                }
            }
        }


        //System.debug(additionsToInsert);
        if(additionsToInsert.size() > 0) {
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
        AnnualTargetUtils.CommitUtilLogs();


        Logger.CommitLogs();
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

    private Boolean HasAccessToNewFeature(Id key) {
        UserSelector selector = new UserSelector();
        User u = (User) selector.GetQueryFactory().WithCriteria(Criteria.Equals(User.Id, key)).Execute()[0];

        Boolean accessBool;
        Set < Id > permissionSetIds = new Set < Id >();
        List < User > userList = new List < User >();
        for ( SetupEntityAccess access : [ SELECT ParentId
                                            FROM SetupEntityAccess
                                            WHERE SetupEntityId IN
                                                ( SELECT Id
                                                    FROM CustomPermission
                                                    WHERE DeveloperName = 'Use_New_FAT_Functionality' )
        ] )
            permissionSetIds.add(access.ParentId);

        userList = [ SELECT Username FROM User WHERE Id IN (
                SELECT AssigneeId FROM PermissionSetAssignment
                WHERE PermissionSetId IN :permissionSetIds AND AssigneeId =: u.Id ) ];
        accessBool = userList.isEmpty() ? false : true;
        return accessBool;
    }

    private Map<String, Object> Logic(Opportunity oldOpp, Opportunity newOpp, Funnel_Addition__c addition) {
        Map<String, Object> returnData = new Map<String, Object>();
        List<Funnel_Addition__c> additionsToInsert = new List<Funnel_Addition__c>();
        List<Funnel_Addition__c> additionsToUpdate = new List<Funnel_Addition__c>();
        if (newOpp.CloseDate != oldOpp.CloseDate) {
            if (AnnualTargetUtils.Utils.IsMovedOutOfCurrentPeriod(addition, newOpp, false)) {
                additionsToInsert.add(AnnualTargetUtils.Utils.CreateNewFunnelAddition(newOpp, true));
                AnnualTargetUtils.Utils.UpdateAmountForCurrentFunnelAddition(addition, oldOpp);
                additionsToUpdate.add(addition);
            } else {
                addition.Close_Date_at_End__c = newOpp.CloseDate;
                AnnualTargetUtils.Utils.SetStartOfPeriodForAddition(addition);
                AnnualTargetUtils.Utils.UpdateAmountForCurrentFunnelAddition(addition, newOpp);
                additionsToUpdate.add(addition);
            }
        }
        if (addition.Current_Amount__c != newOpp.Amount) {
            addition.Current_Amount__c = newOpp.Amount;
        }

        returnData.put('toInsert', additionsToInsert);
        returnData.put('toUpdate',  additionsToUpdate);
        return  returnData;
    }


}