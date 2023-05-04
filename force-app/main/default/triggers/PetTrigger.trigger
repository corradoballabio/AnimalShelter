trigger PetTrigger on Pet__c (after insert) {
	Id dogRecordTypeId = Schema.SObjectType.Pet__c.getRecordTypeInfosByDeveloperName().get(Constants.PET_RT_NAME_DOG).getRecordTypeId();

	if(Trigger.isAfter) {
		if(Trigger.isInsert) {
			if(System.isFuture()) return;
			List<Pet__c> dogs = Utils.filter(Trigger.new, 'RecordTypeId', dogRecordTypeId, true);

			if(!dogs.isEmpty()) PetTriggerHandler.setImage(dogs);
		}
	}
}