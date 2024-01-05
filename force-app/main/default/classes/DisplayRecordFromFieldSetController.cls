public with sharing class DisplayRecordFromFieldSetController {
	@AuraEnabled(cacheable=true)
	public static Wrapper getRecordData(String stringId, String fieldSetApiName, Boolean conditionalHostSchool) {
		try {
			Id recordId = (Id) stringId;

			User currentUser = UsersService.getCurrentUser();
			if (recordId == null) {
				recordId = currentUser.Contact.J1_Opportunity__c;
			}

			Object record = Fetch.recordFieldSetData(recordId, fieldSetApiName);

			Schema.SObjectType objectType = recordId.getSobjectType();

			Boolean displayRecord = true;

			if (conditionalHostSchool && objectType == Opportunity.sObjectType) {
				Opportunity opportunity = [SELECT Id, Placement_School__c FROM Opportunity WHERE Id = :recordId];
				displayRecord = currentUser.AccountId == opportunity.Placement_School__c ? true : false;
			}

			Schema.FieldSet fieldSet = Fetch.objectFieldSet(objectType, fieldSetApiName);
			List<String> fields = new List<String>();

			if (fieldSet != null) {
				for (Schema.FieldSetMember member : fieldSet.getFields()) {
					fields.add(member.getFieldPath());
				}
			}

			return new Wrapper(
				record,
				fields,
				recordId.getSobjectType().getDescribe().getName(),
				recordId.getSobjectType().getDescribe().getLabel(),
				displayRecord
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
		public List<String> fields;
		@AuraEnabled
		public String objectApiName;
		@AuraEnabled
		public String objectLabel;
		@AuraEnabled
		public Boolean displayRecord;

		public Wrapper(
			Object record,
			List<String> fields,
			String objectApiName,
			String objectLabel,
			Boolean displayRecord
		) {
			this.record = record;
			this.fields = fields;
			this.objectApiName = objectApiName;
			this.objectLabel = objectLabel;
			this.displayRecord = displayRecord;
		}
	}
}