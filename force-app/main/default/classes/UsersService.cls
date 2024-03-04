public with sharing class UsersService {
	// Get user's Account, Contact, & J-1 Opportunity
	@AuraEnabled(cacheable=true)
	public static User getCurrentUser() {
		return [
			SELECT Id, AccountId, ContactId, Contact.AccountId, Contact.J1_Opportunity__c
			FROM User
			WHERE Id = :UserInfo.getUserId()
			WITH SECURITY_ENFORCED
		];
	}
}