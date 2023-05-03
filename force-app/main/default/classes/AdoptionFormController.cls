public with sharing class AdoptionFormController {
	@AuraEnabled
	public static List<Pet__c> searchPets(List<String> filters){

		String query = 'SELECT Id,' +
			'Name, ' +
			'PictureUrl__c, ' +
			'Country__c ' +
			'FROM Pet__c ';

		if(!filters.isEmpty()) {query += 'WHERE ' + String.join(filters, ' AND ');}

		query += ' LIMIT 15';
		try {
			return Database.query(query);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static String insertRequest(SObject record){
		try {
			insert (AdoptionRequest__c) record;
			return record.Id;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
}