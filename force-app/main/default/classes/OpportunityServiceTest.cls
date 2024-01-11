@isTest
private class OpportunityServiceTest {
	@isTest
	private static void enablePartnerTeacherTest() {
		Id j1RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
			.get('J_1')
			.getRecordTypeId();

		Account acc = (Account) new SObjectBuilder(Account.SObjectType).create().getRecord();

		Contact con = (Contact) new SObjectBuilder(Contact.SObjectType)
			.put(Contact.AccountId, acc.Id)
			.put(Contact.Email, 'TestEmail1@testemail1.com')
			.create()
			.getRecord();

		Test.startTest();
		// Insert an opportunity to initiate the enablePartnerTeacher process.
		// The Opportunity must be inserted to test setting the associated Contact's
		// J1_Opportunity__c value
		Integer existingUserCount = [SELECT COUNT() FROM User];

		Opportunity opp = (Opportunity) new SObjectBuilder(Opportunity.SObjectType)
			.put(Opportunity.AccountId, acc.Id)
			.put(Opportunity.RecordTypeId, j1RecordTypeId)
			.create()
			.getRecord();
		Test.stopTest();

		Integer updatedUserCount = [SELECT COUNT() FROM User];
		Boolean userCreated = updatedUserCount - existingUserCount == 1 ? true : false;
		Assert.isTrue(userCreated, 'Expected a user to be created but was not.');
	}
	@isTest
	private static void enablePartnerTeacherTest_BuildOppOnly() {
		Id j1RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
			.get('J_1')
			.getRecordTypeId();

		Account acc = (Account) new SObjectBuilder(Account.SObjectType).create().getRecord();

		Contact con = (Contact) new SObjectBuilder(Contact.SObjectType)
			.put(Contact.AccountId, acc.Id)
			.put(Contact.Email, 'TestEmail2@testemail2.com')
			.create()
			.getRecord();

		// Insert an opportunity to initiate the enablePartnerTeacher process.
		// The Opportunity must be inserted to test setting the associated Contact's
		// J1_Opportunity__c value
		Opportunity opp = (Opportunity) new SObjectBuilder(Opportunity.SObjectType)
			.put(Opportunity.AccountId, acc.Id)
			.put(Opportunity.RecordTypeId, j1RecordTypeId)
			.build()
			.getRecord();

		Integer existingUserCount = [SELECT COUNT() FROM User];
		Test.startTest();
		OpportunityService.enablePartnerTeacher(new List<Opportunity>{ opp });
		Test.stopTest();
		Integer updatedUserCount = [SELECT COUNT() FROM User];
		Boolean userCreated = updatedUserCount - existingUserCount == 1 ? true : false;
		Assert.isTrue(userCreated, 'Expected a user to be created but was not.');
	}
	@isTest
	private static void enablePartnerTeacherTest_NoContact() {
		Id j1RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
			.get('J_1')
			.getRecordTypeId();

		Account acc = (Account) new SObjectBuilder(Account.SObjectType).create().getRecord();

		// Insert an opportunity to initiate the enablePartnerTeacher process.
		// The Opportunity must be inserted to test setting the associated Contact's
		// J1_Opportunity__c value
		Opportunity opp = (Opportunity) new SObjectBuilder(Opportunity.SObjectType)
			.put(Opportunity.AccountId, acc.Id)
			.put(Opportunity.RecordTypeId, j1RecordTypeId)
			.build()
			.getRecord();

		Test.startTest();
		OpportunityService.enablePartnerTeacher(new List<Opportunity>{ opp });
		Test.stopTest();
	}
	@isTest
	private static void createInvoiceNumberTest() {
		Payment__c payment = (Payment__c) new SObjectBuilder(Payment__c.SObjectType)
			.put(Payment__c.Name, 'Test')
			.put(Payment__c.Invoice_Number__c, 'PF123-123-123')
			.create()
			.getRecord();

		Test.startTest();
		OpportunityService.createInvoiceNumber();
		Test.stopTest();

		// ASSERTIONS
	}
}