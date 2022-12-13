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

        if(annualQuotaConfigMap.isEmpty()) {
            Logger.Warning('[OpportunityService Error] ==> No Annual Quota Config Found');

        }

        AnnualTargetUtils.InitForOpps(newRecords.values());
        Map<Id, Opportunity> m_NewFAOpps = new Map<Id, Opportunity>(); // List for Opps with Existing FAT
        Map<String, Funnel_Addition_Target__c> targetMapping = new Map<String,Funnel_Addition_Target__c>();
        Map<Id, List<Opportunity>> QuotaConfigToOppMap = new Map<Id, List<Opportunity>>();

        Map<Id, Opportunity> processOpps = newRecords.clone();


        for(Id key : processOpps.keySet())
        {
            Opportunity newOpp = processOpps.get(key);
            if(AnnualTargetUtils.Utils.HasAccessToNewFeature(newOpp.OwnerId)) {
                for(Id configKey : annualQuotaConfigMap.keySet())
                {
                    List<Funnel_Addition_Target__c> funnelAdditionTargets = quotaToTargetMap.get(configKey);
                    Boolean targetFound = false;
                    Funnel_Addition_Target__c i_target = new Funnel_Addition_Target__c();
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



                }

                if(!quotaByFY.containsKey(String.valueOf(newOpp.CloseDate.year()))) {
                    m_NewFAOpps.put(newOpp.id, newOpp);
                }
                System.debug('Execution Complete for ===> ' + newOpp.Name);
            }

        }

        if(m_NewFAOpps.size() > 0) {
            List<Annual_Quota_Config__c> NewConfigs = AnnualQuotaService.Action.CreateNewAnnualQuotaConfiguraitionForNewOpps(m_NewFAOpps.values(), uow);
            List<Funnel_Addition_Target__c> targets = new List<Funnel_Addition_Target__c>();
            for(Annual_Quota_Config__c n_Config : NewConfigs)
            {
                //Generate Targets for the Entire Fiscal Year
                List<Funnel_Addition_Target__c> i_targets = FunnelAdditionTargetService.Action.GenerateNewTargetForQuotaConfiguration(n_Config);

                for(Funnel_Addition_Target__c target : i_targets)
                {
                    //Register newly created Targets to UnitOfWork and Register their relationship with the
                    // appropriate Config record
                    target.Quote_Config__c = n_Config.Id;
                    uow.RegisterNew(target, Funnel_Addition_Target__c.Quote_Config__c , n_Config);

                    for(Id key : m_NewFAOpps.keySet())
                    {
                        Opportunity opp = m_NewFAOpps.get(key);
                        if(target.Fiscal_Year__c == String.valueOf(opp.CloseDate.year()))
                        {
                            String pval = opp.CloseDate.month() == 1 ? 'P1' :
                                            opp.CloseDate.month() == 2 ? 'P2' :
                                                    opp.CloseDate.month() == 3 ? 'P3' :
                                                            opp.CloseDate.month() == 4 ? 'P4' :
                                                                    opp.CloseDate.month() == 5 ? 'P5' :
                                                                            opp.CloseDate.month() == 6 ? 'P6' :
                                                                                    opp.CloseDate.month() == 7 ? 'P7' :
                                                                                            opp.CloseDate.month() == 8 ? 'P8' :
                                                                                                    opp.CloseDate.month() == 9?'P9':
                                                                                                            opp.CloseDate.month() == 10 ? 'P10' :
                                                                                                                    opp.CloseDate.month() == 11 ? 'P11' : 'P12';

                            if(target.Period__c == pval)
                            {
                                Funnel_Addition__c addition = FunnelAdditionService.Action.CreateNewAddition(opp, target);
                                uow.RegisterNew(addition, Funnel_Addition__c.Funnel_Addition_Target__c, target);
                                m_NewFAOpps.remove(key);
                            }
                        }
                    }
                }

                //targets.addAll(i_targets);
            }

        }

        //Logic for Creating Funnel Additions with Existing Opps

        Logger.CommitLogs();
        uow.CommitWork();

    }


    public void AfterUpdateActions(Map<Id, Opportunity> newRecords, Map<Id, Opportunity> oldRecords) {
        UnitOfWork uow = new UnitOfWork(SOBJECTS());

        Map<Id, Opportunity> OppsWithFunnelAdditions = new Map<Id, Opportunity>();
        Map<Id, Opportunity> OppsWithChangedCloseDates = new Map<Id, Opportunity>();
        Map<Id, Opportunity> OppsMovedOutOfPeriod = new Map<Id, Opportunity>();

        Map<Id, Funnel_Addition__c> CurrentAdditions = new Map<Id, Funnel_Addition__c>(
        [SELECT Id, Period__c, Current_Period__c, Current_Amount__c, Probability_At_Start__c, Opportunity__c
        FROM
                Funnel_Addition__c
        WHERE Opportunity__c IN: newRecords.keySet()
        ]);

        //Mapping of Funnel Addition Ids to their Opportunities
        Map<Id, Opportunity> FunnelAdditionIdToOppMap = new Map<Id, Opportunity>();


        for(Id key : CurrentAdditions.keySet())
        {
            Funnel_Addition__c iAddition = CurrentAdditions.get(key);
            //See if there is a Funnel Addition for a current Opportunity
            if(newRecords.keySet().contains(iAddition.Opportunity__c))
            {
                Opportunity opp = newRecords.get(iAddition.Opportunity__c);
                OppsWithFunnelAdditions.put(opp.Id, opp);
                FunnelAdditionIdToOppMap.put(iAddition.Id, opp);
            }
        }

        AnnualTargetUtils.InitForOpps(newRecords.values());

        for(Id i_key : oldRecords.keySet())
        {
            Opportunity oldOpp = oldRecords.get(i_key);
            if(newRecords.containsKey(i_key))
            {
                Opportunity opportunity = newRecords.get(i_key);
                if(opportunity.CloseDate != oldOpp.CloseDate)
                {
                    OppsWithChangedCloseDates.put(i_key, opportunity);
                }
            }
        }

        for(Id mId : FunnelAdditionIdToOppMap.keySet())
        {
            Funnel_Addition__c mAddition = CurrentAdditions.get(mId);

            if(OppsWithChangedCloseDates.containsKey(mAddition.Opportunity__c))
            {
                Opportunity opp = OppsWithChangedCloseDates.get(mAddition.Opportunity__c);
                String periodValue = '';
                List<Period> cPeriods = new List<Period>();
                for(Period p : AnnualTargetUtils.PeriodMapByFY.keySet())
                {
                    if(p.StartDate.year() == Date.today().year())
                    {
                        cPeriods = AnnualTargetUtils.PeriodMapByFY.get(p);
                    }
                }

                for(Period p : cPeriods)
                {
                    if(p.StartDate <= opp.CloseDate && p.EndDate >= opp.CloseDate)
                    {
                        periodValue = 'P' + p.Number;
                    }
                }

                if(mAddition.Period__c != periodValue)
                {

                }
            }
        }


        uow.CommitWork();
        AnnualTargetUtils.CommitUtilLogs();


        Logger.CommitLogs();
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

    private virtual class OpportunityServiceException extends Exception { }
    private class OpportunityServiceClassException extends OpportunityServiceException {
        String message;
    }






}