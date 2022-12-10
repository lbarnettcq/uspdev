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

    public void AfterInsertServices(Map<Id, Opportunity> newRecords, Map<Id, Opportunity> oldRecords)
    {
        UnitOfWork uow = new UnitOfWork(SOBJECTS());

        List<Funnel_Addition__c> additionsToUpdate = new List<Funnel_Addition__c>();
        List<Funnel_Addition__c> additionsToInsert = new List<Funnel_Addition__c>();
        FunnelAdditionSelector funnelAdditionSelector = new FunnelAdditionSelector();
        Map<Id, Funnel_Addition__c> currentFunnelAdditions = new Map<Id, Funnel_Addition__c>();
        currentFunnelAdditions.putAll(funnelAdditionSelector.GetAll());
        Map<String, String> iFunnelAdditionMap = new Map<String, String>();
        AnnualQuotaSelector quotaSelector = new AnnualQuotaSelector();


        List<Annual_Quota_Config__c> aConfigs =  AnnualQuotaSelector.Instance.GetByFiscalYear(String.valueOf(Date.today().year()));
        aConfigs.addAll(AnnualQuotaSelector.Instance.GetByFiscalYear(String.valueOf(Date.today().year() + 1)));


        Map<Id, Annual_Quota_Config__c> annualQuotaConfigMap = new Map<Id, Annual_Quota_Config__c>();
        annualQuotaConfigMap.putAll(quotaSelector.GetAll());


        Map<Id, Funnel_Addition_Target__c> funnelAdditionTargetMap = new Map<Id, Funnel_Addition_Target__c>(
        [
                SELECT Id,
                        Quote_Config__c, Fiscal_Year__c, Rep__c, Territory__c, Amount_at_Start__c, Current_Amount__c,Period__c
                FROM
                        Funnel_Addition_Target__c
                WHERE Quote_Config__c IN: annualQuotaConfigMap.keySet()
        ]);
        Map<Id, List<Funnel_Addition_Target__c>> quotaToTargetMap = new Map<Id, List<Funnel_Addition_Target__c>>();
        Map<String, List<Annual_Quota_Config__c>> quotaByFY = new Map<String, List<Annual_Quota_Config__c>>();

        for(Id key : annualQuotaConfigMap.keySet()) {
            Annual_Quota_Config__c config = annualQuotaConfigMap.get(key);
            if(!quotaToTargetMap.containsKey(key)) {
                List<Funnel_Addition_Target__c> targets = new List<Funnel_Addition_Target__c>();
                for(Funnel_Addition_Target__c target : funnelAdditionTargetMap.values()) {
                    if(target.Quote_Config__c == config.Id) { targets.add(target);}
                }
                if(targets.size() > 0) {
                    quotaToTargetMap.put(config.Id, targets);
                }
            }

            if(quotaByFY.containsKey(config.Fiscal_Year__c)) {
                quotaByFY.get(config.Fiscal_Year__c).add(config);
            }else {
                quotaByFY.put(config.Fiscal_Year__c, new List<Annual_Quota_Config__c>{config});
            }
        }

        AnnualTargetUtils.InitForOpps(newRecords.values());
        List<Opportunity> m_NewFAOpps = new List<Opportunity>(); // List for Opps with Existing FAT
        Map<String, Funnel_Addition_Target__c> targetMapping = new Map<String,Funnel_Addition_Target__c>();
        Map<Id, List<Opportunity>> QuotaConfigToOppMap = new Map<Id, List<Opportunity>>();

        Map<Id, Opportunity> processOpps = newRecords.clone();


        for(Id key : processOpps.keySet())
        {
            Opportunity newOpp = processOpps.get(key);
            if(AnnualTargetUtils.Utils.HasAccessToNewFeature(newOpp.OwnerId)) {
                for(Id configKey : annualQuotaConfigMap.keySet()) {
                    List<Funnel_Addition_Target__c> funnelAdditionTargets = quotaToTargetMap.get(configKey);
                    List<Period> currentFYPeriods = new List<Period>();
                    for(Period pYear : AnnualTargetUtils.PeriodMapByFY.keySet()) {
                        if(newOpp.CloseDate.year() == pYear.StartDate.year())
                        {
                            currentFYPeriods = AnnualTargetUtils.PeriodMapByFY.get(pYear);
                        }
                    }
                    Boolean targetFound = false;
                    Funnel_Addition_Target__c i_target = new Funnel_Addition_Target__c();
                    String pVal = '';
                    Annual_Quota_Config__c i_config = new Annual_Quota_Config__c();
                    if(quotaByFY.containsKey(String.valueOf(newOpp.CloseDate.year())))
                    {
                        List<Annual_Quota_Config__c> CurrentFYConfig = quotaByFY.get(String.valueOf(newOpp.CloseDate.year()));
                        for(Annual_Quota_Config__c config : CurrentFYConfig)
                        {
                            if(config.Fiscal_Year__c == String.valueOf(newOpp.CloseDate.year()))
                            {
                                i_config = config;
                            }
                        }
                        if(QuotaConfigToOppMap.containsKey(i_config.Id))
                        {
                            QuotaConfigToOppMap.get(i_config.Id).add(newOpp);
                        }else if(i_config.Id != null) {
                            QuotaConfigToOppMap.put(i_config.Id, new List<Opportunity>{newOpp});
                        }

                    }

                    if(!quotaByFY.containsKey(String.valueOf(newOpp.CloseDate.year()))) {
                        m_NewFAOpps.add(newOpp);
                    }


                }
                System.debug('Execution Complete for ===> ' + newOpp.Name);
            }

        }
        if(m_NewFAOpps.size() > 0) {
            List<Annual_Quota_Config__c> NewConfigs = AnnualQuotaService.Action.CreateNewAnnualQuotaConfiguraitionForNewOpps(m_NewFAOpps, uow);
        }

        Logger.CommitLogs();
        uow.CommitWork();

    }


    public void AfterUpdateActions(Map<Id, Opportunity> newRecords, Map<Id, Opportunity> oldRecords) {
        List<Funnel_Addition__c> additionsToUpdate = new List<Funnel_Addition__c>();
        List<Funnel_Addition__c> additionsToInsert = new List<Funnel_Addition__c>();
        AnnualQuotaSelector quotaSelector = new AnnualQuotaSelector();
        Map<Id, Annual_Quota_Config__c> annualQuotaConfigMap = new Map<Id, Annual_Quota_Config__c>();
        annualQuotaConfigMap.putAll(quotaSelector.GetAll());
        Map<Id, Funnel_Addition_Target__c> funnelAdditionTargetMap = new Map<Id, Funnel_Addition_Target__c>(
        [
                SELECT Id,
                Quote_Config__c, Fiscal_Year__c, Rep__c, Territory__c, Amount_at_Start__c, Current_Amount__c
                FROM
                Funnel_Addition_Target__c
                WHERE Quote_Config__c IN: annualQuotaConfigMap.keySet()
        ]);
        Map<Id, List<Funnel_Addition_Target__c>> quotaToTargetMap = new Map<Id, List<Funnel_Addition_Target__c>>();
        UnitOfWork uow = new UnitOfWork(SOBJECTS());
        for(Id key : annualQuotaConfigMap.keySet()) {
            Annual_Quota_Config__c config = annualQuotaConfigMap.get(key);
            if(!quotaToTargetMap.containsKey(key)) {
                List<Funnel_Addition_Target__c> targets = new List<Funnel_Addition_Target__c>();
                for(Funnel_Addition_Target__c target : funnelAdditionTargetMap.values()) {
                    if(target.Quote_Config__c == config.Id) { targets.add(target);}
                }
                if(targets.size() > 0) {
                    quotaToTargetMap.put(config.Id, targets);
                }
            }
        }
        Map<String, Funnel_Addition_Target__c> targetMapping = new Map<String, Funnel_Addition_Target__c>();

        Map<String, Object> returnData = new Map<String, Object>();
        AnnualTargetUtils.InitForOpps(newRecords.values());
        for(Id key : oldRecords.keySet()) {
            Opportunity oldOpp = oldRecords.get(key);
            if(AnnualTargetUtils.Utils.HasAccessToNewFeature(oldOpp.OwnerId)) {
                if (newRecords.containsKey(key)) {

                }
            }
        }

        uow.CommitWork();
        AnnualTargetUtils.CommitUtilLogs();


        Logger.CommitLogs();
    }

    private Funnel_Addition_Target__c CreateNewTarget(String CurrentPeriod, Annual_Quota_Config__c config, UnitOfWork
    uow) {
        Funnel_Addition_Target__c iTarget= new Funnel_Addition_Target__c();
        iTarget.Quote_Config__c = config.Id;
        iTarget.Rep__c = config.Rep__c;
        iTarget.Period__c = CurrentPeriod;
        iTarget.Territory__c = config.Territory__c;
        iTarget.Fiscal_Year__c = config.Fiscal_Year__c;
        //TODO: Bulkify This, currently executing in a loop
        uow.RegisterNew(iTarget);
        return iTarget;
    }




    private Map<String, Object> Logic(Opportunity oldOpp, Opportunity newOpp, Funnel_Addition__c addition, UnitOfWork
    uow) {
        Map<String, Object> returnData = new Map<String, Object>();
        List<Funnel_Addition__c> additionsToInsert = new List<Funnel_Addition__c>();
        List<Funnel_Addition__c> additionsToUpdate = new List<Funnel_Addition__c>();
        if (newOpp.CloseDate != oldOpp.CloseDate) {
            if (AnnualTargetUtils.Utils.IsMovedOutOfCurrentPeriod(addition, newOpp, false)) {
                additionsToInsert.add(AnnualTargetUtils.Utils.CreateNewFunnelAddition(newOpp, true, uow));
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


    private static List<SObjectType> SOBJECTS()
    {
        return new List<SObjectType> {
                Annual_Funnel_Addition_Target_Config__c.SObjectType,
                Annual_Quota_Config__c.SObjectType,
                Funnel_Addition_Target__c.SObjectType,
                Opportunity.SObjectType,
                Funnel_Addition__c.SObjectType
        };
    }




}