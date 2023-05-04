@isTest
public with sharing class PetFormControllerTest {
	@TestSetup
	static void testSetup(){
		Configuration__c endpoint = new Configuration__c (
			Name = 'DogAPIGetBreedsEndpoint',
			Value__c = 'testendpoint'
		);
		Configuration__c httpMethod = new Configuration__c (
			Name = 'DogAPIGetBreedsMethod',
			Value__c = 'GET'
		);
		insert new List<Configuration__c>{endpoint, httpMethod};
	}

	@isTest
	static void testGetDogRecordType() {
		Assert.areEqual(
			Schema.SObjectType.Pet__c.getRecordTypeInfosByName().get(Constants.PET_RT_NAME_DOG).getRecordTypeId(),
			PetFormController.getDogRecordTypeId(),
			'The returned RecordTypeId is not correct');
	}

	@isTest
	static void testInsertCompensationSuccess() {
		Pet__c pet = new Pet__c(
			Name = 'test dog name',
			Breed__c = 'boxer',
			Location__c = 'Limburg'
		);

		Test.startTest();
		Id petId = PetFormController.insertPet(pet);
		Test.stopTest();

		List<Pet__c> pets = [SELECT Id,
			Name,
			Breed__c,
			Location__c
			FROM Pet__c];

		Assert.isFalse(pets.isEmpty(), 'No Pet record has been created');
		Assert.areEqual(1, pets.size(), 'There is more than a Pet record');
		Assert.areEqual(pet.Id, pets[0].Id, 'Pet Id value is not set correctly');
		Assert.areEqual(pet.Name, pets[0].Name, 'Pet Name value is not set correctly');
		Assert.areEqual(pet.Breed__c, pets[0].Breed__c, 'Pet Breed__c value is not set correctly');
		Assert.areEqual(pet.Location__c, pets[0].Location__c, 'Pet Location__c value is not set correctly');
	}

	@isTest
	static void testInsertCompensationFail() {
		Boolean exceptionOccurred = false;

		Pet__c pet = new Pet__c(
			Location__c = 'XXXXX'
		);

		try {
			Test.startTest();
			Id petId = PetFormController.insertPet(pet);
			Test.stopTest();
		} catch (AuraHandledException ex) {
			exceptionOccurred = true;
		}

		Assert.isTrue(exceptionOccurred, 'No exception has occured');
	}

	@isTest
	static void testGetBreedSuccess() {
		Test.setMock(HttpCalloutMock.class, new TestMocks.getBreedsSuccess());

		Test.startTest();
		Set<String> response = (Set<String>) PetFormController.getDogBreeds();
		Test.stopTest();

		Assert.isTrue(!response.isEmpty(), 'No item returned');
		Assert.areEqual(2, response.size(), 'Results has not 2 items');
	}

	@isTest
	static void testGetBreedFail() {
		Test.setMock(HttpCalloutMock.class, new TestMocks.getBreedsFail());
		Boolean exceptionOccurred = false;

		try {
			Test.startTest();
			Set<String> response = (Set<String>) PetFormController.getDogBreeds();
			Test.stopTest();
		} catch (AuraHandledException ex) {
			exceptionOccurred = true;
		}

		Assert.isTrue(exceptionOccurred, 'No exception has occured');
	}
}