@isTest
private class DisplayRecordFromFieldSetControllerTest {
	@isTest
	private static void getRecordData_WithRecordId() {
		Account account = (Account) new SObjectBuilder(Account.sObjectType).create().getRecord();

		DisplayRecordFromFieldSetController.Wrapper record;

		Test.startTest();
		record = DisplayRecordFromFieldSetController.getRecordData((String) account.Id, 'TestFieldSet');
		Test.stopTest();

		Assert.isNotNull(record, 'No data was returned');
		Assert.areEqual('Account', record.objectApiName, 'Did not return the correct object api name');
		Assert.areEqual('Account', record.objectLabel, 'Did not return the correct object label');
	}

	@isTest
	private static void getRecordData_WithoutRecordId() {
		Account account = (Account) new SObjectBuilder(Account.sObjectType).create().getRecord();

		Opportunity opportunity = (Opportunity) new SObjectBuilder(Opportunity.sObjectType)
			.put(Opportunity.AccountId, account.Id)
			.create()
			.getRecord();

		Contact contact = (Contact) new SObjectBuilder(Contact.sObjectType)
			.put(Contact.AccountId, account.Id)
			.put(Contact.J1_Opportunity__c, opportunity.Id)
			.create()
			.getRecord();

		User user = (User) new SObjectBuilder(User.sObjectType)
			.put(User.ContactId, contact.Id)
			.put(
				User.ProfileId,
				[
					SELECT Id
					FROM profile
					WHERE UserType = 'PowerPartner'
					LIMIT 1
				][0]
				.Id
			)
			.create()
			.getRecord();

		DisplayRecordFromFieldSetController.Wrapper record;
		Test.startTest();
		System.runAs(user) {
			record = DisplayRecordFromFieldSetController.getRecordData(null, 'TestFieldSet');
		}
		Test.stopTest();

		Assert.isNotNull(record, 'No data was returned');
		Assert.areEqual('Opportunity', record.objectApiName, 'Did not return the correct object api name');
		Assert.areEqual('Opportunity', record.objectLabel, 'Did not return the correct object label');
	}
}