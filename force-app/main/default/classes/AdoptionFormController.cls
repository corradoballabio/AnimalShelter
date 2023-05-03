public with sharing class AdoptionFormController {
	@AuraEnabled
	public static List<Pet__c> searchPets(List<String> filters){
		Configuration__c pageSize = Configuration__c.getValues('AdoptionFormResultPageSize');
		String query = 'SELECT Id,' +
			'Name, ' +
			'PictureUrl__c, ' +
			'Location__c ' +
			'FROM Pet__c ';

		if(!filters.isEmpty()) {query += 'WHERE ' + String.join(filters, ' AND ');}
		query += ' LIMIT ' + Integer.valueOf(pageSize.Value__c);

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