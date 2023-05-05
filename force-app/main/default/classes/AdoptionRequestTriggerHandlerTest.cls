@isTest
public with sharing class AdoptionRequestTriggerHandlerTest {
	@TestSetup
	static void testSetup(){
		insert new Configuration__c (
			Name = 'DisableSetImageInTrigger',
			Value__c = 'true'
		);
	}

	@isTest
	public static void testPetStatusUpdate() {
		Account testAccount = new Account(
			LastName = 'name test'
		);
		insert testAccount;

		Pet__c testPet1 = new Pet__c(
			Name = 'test pet1 name',
			Status__c = Constants.PET_STATUS_REGISTERED
		);
		Pet__c testPet2 = new Pet__c(
			Name = 'test pet2 name',
			Status__c = Constants.PET_STATUS_REGISTERED
		);
		insert new List<Pet__c>{testPet1, testPet2};

		AdoptionRequest__c request1 = new AdoptionRequest__c(
			Account__c = testAccount.Id,
			Pet__c = testPet1.Id,
			Status__c = Constants.REQUEST_STATUS_CREATED
		);
		AdoptionRequest__c request2 = new AdoptionRequest__c(
			Account__c = testAccount.Id,
			Pet__c = testPet2.Id,
			Status__c = Constants.REQUEST_STATUS_APPROVED
		);

		Test.startTest();
		insert new List<AdoptionRequest__c>{request1, request2};
		Test.stopTest();

		Set<Id> petIds = new Set<Id>{testPet1.Id, testPet2.Id};
		List<Pet__c> pets = [SELECT Id,
			Status__c
			FROM Pet__c
			WHERE Id IN :petIds];

		for(Pet__c pet : pets) {
			Assert.areEqual(Constants.PET_STATUS_IN_ADOPTION, pet.Status__c, 'Pet Status__c is not updated correctly');
		}
	}

	@isTest
	public static void testPetStatusUpdateOnUpdate() {
		Account testAccount = new Account(
			LastName = 'name test'
		);
		insert testAccount;

		Pet__c testPet1 = new Pet__c(
			Name = 'test pet1 name',
			Status__c = Constants.PET_STATUS_REGISTERED
		);
		Pet__c testPet2 = new Pet__c(
			Name = 'test pet2 name',
			Status__c = Constants.PET_STATUS_REGISTERED
		);
		insert new List<Pet__c>{testPet1, testPet2};

		AdoptionRequest__c request1 = new AdoptionRequest__c(
			Account__c = testAccount.Id,
			Pet__c = testPet1.Id,
			Status__c = Constants.REQUEST_STATUS_CREATED
		);
		AdoptionRequest__c request2 = new AdoptionRequest__c(
			Account__c = testAccount.Id,
			Pet__c = testPet2.Id,
			Status__c = Constants.REQUEST_STATUS_APPROVED
		);
		insert new List<AdoptionRequest__c>{request1, request2};

		request1.Status__c = Constants.REQUEST_STATUS_ADOPTED;
		request2.Status__c = Constants.REQUEST_STATUS_NOT_ADOPTED;

		Test.startTest();
		update new List<AdoptionRequest__c>{request1, request2};
		Test.stopTest();

		Set<Id> petIds = new Set<Id>{testPet1.Id, testPet2.Id};
		Map<Id, Pet__c> pets = new Map<Id,Pet__c>([SELECT Id,
			Status__c
			FROM Pet__c
			WHERE Id IN :petIds]);

		Assert.areEqual(Constants.PET_STATUS_ADOPTED, pets.get(request1.Pet__c).Status__c, 'Pet1 Status__c is not updated correctly');
		Assert.areEqual(Constants.PET_STATUS_REGISTERED, pets.get(request2.Pet__c).Status__c, 'Pet2 Status__c is not updated correctly');
	}
}