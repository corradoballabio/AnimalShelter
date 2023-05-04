@isTest
public with sharing class PetTriggerHandlerTest {
	@TestSetup
	static void testSetup(){
		Configuration__c endpoint = new Configuration__c (
			Name = 'DogAPIGetImageEndpoint',
			Value__c = 'https://dog.ceo/api/breed/$$$/images/random'
		);
		Configuration__c httpMethod = new Configuration__c (
			Name = 'DogAPIGetImageMethod',
			Value__c = 'GET'
		);
		insert new List<Configuration__c>{endpoint, httpMethod};
	}

	@isTest
	public static void testGetPictureSuccess() {
		Test.setMock(HttpCalloutMock.class, new TestMocks.getImagesSuccess());
		Pet__c testPet = new Pet__c(
			Name = 'test pet name',
			Status__c = Constants.PET_STATUS_CREATED,
			Breed__c = 'Boxer'
		);

		Test.startTest();
		insert testPet;
		Test.stopTest();

		testPet = [SELECT Id,
			PictureUrl__c,
			Status__c
			FROM Pet__c
			WHERE Id = :testPet.Id];

		Assert.isTrue(String.isNotBlank(testPet.PictureUrl__c), 'Dog Image is still blank');
		Assert.areEqual(testPet.Status__c, Constants.PET_STATUS_REGISTERED, 'Dog Status is not updated');
	}

	@isTest
	public static void testGetPictureFail() {
		Test.setMock(HttpCalloutMock.class, new TestMocks.getImagesFail());
		Pet__c testPet = new Pet__c(
			Name = 'test pet name',
			Status__c = Constants.PET_STATUS_CREATED,
			Breed__c = 'Boxer'
		);

		Test.startTest();
		insert testPet;
		Test.stopTest();

		testPet = [SELECT Id,
			PictureUrl__c,
			Status__c
			FROM Pet__c
			WHERE Id = :testPet.Id];

		Assert.isTrue(String.isBlank(testPet.PictureUrl__c), 'Dog Image is not blank');
		Assert.areEqual(testPet.Status__c, Constants.PET_STATUS_CREATED, 'Dog Status is not still Created');
	}
}