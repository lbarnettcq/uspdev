/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class FunnelAdditionTargetService {
    private static FunnelAdditionTargetService m_actions;
    public static FunnelAdditionTargetService Action {
        get {
            if(m_actions != null) { return m_actions;}
            m_actions = new FunnelAdditionTargetService();
            return m_actions;
        }
    }

    private static final List<Period> i_Periods = DefaultPeriodSelector.Instance.queryAll();
    private static final List<FiscalYearSettings> iYEAR_SETTINGS = [SELECT Id, Name FROM FiscalYearSettings];

    public List<Funnel_Addition_Target__c> GenerateNewTargetForQuotaConfiguration(Annual_Quota_Config__c config) {
        //List<Period> fyPeriods = DefaultPeriodSelector.Instance.GetByFiscalYear(config.Fiscal_Year__c);
        List<Period> fyPeriods = new List<Period>();
        for(Period period : i_Periods) {
            if(period.Type == 'Month') {
                for(FiscalYearSettings fiscalYearSettings : iYEAR_SETTINGS) {
                    if(period.FiscalYearSettingsId == fiscalYearSettings.Id) {
                        if(fiscalYearSettings.Name == config.Fiscal_Year__c) {
                            fyPeriods.add(period);
                        }
                    }
                }
            }
        }

        List<Funnel_Addition_Target__c> newTargets = new List<Funnel_Addition_Target__c>();
        if(!fyPeriods.isEmpty()) {
            for(Period p : fyPeriods) {
                Funnel_Addition_Target__c target = new Funnel_Addition_Target__c(
                        Quote_Config__c = config.Id,
                        Fiscal_Year__c = config.Fiscal_Year__c,
                        Rep__c = config.Rep__c,
                        Territory__c = config.Territory__c,
                        Period__c = String.valueOf('P' + p.Number)
                );
                newTargets.add(target);
            }
        }
        return newTargets;
    }

    public void CreateNewFATWithNewConfig(List<Annual_Quota_Config__c> configs, UnitOfWork uow) {
        for(Annual_Quota_Config__c config : configs) {

        }
    }

}