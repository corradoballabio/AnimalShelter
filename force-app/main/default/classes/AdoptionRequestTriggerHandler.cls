public with sharing class AdoptionRequestTriggerHandler {
	private static Set<String> inProgressStatuses = new Set<String>{
		Constants.REQUEST_STATUS_CREATED,
		Constants.REQUEST_STATUS_APPROVED
	};

	public static void setPetStatus(List<AdoptionRequest__c> requests) {
		List<Pet__c> toUpdate = new List<Pet__c>();

		List<AdoptionRequest__c> successfullRequests = Utils.filter(requests, 'Status__c', Constants.REQUEST_STATUS_ADOPTED, true);
		List<AdoptionRequest__c> unsuccessfullRequests = Utils.filter(requests, 'Status__c', Constants.REQUEST_STATUS_NOT_ADOPTED, true);
		List<AdoptionRequest__c> inProgressRequests = Utils.filter(requests, 'Status__c', inProgressStatuses, true);

		List<Case> casesToClose = [SELECT Id
			FROM Case
			WHERE Id IN :Utils.getSet(successfullRequests, 'Case__c')];

		for(AdoptionRequest__c request : successfullRequests) {
			toUpdate.add(new Pet__c(
				Id = request.Pet__c,
				Status__c = Constants.PET_STATUS_ADOPTED));
		}
		for(AdoptionRequest__c request : unsuccessfullRequests) {
			toUpdate.add(new Pet__c(
				Id = request.Pet__c,
				Status__c = Constants.PET_STATUS_REGISTERED));
		}
		for(AdoptionRequest__c request : inProgressRequests) {
			toUpdate.add(new Pet__c(
				Id = request.Pet__c,
				Status__c = Constants.PET_STATUS_IN_ADOPTION));
		}
		for(Case c : casesToClose) {
			c.Status = Constants.CASE_STATUS_CLOSED;
		}

		if(!toUpdate.isEmpty()) update toUpdate;
		if(!casesToClose.isEmpty()) update casesToClose;
	}
}