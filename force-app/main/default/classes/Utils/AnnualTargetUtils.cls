/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class AnnualTargetUtils {

    private static AnnualTargetUtils m_instance;
    public static AnnualTargetUtils Utils {
        get {
            if(m_instance != null) {return m_instance; }
            m_instance = new AnnualTargetUtils();
            return m_instance;
        }
    }

    public Funnel_Addition__c CreateNewFunnelAddition(Opportunity opportunity) {
        Funnel_Addition__c iAddition = new Funnel_Addition__c();
        iAddition.Amount_at_Start__c = opportunity.Amount;
        iAddition.Close_Date_at_Start__c = opportunity.CloseDate;
        iAddition.Probability_At_Start__c = opportunity.Probability;

        return iAddition;
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

            if(StartPeriods.Id != CurrentPeriod.Id) {
                value = true;
            }
        }
        return value;
    }

    public void UpdateAmountForCurrentFunnelAddition(Funnel_Addition__c addition, Opportunity opportunity) {
        addition.Current_Amount__c = opportunity.Amount;
    }


}