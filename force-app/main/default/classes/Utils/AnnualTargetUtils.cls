/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class AnnualTargetUtils {

    //private static String m_Period;
    public static String Period;

    private static AnnualTargetUtils m_instance;
    public static AnnualTargetUtils Utils {
        get {
            if(m_instance != null) {return m_instance; }
            System.debug('[][] New Instance of UTILS created');
            m_instance = new AnnualTargetUtils();
            return m_instance;
        }
    }

    //private static Annual_Quota_Config__c m_quotaConfig;
    public static Annual_Quota_Config__c QuotaConfig = new Annual_Quota_Config__c();

    public Funnel_Addition__c CreateNewFunnelAddition(Opportunity opportunity) {
        FunnelAdditionTargetSelector sFunneladditiontargetselector = new FunnelAdditionTargetSelector();
        Funnel_Addition__c iAddition = new Funnel_Addition__c();
        iAddition.Amount_at_Start__c = opportunity.Amount;
        iAddition.Close_Date_at_Start__c = opportunity.CloseDate;
        iAddition.Probability_At_Start__c = opportunity.Probability;
        iAddition.Funnel_Addition_Target__c = QuotaConfig != null ? sFunneladditiontargetselector.GetByQuotaConfig
        (QuotaConfig.Id)[0].Id : null;
        System.debug('[][]Creating new Funnel Addition [][][]');
        System.debug(iAddition);

        return iAddition;
    }

    public Funnel_Addition__c GetFunnelAddition(Opportunity opportunity) {
        FunnelAdditionSelector selector = new FunnelAdditionSelector();
        return selector.GetByOpportunity(opportunity.Id)[0];
    }

    public Boolean IsThereExistingFunnelAddition(Opportunity opportunity) {
        FunnelAdditionSelector selector = new FunnelAdditionSelector();
        Boolean val = true;

        if(selector.GetByOpportunity(opportunity.Id).isEmpty()) {
            val = false;
        }

        return val;
    }


    public Boolean IsMovedOutOfCurrentPeriod(Funnel_Addition__c addition, Opportunity opportunity, Boolean
            CustomPeriodOverride) {
        Boolean value = false;
        if(CustomPeriodOverride == false) {
            DefaultPeriodSelector selector = new DefaultPeriodSelector();
            Period StartPeriods = selector.GetWhereDateIn(addition.Close_Date_at_Start__c)[0];
            Period CurrentPeriod = selector.GetWhereDateIn(Opportunity.CloseDate)[0];
            //m_Period = 'P' + String.valueOf(StartPeriods.Number);

            if(StartPeriods.Id != CurrentPeriod.Id) {
                value = true;
            }
        }
        return value;
    }

    public void UpdateAmountForCurrentFunnelAddition(Funnel_Addition__c addition, Opportunity opportunity) {
        addition.Current_Amount__c = opportunity.Amount;
    }

    private void CreateNewFunnelAdditionTarget(Funnel_Addition__c addition) {
        Funnel_Addition_Target__c newTarget = new Funnel_Addition_Target__c();

    }

    private Boolean IsThereExistingFAT(Funnel_Addition__c addition) {
        Boolean val = false;

        return val;
    }

    public String GetPeriodForOpp(Opportunity opportunity, Boolean CustomPeriodOverride) {
        String value = '';
        if(!CustomPeriodOverride) {
            DefaultPeriodSelector selector = new DefaultPeriodSelector();
            Period p = selector.GetWhereDateIn(opportunity.CloseDate)[0];
            value = 'P' + p.Number;
        }
        return value;
    }


}