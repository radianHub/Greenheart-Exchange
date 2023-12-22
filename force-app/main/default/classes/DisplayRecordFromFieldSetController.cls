public with sharing class DisplayRecordFromFieldSetController {
	@AuraEnabled(cacheable=true)
	public static Wrapper getRecordData(String stringId, String fieldSetApiName) {
		try {
			Id recordId = (Id) stringId;

			if (recordId == null) {
				User currentUser = UsersService.getCurrentUserAccountContactOpportunity();
				recordId = currentUser.Contact.J1_Opportunity__c;
			}

			Object record = Fetch.recordFieldSetData(recordId, fieldSetApiName);

			return new Wrapper(
				record,
				recordId.getSobjectType().getDescribe().getName(),
				recordId.getSobjectType().getDescribe().getLabel()
			);
		} catch (Exception e) {
			System.debug('EXCEPTION: ' + e.getMessage() + ' at ' + e.getStackTraceString());
			throw new AuraHandledException(e.getMessage());
		}
	}

	public class Wrapper {
		@AuraEnabled
		public Object record;
		@AuraEnabled
		public String objectApiName;
		@AuraEnabled
		public String objectLabel;

		public Wrapper(Object record, String objectApiName, String objectLabel) {
			this.record = record;
			this.objectApiName = objectApiName;
			this.objectLabel = objectLabel;
		}
	}
}