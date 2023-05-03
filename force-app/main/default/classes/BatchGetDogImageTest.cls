@isTest
public with sharing class BatchGetDogImageTest {

	@TestSetup
	static void testSetup(){
		Id dogRecordTypeId = Schema.SObjectType.Pet__c.getRecordTypeInfosByDeveloperName().get(Constants.PET_RT_NAME_DOG).getRecordTypeId();

		Configuration__c endpoint = new Configuration__c (
			Name = 'DogAPIGetImageEndpoint',
			Value__c = 'https://dog.ceo/api/breed/$$$/images/random'
		);
		Configuration__c httpMethod = new Configuration__c (
			Name = 'DogAPIGetImageMethod',
			Value__c = 'GET'
		);
		insert new List<Configuration__c>{endpoint, httpMethod};

		Pet__c testPet1 = new Pet__c(
			Name = 'test pet1 name',
			RecordTypeId = dogRecordTypeId,
			Status__c = Constants.PET_STATUS_CREATED,
			Breed__c = 'Boxer'
		);
		Pet__c testPet2 = new Pet__c(
			Name = 'test pet2 name',
			RecordTypeId = dogRecordTypeId,
			Status__c = Constants.PET_STATUS_CREATED,
			Breed__c = 'Boxer'
		);
		Pet__c testPet3 = new Pet__c(
			Name = 'test pet3 name',
			RecordTypeId = dogRecordTypeId,
			Status__c = Constants.PET_STATUS_CREATED,
			Breed__c = 'Pug'
		);
		Pet__c testPet4 = new Pet__c(
			Name = 'test pet4 name',
			RecordTypeId = dogRecordTypeId,
			Status__c = Constants.PET_STATUS_REGISTERED,
			Breed__c = 'Boxer'
		);
		insert new List<Pet__c>{testPet1, testPet2, testPet3, testPet4};
	}

	@isTest
	public static void testSetDogImageSuccess() {
		Test.setMock(HttpCalloutMock.class, new TestMocks.getImagesSuccess());
		List<Pet__c> createdDogs = [SELECT Id
			FROM Pet__c
			WHERE Status__c = :Constants.PET_STATUS_CREATED];

		Assert.isFalse(createdDogs.isEmpty(), 'There is no dogs in created status');

		Test.startTest();
		Database.executeBatch(new BatchGetDogImage(), 50);
		Test.stopTest();

		List<Pet__c> registeredDogs = [SELECT Id,
			PictureUrl__c,
			Name
			FROM Pet__c
			WHERE Id IN :createdDogs];

		createdDogs = [SELECT Id
			FROM Pet__c
			WHERE Status__c = :Constants.PET_STATUS_CREATED];

		Assert.isTrue(createdDogs.isEmpty(), createdDogs.size() + ' Dogs are still in Created status');
		Assert.isFalse(registeredDogs.isEmpty(), 'No Registered Dogs found');
		for(Pet__c dog : registeredDogs) {
			Assert.isTrue(String.isNotBlank(dog.PictureUrl__c), 'The registered dog ' + dog.Name + ' did not receive an Image');
		}
	}
}