public with sharing class PetTriggerHandler {
	static String endpoint = Configuration__c.getValues('DogAPIGetImageEndpoint').Value__c;
	static String method = Configuration__c.getValues('DogAPIGetImageMethod').Value__c;

	public static void setImage(List<Pet__c> dogs) {
		for(Pet__c dog : dogs) {
			getPicture(JSON.serialize(dog));
		}
	}

	@future(callout=true)
	public static void getPicture(String serializedDog) {
		Pet__c dog = (Pet__c) JSON.deserialize(serializedDog, Pet__c.class);

		Http http = new Http();

		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint.replace('$$$', dog.Breed__c));
		req.setMethod(method);

		HttpResponse res = http.send(req);
		Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

		if(responseBody.get('status') != 'success') return;

		dog.PictureUrl__c = (String) responseBody.get('message');
		dog.Status__c = Constants.PET_STATUS_REGISTERED;

		update dog;
	}
}