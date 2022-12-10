/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

trigger AnnualQuotaConfidTrigger on Annual_Quota_Config__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Config__c settings = Trigger_Config__c.getInstance();
    if(settings.Disable_Triggers__c == false) {
        AnnualQuotaConfigTriggerHandler.Execute();
    }

}