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

	@isTest
	private static void verifyGroupNamesExist() {
		Map<String, String> groupMap = CommunityUtility.TYPE_TO_PUBLIC_GROUP;
		List<String> publicGroupNames = new List<String>();
		for (String groupName : groupMap.values()) {
			publicGroupNames.add(groupName);
		}

		if (publicGroupNames != null || publicGroupNames.size() > 0) {
			List<Group> publicGroups = [
				SELECT Id, Name, DeveloperName
				FROM Group
				WHERE DeveloperName IN :publicGroupNames
			];
			Assert.areEqual(
				publicGroupNames.size(),
				publicGroups.size(),
				'Unable to find all listed Public Groups: ' + publicGroupNames
			);
		} else {
			Assert.fail('Error getting Public Group Map from Community Utility');
		}
	}

	@IsTest
	private static void buildGroupMember() {
		Account acc = (Account) new SObjectBuilder(Account.SObjectType).create().getRecord();

		Contact con = (Contact) new SObjectBuilder(Contact.SObjectType)
			.put(Contact.AccountId, acc.Id)
			.put(Contact.Email, 'test' + Math.random() + '@buildGroupMember.com')
			.create()
			.getRecord();

		User user = CommunityUtility.buildPartnerUser(con, acc.Id, 'Greenheart Teacher Community User');
		insert user;

		Integer existingGroupsCount = [SELECT COUNT() FROM GroupMember WHERE UserOrGroupId = :user.Id];

		Test.startTest();
		CommunityUtility.assignToGroup(new List<Id>{ user.Id }, 'Teacher');
		Test.stopTest();

		Integer currentGroupsCount = [SELECT COUNT() FROM GroupMember WHERE UserOrGroupId = :user.Id];
		Assert.areEqual(existingGroupsCount + 1, currentGroupsCount, 'User was not added to Public Group as expected');
	}
}