public with sharing class PetFormController {
	@AuraEnabled
	public static Id getDogRecordTypeId() {
		return Schema.SObjectType.Pet__c.getRecordTypeInfosByName().get(Constants.PET_RT_NAME_DOG).getRecordTypeId();
	}

	@AuraEnabled(cacheable=true)
	public static Object getDogBreeds() {
		String endpoint = Configuration__c.getValues('DogAPIGetBreedsEndpoint').Value__c;
		String method = Configuration__c.getValues('DogAPIGetBreedsMethod').Value__c;

		try {
			Http http = new Http();

			HttpRequest req = new HttpRequest();
			req.setEndpoint(endpoint);
			req.setMethod(method);

			HttpResponse res = http.send(req);

			Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
			if(responseBody.get('status') != 'success') throw new AuraHandledException((String) responseBody.get('message'));

			return ((Map<String,Object>) responseBody.get('message')).keySet();
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Id insertPet(SObject record){
		try {
			upsert (Pet__c) record;
			return record.Id;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
}