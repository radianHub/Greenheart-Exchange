// RadianHub - Developer p.hart
// Apex class for a LWC based universal application dependent on  custom metadata and object field sets

public without sharing class UniversalApp {
	public final static String NOT_FOUND = 'Application \'DeveloperName\' not found in Custom Metadata.';
	public final static String NO_SECTION = 'Application sections were not found in Custom Metadata.';
	public final static String NO_FIELDSETS = 'Field sets were not found for object: {0}.';
	public final static String NULL_FIELDSETS = 'The field set(s) were not found for the following Universal App Sections: {0}.';
	public final static String NULL_FIELDSET = 'The field set {0} was not found on {1}.';

	public static Universal_App__mdt[] apps;
	public static Universal_App_Section__mdt[] sects;

	// Method   - queryApps
	// Descr.   - Segregated (for testing) mdt query which updates the class static variable "apps"
	// Input    - String DeveloperName of CustomMetadata 'Universal App'
	private static void queryApps(String appDevName) {
		apps = [
			SELECT
				Id,
				CSS__c,
				DeveloperName,
				Logo_URL__c,
				MasterLabel,
				Object__c,
				Post_Submit_Fields__c,
				Page_Redirect__c,
				Object_with_Boolean__c,
				Boolean_Field__c,
				Page_Redirect_if_True__c,
				Page_Redirect_if_False__c,
				ParentOppField__c,
				ParentAcctField__c,
				vfPageRedirect__c
			FROM Universal_App__mdt
			WHERE DeveloperName = :appDevName
		];
	}

	// Method   - querySects
	// Descr.   - Segregated (for testing) mdt query which updates the class static variable "sects"
	// Input    - Id of 'Universal App'
	private static void querySects(String appId) {
		sects = [
			SELECT
				Id,
				DeveloperName,
				MasterLabel,
				Order__c,
				Page__c,
				Section_Body__c,
				Section_Field_Set__c,
				Section_Field_Columns__c,
				Section_Field_Flow__c,
				Section_Header__c,
				conditionalRequire__c,
				conditionalRender__c,
				DisplayByDefault__c,
				AddChildButtonLabel__c,
				ChildFieldSet__c,
				ChildObject__c,
				ChildObjectRecordLimit__c,
				ChildTableTitle__c,
				ParentField__c,
				isEnableChildRecords__c
			FROM Universal_App_Section__mdt
			WHERE Universal_App__c = :appId
		];
	}

	/**
	 * @description : QUERIES FOR A LIST OF FIELD SETTINGS TO BE USED AS ALTERNATIVE LABELS.
	 * @author Zachary Csotya | 08/31/2023
	 * @return List<Universal_App_Field_Setting__mdt>
	 **/
	private static List<Universal_App_Field_Setting__mdt> queryFieldSettings() {
		return [
			SELECT
				Id,
				DeveloperName,
				MasterLabel,
				Expected_Field_Label__c,
				Field_Name__c,
				Universal_App_Section__c,
				Type__c,
				Accepted_File_Types__c,
				DocumentType__c
			FROM Universal_App_Field_Setting__mdt
		];
	}

	/**
	 * @description : Query all fields in a sObject and return the results.
	 * @author Zachary Csotya | 06/28/2022
	 * @param Id rId
	 * @param String objName
	 * @return sObject
	 **/
	public static sObject queryRecord(Id rId, String objName) {
		Map<String, Schema.SObjectField> fields = ((SObject) Type.forName('Schema', objName)?.newInstance())
			?.getSObjectType()
			?.getDescribe()
			?.fields
			?.getMap();

		String expr = ' ';
		SObject obj = null;
		for (Integer i = 0; i < fields.values().size() - 1; i++) {
			expr += fields.values()[i] + ', ';
		}
		expr += fields.values()[fields.values().size() - 1];
		String qry = 'SELECT' + expr + ' FROM ' + objName + ' WHERE Id = ' + '\'' + rId + '\'';
		obj = Database.query(qry);

		return obj;
	}

	/**
	 * @description : Query all fields in a sObject and return the results.
	 * @author Zachary Csotya | 08/02/2022
	 * @param String fieldName
	 * @param String objName
	 * @param String recordId
	 * @return sObject
	 **/
	@AuraEnabled
	public static sObject queryForBoolean(String fieldName, String objName, String recordId) {
		List<SObject> obj = null;
		String qry = 'SELECT ' + fieldName + ' FROM ' + objName + ' WHERE Id = ' + '\'' + recordId + '\'';
		system.debug(qry);
		obj = Database.query(qry);
		system.debug('Queried Records ' + obj.size());

		if (obj.size() == 1) {
			return obj[0];
		} else {
			return null;
		}
	}

	// Method   - retrieveApp
	// Descr.   - Aura enabled (LWC c-univ-app) method for returning map of Universal Application and field sets
	// Input    - String DeveloperName of CustomMetadata 'Universal App'
	// Output   - Map<String, Object> {'data' -> [{api -> fieldAPI__c, options...}, ...], 'error' -> 'String'}
	@AuraEnabled(cacheable=true)
	public static Map<String, Object> retrieveApp(String appDevName, Id recordId) {
		Map<String, Object> ret = new Map<String, Object>();

		try {
			// Query for application, prepopulate in testing
			if (apps == null) {
				queryApps(appDevName);
			}

			if (apps == null || apps.size() != 1) {
				ret.put('error', NOT_FOUND);
			} else {
				Universal_App__mdt application = apps[0];

				// Query for sections, prepopulate in testing
				if (sects == null) {
					querySects(application.Id);
				}

				if (sects == null || sects.size() == 0) {
					ret.put('error', NO_SECTION);
				} else {
					Map<String, List<Object>> fieldsetmap = new Map<String, List<Object>>();

					Map<String, Schema.FieldSet> objectFieldSetMap = ((SObject) Type.forName(
								'Schema',
								application.Object__c
							)
							?.newInstance())
						?.getSObjectType()
						?.getDescribe()
						?.fieldSets
						?.getMap();

					if (objectFieldSetMap == null) {
						ret.put('error', String.format(NO_FIELDSETS, new List<Object>{ application.Object__c }));
					} else {
						Map<String, Set<String>> mapfieldset = new Map<String, Set<String>>();
						// Map<String, Map<String, String>> mapFieldSetting = new Map<String, Map<String, String>>();
						Map<String, Map<String, Universal_App_Field_Setting__mdt>> mapFieldSetting = new Map<String, Map<String, Universal_App_Field_Setting__mdt>>();

						for (Universal_App_Section__mdt section : sects) {
							String sectionFieldSet = section.Section_Field_Set__c;
							if (String.isNotBlank(sectionFieldSet)) {
								for (Universal_App_Field_Setting__mdt fieldSetting : queryFieldSettings()) {
									if (fieldSetting.Universal_App_Section__c == section.Id) {
										if (mapFieldSetting.containsKey(sectionFieldSet)) {
											if (
												!mapFieldSetting.get(sectionFieldSet)
													.containsKey(fieldSetting.Field_Name__c)
											) {
												mapFieldSetting.get(sectionFieldSet)
													.put(
														fieldSetting.Field_Name__c,
														// fieldSetting.Expected_Field_Label__c
														fieldSetting
													);
											}
										} else {
											mapFieldSetting.put(
												sectionFieldSet,
												new Map<String, Universal_App_Field_Setting__mdt>{
													// fieldSetting.Field_Name__c => fieldSetting.Expected_Field_Label__c
													fieldSetting.Field_Name__c => fieldSetting
												}
											);
										}
									}
								}

								if (mapfieldset.containsKey(sectionFieldSet)) {
									mapfieldset.get(sectionFieldSet).add(section.DeveloperName);
								} else {
									mapfieldset.put(sectionFieldSet, new Set<String>{ section.DeveloperName });
								}
							}
						}

						Set<String> nullFieldSets = new Set<String>();
						sObject fieldValues = null;

						if (recordId != null) {
							fieldValues = queryRecord(recordId, application.Object__c);
							System.debug(fieldValues);
						}

						for (String fieldSet : mapfieldset.keySet()) {
							Schema.FieldSet objFieldSet = objectFieldSetMap.get(fieldSet);
							if (objFieldSet != null) {
								List<Schema.FieldSetMember> fields = objFieldSet.getFields();
								List<Object> fieldMembers = new List<Object>();
								for (Schema.FieldSetMember member : fields) {
									String altLabel;
									Boolean hasAltLabel = false;
									Boolean isFile = false;
									String acceptedFileTypes = '';
									String documentType = '';

									if (mapFieldSetting?.containsKey(fieldSet)) {
										if (mapFieldSetting.get(fieldSet)?.containsKey(member.getFieldPath())) {
											Universal_App_Field_Setting__mdt fieldSetting = mapFieldSetting.get(
													fieldSet
												)
												.get(member.getFieldPath());

											hasAltLabel = true;
											altLabel = fieldSetting.Expected_Field_Label__c;
											isFile = fieldSetting.Type__c == 'File' ? true : false;
											acceptedFileTypes = fieldsetting.Accepted_File_Types__c;
											documentType = fieldsetting.DocumentType__c;
										}
									}

									Map<String, Object> fieldMember = new Map<String, Object>{
										'api' => member.getFieldPath(),
										'req' => (member.getDBRequired() || member.getRequired()),
										'label' => member.getLabel(),
										'type' => member.getType().name(),
										'hasAltLabel' => hasAltLabel,
										'altLabel' => altLabel,
										'isBool' => member.getType().name() == 'BOOLEAN' ? true : false,
										'isFile' => isFile,
										'acceptedFileTypes' => acceptedFileTypes,
										'documentType' => documentType
									};

									if (recordId != null) {
										fieldMember.put('value', fieldValues.get(member.getFieldPath()));
									}
									fieldMembers.add(fieldMember);
								}
								fieldsetmap.put(fieldSet, fieldMembers);
							} else {
								nullFieldSets.addAll(new List<String>(mapfieldset.get(fieldSet)));
							}
						}
						system.debug(fieldsetmap);

						if (nullFieldSets.size() > 0) {
							ret.put('error', String.format(NULL_FIELDSETS, new List<Object>{ nullFieldSets }));
						}

						ret.put(
							'data',
							new Map<String, Object>{
								'application' => application,
								'sections' => sects,
								'fieldsetmap' => fieldsetmap
							}
						);
					}
				}
			}
		} catch (Exception e) {
			ret.put('error', e.getTypeName() + ' | ' + e.getMessage() + ' | ' + e.getStackTraceString());
		}

		return ret;
	}

	@AuraEnabled
	public static Map<String, Object> submitApp(SObject sObj, String application, String filesString) {
		Map<String, Object> ret = new Map<String, Object>();

		System.debug('filesString ' + filesString);

		try {
			/*switch on application {
				when 'Registration' {
					Contact newCommunityMember = (Contact) sObj;

					List<Contact> existingCommunityMember = [
						SELECT Id
						FROM Contact
						WHERE Email = :newCommunityMember.Email
					];

					if (existingCommunityMember.size() > 0) {
						throw new AuraHandledException('A a community member already exists under this email address');
					}

					upsert newCommunityMember;
					ret.put('data', newCommunityMember.Id);

					sObj = newCommunityMember;
				}
				when 'Grant_Application' {
					Opportunity newGrantApplication = (Opportunity) sObj;

					List<Contact> existingCommunityMember = [
						SELECT Id, Email, AccountId
						FROM Contact
						WHERE Email = :newGrantApplication.Email_Address__c
					];

					if (existingCommunityMember.size() == 0) {
						throw new CustomException('No community member has been registered with this email address');
					}

					newGrantApplication.AccountId = existingCommunityMember[0].AccountId;
					newGrantApplication.StageName = 'Application Received';
					newGrantApplication.CloseDate = Date.today();
					newGrantApplication.Community_Member__c = existingCommunityMember[0].Id;

					upsert newGrantApplication;
					ret.put('data', newGrantApplication.Id);

					sObj = newGrantApplication;
				}
				when else {*/
			upsert sObj;
			ret.put('data', sObj.Id);
			//	}
			//}

			if (filesString != null) {
				List<fileWrapper> filesList = (List<fileWrapper>) JSON.deserialize(
					filesString,
					List<fileWrapper>.class
				);

				List<fileWrapper> files = new List<fileWrapper>();
				for (fileWrapper file : filesList) {
					fileWrapper newFile = new fileWrapper();
					newFile.base64 = file.base64;
					newFile.fileName = file.fileName;
					newFile.documentType = file.documentType;
					files.add(newFile);
				}
				//uploadFiles(files, sObj);
				uploadDocAndFile(files, sObj);
			}
		} catch (CustomException customException) {
			ret.put('error', customException.getMessage());
		} catch (Exception e) {
			ret.put('error', e.getTypeName() + ' | ' + e.getMessage() + ' | ' + e.getStackTraceString());
		}

		return ret;
	}

	/*public static void uploadFiles(List<File> files, SObject sObj) {
		List<ContentVersion> contentVersionsToInsert = new List<ContentVersion>();
		List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();

		for (File file : files) {
			ContentVersion cv = createContentVersion(file.base64, file.filename);
			contentVersionsToInsert.add(cv);
		}
		insert contentVersionsToInsert;

		for (ContentVersion contVersion : contentVersionsToInsert) {
			ContentDocumentLink cdl = createContentLink(contVersion.Id, sObj.Id);
			contentDocumentLinksToInsert.add(cdl);
		}
		insert contentDocumentLinksToInsert;
	}*/

	// alt for uploadFiles where using the Document__c layer between parent record and file
	public static void uploadDocAndFile(List<fileWrapper> files, SObject sObj) {
		List<ContentVersion> cvToInsert = new List<ContentVersion>();
		List<ContentDocumentLink> cdLinksToInsert = new List<ContentDocumentLink>();
		List<Document__c> docsToInsert = new List<Document__c>();

		for (fileWrapper file : files) {
			ContentVersion cv = createContentVersion(file.base64, file.fileName);
			cvToInsert.add(cv);

			Document__c doc = createDocument(file.fileName, file.documentType, sObj);
			docsToInsert.add(doc);
		}
		insert cvToInsert;
		insert docsToInsert;

		for (Integer i = 0; i < files.size(); i++) {
			ContentDocumentLink cdl = createContentLink(cvToInsert[i].Id, docsToInsert[i].Id);
			cdLinksToInsert.add(cdl);
		}
		insert cdLinksToInsert;
	}

	private static ContentVersion createContentVersion(String base64, String filename) {
		ContentVersion cv = new ContentVersion();
		cv.VersionData = EncodingUtil.base64Decode(base64);
		cv.Title = filename;
		cv.PathOnClient = filename;
		return cv;
	}

	private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
		if (contentVersionId == null || recordId == null) {
			return null;
		}
		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = [
			SELECT ContentDocumentId
			FROM ContentVersion
			WHERE Id = :contentVersionId
		]
		.ContentDocumentId;

		cdl.LinkedEntityId = recordId;
		cdl.ShareType = 'V';
		return cdl;
	}

	private static Document__c createDocument(String fileName, String fileType, SObject sObj) {
		if (fileName == null) {
			return null;
		}
		Document__c doc = new Document__c();
		doc.Name = fileName;
		doc.Type__c = fileType;

		String objType = sObj.getSObjectType().getDescribe().getName();

		switch on objType {
			when 'Opportunity' {
				doc.Opportunity__c = sObj.Id;
			}
			when 'Account' {
				doc.Account__c = sObj.Id;
			}
			when 'Contact' {
				Contact c = (Contact) sObj;
				doc.Account__c = c.AccountId;
				doc.Contact__c = c.Id;
			}
			when 'Cross_Cultural_Activity__c' {
				Cross_Cultural_Activity__c cca = (Cross_Cultural_Activity__c) sObj;
				doc.Opportunity__c = cca.Opportunity_Name__c;
				doc.CrossCulturalActivity__c = cca.Id;
			}
		}

		return doc;
	}

	public class File {
		public String filename;
		public string base64;
	}

	public class CustomException extends Exception {
	}

	@AuraEnabled
	public static void submitChildObjects(List<childRecordsWrapper> childObjs, Id parentId) {
		try {
			List<SObject> records = new List<SObject>();
			for (childRecordsWrapper wrapper : childObjs) {
				for (SObject record : wrapper.records) {
					record.put(wrapper.parentField, parentId);
				}
				records.addAll(wrapper.records);
			}
			insert records;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Map<String, Object> getChildObjectFields(String ObjectName, String FieldSetName) {
		Map<String, Object> ret = new Map<String, Object>();

		Map<String, List<Object>> fieldsetmap = new Map<String, List<Object>>();

		Schema.FieldSet objFieldSet = ((SObject) Type.forName('Schema', ObjectName)?.newInstance())
			?.getSObjectType()
			?.getDescribe()
			?.fieldSets
			?.getMap()
			?.get(FieldSetName);

		if (objFieldSet == null) {
			ret.put('error', String.format(NULL_FIELDSET, new List<Object>{ FieldSetName, ObjectName }));
		} else {
			Map<String, Set<String>> mapfieldset = new Map<String, Set<String>>();
			Map<String, Map<String, String>> mapFieldSetting = new Map<String, Map<String, String>>();

			Set<String> nullFieldSets = new Set<String>();
			sObject fieldValues = null;

			List<Schema.FieldSetMember> fields = objFieldSet.getFields();
			List<Object> fieldMembers = new List<Object>();
			for (Schema.FieldSetMember member : fields) {
				String altLabel;
				Boolean hasAltLabel = false;

				if (mapFieldSetting?.containsKey(FieldSetName)) {
					if (mapFieldSetting.get(FieldSetName)?.containsKey(member.getFieldPath())) {
						hasAltLabel = true;
						altLabel = mapFieldSetting.get(FieldSetName).get(member.getFieldPath());
					}
				}

				Map<String, Object> fieldMember = new Map<String, Object>{
					'api' => member.getFieldPath(),
					'req' => (member.getDBRequired() || member.getRequired()),
					'label' => member.getLabel(),
					'type' => member.getType().name(),
					'hasAltLabel' => hasAltLabel,
					'altLabel' => altLabel
				};

				fieldMembers.add(fieldMember);
			}

			ret.put('fielddata', fieldMembers);
			System.debug(ret);
		}

		return ret;
	}

	public class childRecordsWrapper {
		@AuraEnabled
		public String objectName { get; set; }
		@AuraEnabled
		public String parentField { get; set; }
		@AuraEnabled
		public List<SObject> records { get; set; }
	}

	public class fileWrapper {
		@AuraEnabled
		public String base64 { get; set; }
		@AuraEnabled
		public String fileName { get; set; }
		@AuraEnabled
		public String fileType { get; set; }
		@AuraEnabled
		public String documentType { get; set; }
	}
}