public with sharing class CommunityUtility {
	public static final Map<String, String> TYPE_TO_PUBLIC_GROUP = new Map<String, String>{
		'Teacher' => 'Teach_USA_Teachers',
		'School' => 'Teach_USA_Host_School',
		'Partner' => 'Teach_USA_Partners'
	};

	public static User buildPartnerUser(Contact con, Id accountId, String profileName) {
		// Create a user for the account
		List<Profile> portalProfiles = getPartnerProfileFromName(profileName);

		// Throw an exception if the profile does not return a value
		if (portalProfiles.isEmpty()) {
			throw new CommunityUtilityException(
				'The profile \'' +
					profileName +
					'\' does not exist. ' +
					'Please contact your developer and ask them to review the enablePartnerUser method in the CommunityUtility class to ensure the correct profile is being returned by the query.'
			);
		}

		// Strings for use when creating the user for readability
		String ghUsername = con.Email + '.gh';
		String randomNumberString = String.valueOf((Math.random() * 100)).left(2);
		String firstLetterFirstName = con?.FirstName?.left(1) == null ? '' : con.FirstName.left(1);

		String ghAlias = firstLetterFirstName + con.LastName.left(4) + randomNumberString;

		// Build the user
		User user = new User(
			Username = ghUsername,
			ContactId = con.Id,
			ProfileId = portalProfiles[0].Id,
			Alias = ghAlias,
			Email = con.Email,
			EmailEncodingKey = 'UTF-8',
			LastName = con.LastName,
			CommunityNickname = ghAlias,
			TimeZoneSidKey = 'America/Chicago',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US'
		);
		return User;
	}

	public static String generateRandomPassword() {
		Integer len = 15;
		Blob blobKey = crypto.generateAesKey(256);
		String key = EncodingUtil.convertToHex(blobKey);
		String pwd = key.substring(0, len);

		return pwd;
	}

	public static List<Profile> getPartnerProfileFromName(String profileName) {
		return [
			SELECT Id
			FROM Profile
			WHERE UserType = 'PowerPartner' AND Name = :profileName
			WITH USER_MODE
		];
	}

	@future
	public static void assignToGroup(List<Id> userIds, String userType) {
		//userType should be Teacher, School, or Partner. See Map: TYPE_TO_PUBLIC_GROUP
		List<GroupMember> membersToInsert = new List<GroupMember>();
		if (String.isBlank(userType)) {
			// if userType is null or blank, no action is taken.
			return;
		}

		String groupName = TYPE_TO_PUBLIC_GROUP.get(userType);
		if (groupName != null) {
			Group g = [SELECT Id, Name FROM Group WHERE DeveloperName = :groupName];

			for (Id uId : userIds) {
				GroupMember member = new GroupMember();
				member.GroupId = g.Id;
				member.UserOrGroupId = uId;

				membersToInsert.add(member);
			}

			// insert Group Members
			if (membersToInsert.size() > 0) {
				SObjectHelper.objInsert(membersToInsert);
			}
		} else {
			// if userType passed does not map to anything in the TYPE_TO_PUBLIC_GROUP
			throw new CommunityUtilityException(
				'The userType \'' +
					userType +
					'\' was unexpected. ' +
					'Please contact your developer and ask them to review the assignToGroup method in the CommunityUtility class to ensure a correct userType is being passed from the Trigger.'
			);
		}
	}

	public class CommunityUtilityException extends Exception {
	}
}