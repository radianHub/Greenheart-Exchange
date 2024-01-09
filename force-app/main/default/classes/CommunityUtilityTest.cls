@isTest
private class CommunityUtilityTest {
	@isTest
	private static void generateRandomPasswordTest() {
		Test.startTest();
		String pass = CommunityUtility.generateRandomPassword();
		Integer passLength = pass.length();
		Test.stopTest();
		Assert.areEqual(15, passLength, 'Expected a 15 character password but was ' + passLength + ' characters.');
	}

	@isTest
	private static void buildPartnerUser() {
		Account acc = (Account) new SObjectBuilder(Account.SObjectType).create().getRecord();

		Contact con = (Contact) new SObjectBuilder(Contact.SObjectType)
			.put(Contact.AccountId, acc.Id)
			.create()
			.getRecord();

		Test.startTest();
		User partnerUser = CommunityUtility.buildPartnerUser(con, acc.Id, 'Greenheart Teacher Community User');
		Test.stopTest();

		Assert.isNotNull(partnerUser, 'Expected a partner user to be created but was not.');
	}
	@isTest
	private static void buildPartnerUser_NullProfile() {
		Account acc = (Account) new SObjectBuilder(Account.SObjectType).create().getRecord();

		Contact con = (Contact) new SObjectBuilder(Contact.SObjectType)
			.put(Contact.AccountId, acc.Id)
			.create()
			.getRecord();

		Test.startTest();
		try {
			User partnerUser = CommunityUtility.buildPartnerUser(con, acc.Id, '');
		} catch (Exception e) {
			String exceptionMessageType = e.getTypeName();
			Boolean isCorrectType = exceptionMessageType == 'CommunityUtility.CommunityUtilityException' ? true : false;

			Assert.isTrue(
				isCorrectType,
				'Expected exception to be type CommunityUtility.CommunityUtilityException but was ' +
				exceptionMessageType
			);
		}

		Test.stopTest();
	}
}