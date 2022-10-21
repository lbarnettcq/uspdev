/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class AnnualQuotaConfigTriggerHandler {

    public static void Execute() {
        if(Trigger.isExecuting) {
            if(Trigger.isBefore){
                if(Trigger.isInsert) {
                    beforeInsertActions();
                }else if(Trigger.isUpdate) {
                    beforeUpdateActions();
                }else if(Trigger.isDelete) {

                }
            }
        }
    }

    private static void beforeInsertActions() {

        List<Annual_Quota_Config__c> quotaConfigs = Trigger.new;
        AnnualTargetSelector iSelector = new AnnualTargetSelector();
        for(Annual_Quota_Config__c mConfig : quotaConfigs) {
            Annual_Funnel_Addition_Target_Config__c pConfig = iSelector.GetById(new Set<Id>{ mConfig
                    .Annual_Funnel_Addition_Target_Config__c})[0];
            mConfig.AnnualTarget__c = pConfig.Target__c;
            mConfig.Period_Target__c = pConfig.Target__c/12;
        }
    }

    private static void beforeUpdateActions() {
        List<Annual_Quota_Config__c> quotaConfigs = Trigger.new;
        AnnualTargetSelector iSelector = new AnnualTargetSelector();
        for(Annual_Quota_Config__c mConfig : quotaConfigs) {
            Annual_Funnel_Addition_Target_Config__c pConfig = iSelector.GetById(new Set<Id>{ mConfig
                    .Annual_Funnel_Addition_Target_Config__c})[0];
            mConfig.AnnualTarget__c = pConfig.Target__c;
            mConfig.Period_Target__c = pConfig.Target__c/12;
        }
    }

}