@isTest
public with sharing class AdoptionFormControllerTest {
	@TestSetup
	static void testSetup(){
		insert new Configuration__c (
			Name = 'AdoptionFormResultPageSize',
			Value__c = '15'
		);

		Account account = new Account(
			LastName = 'name test'
		);
		insert account;

		insert new Case(
			AccountId = account.Id,
			Status = 'New',
			Origin = 'Web'
		);

		Pet__c testPet1 = new Pet__c(
			Name = 'test pet1 name',
			Breed__c = 'Boxer',
			Location__c = 'Limburg'
		);
		Pet__c testPet2 = new Pet__c(
			Name = 'test pet2 name',
			Breed__c = 'Boxer',
			Location__c = 'Limburg'
		);
		Pet__c testPet3 = new Pet__c(
			Name = 'test pet3 name',
			Breed__c = 'Pug',
			Location__c = 'Limburg'
		);
		Pet__c testPet4 = new Pet__c(
			Name = 'test pet4 name',
			Breed__c = 'Boxer',
			Location__c = 'Zeeland'
		);
		insert new List<Pet__c>{testPet1, testPet2, testPet3, testPet4};
	}

	@isTest
	static void testSearchPetsSuccessBreedLocation() {
		String filter1 = 'Location__c = \'Limburg\'';
		String filter2 = 'Breed__c = \'Boxer\'';

		List<Pet__c> petList = Database.query('SELECT Id ' +
			'FROM Pet__c ' +
			'WHERE ' + filter1 +
			'AND ' + filter2);

		List<String> filters = new List<String>{filter1, filter2};

		Test.startTest();
		List<Pet__c> results = AdoptionFormController.searchPets(filters);
		Test.stopTest();

		Assert.areEqual(petList.size(), results.size(), 'Results are not as many as expected');
	}

	@isTest
	static void testSearchPetsSuccessBreed() {
		String filter = 'Breed__c = \'Boxer\'';

		List<Pet__c> petList = Database.query('SELECT Id ' +
			'FROM Pet__c ' +
			'WHERE ' + filter);

		List<String> filters = new List<String>{filter};

		Test.startTest();
		List<Pet__c> results = AdoptionFormController.searchPets(filters);
		Test.stopTest();

		Assert.areEqual(petList.size(), results.size(), 'Results are not as many as expected');
	}

	@isTest
	static void testSearchPetsSuccessLocation() {
		String filter = 'Location__c = \'Limburg\'';

		List<Pet__c> petList = Database.query('SELECT Id ' +
			'FROM Pet__c ' +
			'WHERE ' + filter);

		List<String> filters = new List<String>{filter};

		Test.startTest();
		List<Pet__c> results = AdoptionFormController.searchPets(filters);
		Test.stopTest();

		Assert.areEqual(petList.size(), results.size(), 'Results are not as many as expected');
	}

	@isTest
	static void testSearchPetsSuccessNoFilters() {
		Configuration__c pageSize = Configuration__c.getValues('AdoptionFormResultPageSize');

		List<Pet__c> petList = Database.query('SELECT Id ' +
			'FROM Pet__c ' +
			'LIMIT' + Integer.valueOf(pageSize.Value__c));

		List<String> filters = new List<String>{};

		Test.startTest();
		List<Pet__c> results = AdoptionFormController.searchPets(filters);
		Test.stopTest();

		Assert.areEqual(petList.size(), results.size(), 'Results are not as many as expected');
	}

	@isTest
	static void testInsertRequestSuccess() {
		Case testCase = [SELECT Id, AccountId FROM Case LIMIT 1];
		Pet__c pet = [SELECT Id FROM Pet__c LIMIT 1];
		AdoptionRequest__c request = new AdoptionRequest__c(
			Account__c = testCase.AccountId,
			Pet__c = pet.Id,
			Case__c = testCase.Id
		);

		Test.startTest();
		AdoptionFormController.insertRequest(request);
		Test.stopTest();

		List<AdoptionRequest__c> requests = [SELECT Id,
			Account__c,
			Pet__c,
			Case__c
			FROM AdoptionRequest__c];

		Assert.isFalse(requests.isEmpty(), 'No Adoption Request record has been created');
		Assert.areEqual(1, requests.size(), 'There is more than a Adoption Request record');
		Assert.areEqual(testCase.AccountId, requests[0].Account__c, 'Account value is not set correctly');
		Assert.areEqual(pet.Id, requests[0].Pet__c, 'Pet value is not set correctly');
		Assert.areEqual(testCase.Id, requests[0].Case__c, 'Case value is not set correctly');
	}

	@isTest
	static void testInsertRequestFail() {
		Boolean exceptionOccurred = false;
		Case testCase = [SELECT Id, AccountId FROM Case LIMIT 1];

		AdoptionRequest__c request = new AdoptionRequest__c(
			Account__c = testCase.AccountId,
			Case__c = testCase.Id
		);

		try {
			Test.startTest();
			AdoptionFormController.insertRequest(request);
			Test.stopTest();
		} catch (AuraHandledException ex) {
			exceptionOccurred = true;
		}

		Assert.isTrue(exceptionOccurred, 'No exception has occured');
	}
}