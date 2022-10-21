trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {
	Trigger_Config__c settings = Trigger_Config__c.getInstance();
	if(!settings.Disable_Triggers__c) {
		if(!settings.Disable_Triggers__c) {
			OpportunityTriggerHandler.Execute();
		}
	}
}