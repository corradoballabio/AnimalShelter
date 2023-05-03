public with sharing class BatchGetDogImage implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
	Id dogRecordTypeId = Schema.SObjectType.Pet__c.getRecordTypeInfosByDeveloperName().get(Constants.PET_RT_NAME_DOG).getRecordTypeId();
	String endpoint = Configuration__c.getValues('DogAPIGetImageEndpoint').Value__c;
	String method = Configuration__c.getValues('DogAPIGetImageMethod').Value__c;
	String statusCreated = Constants.PET_STATUS_CREATED;
	Integer calloutsLimit = 50;

	public Database.QueryLocator start(Database.BatchableContext bc) {
		String query = 'SELECT Id, ' +
			'Breed__c ' +
			'FROM Pet__c ' +
			'WHERE RecordTypeId = :dogRecordTypeId ' +
			'AND Status__c = :statusCreated';

		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc, List<Pet__c> dogs) {
		for(Pet__c dog : dogs) {
			Http http = new Http();

			HttpRequest req = new HttpRequest();
			req.setEndpoint(endpoint.replace('$$$', dog.Breed__c));
			req.setMethod(method);

			HttpResponse res = http.send(req);

			Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

			dog.PictureUrl__c = (String) responseBody.get('message');
			dog.Status__c = Constants.PET_STATUS_REGISTERED;
		}

		update dogs;
	}

	public void finish(Database.BatchableContext bc) {}

	public void execute(SchedulableContext context) {
		Database.executeBatch(new BatchGetDogImage(), calloutsLimit);
	}
}