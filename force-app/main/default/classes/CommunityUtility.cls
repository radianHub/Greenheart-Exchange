public with sharing class CommunityUtility {
	public static User buildPartnerUser(Contact con, Id accountId, String profileName) {
		// Create a user for the account
		List<Profile> portalProfiles = getPartnerProfileFromName(profileName);

		// Throw an exception if the profile does not return a value
		if (portalProfiles.isEmpty()) {
			throw new CommunityUtilityException(
				'The profile \'' +
					profileName +
					'\' does not exist. ' +
					'Please contact your developer and ask them to review the enablePartnerUser class in the CommunityUtility class to ensure the correct profile is being returned by the query.'
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

	public class CommunityUtilityException extends Exception {
	}
}