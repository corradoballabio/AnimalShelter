trigger AdoptionRequestTrigger on AdoptionRequest__c (after insert, after update) {
	if(Trigger.isAfter) {
		if(Trigger.isInsert) {
			AdoptionRequestTriggerHandler.setPetStatus(Trigger.new);
		}
		if(Trigger.isUpdate) {
			AdoptionRequestTriggerHandler.setPetStatus(Trigger.new);
		}
	}
}