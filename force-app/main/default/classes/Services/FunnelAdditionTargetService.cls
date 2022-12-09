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

    public List<Funnel_Addition_Target__c> GenerateNewTargetForQuotaConfiguration(Annual_Quota_Config__c config) {
        List<Period> fyPeriods = DefaultPeriodSelector.Instance.GetByFiscalYear(config.Fiscal_Year__c);
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

}