/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

trigger AnnualTargetConfigTrigger on Annual_Funnel_Addition_Target_Config__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    AnnualTargetConfigTriggerHandler.Execute();
}