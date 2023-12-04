@isTest
public without sharing class FilesUploadControllerTest {
   @isTest
   private static void deleteContentDocumentAndDocumentPositive(){
    // Insert  ContentVersion
    ContentVersion cv = (ContentVersion) new SObjectBuilder(ContentVersion.SObjectType)
    .create()
    .getRecord();

    // Get picklist values for the Document__c object's "Type__c" field
    Schema.DescribeFieldResult documentType = Document__c.Type__c.getDescribe();

    List<Schema.PicklistEntry> documentTypePicklistValues = documentType.getPicklistValues();
    String firstPicklistValue = documentTypePicklistValues[0].getValue();

    // Insert a Document__c record
    Document__c doc = (Document__c) new SObjectBuilder(Document__c.SobjectType)
    .put(Document__c.Type__c, firstPicklistValue)
    .create()
    .getRecord(); 

    ContentVersion queriedCv = getContentVersion(cv.Id);

    Id contentDocumentId = queriedCv.ContentDocumentId;

    Test.startTest();
    FilesUploadController.deleteContentDocumentAndDocument(contentDocumentId, doc.Id);
    Test.stopTest();

    // ASSERTION(S)
    // 1. Ensure the ContentDocument record was deleted
    List<ContentDocument> cds = [SELECT Id FROM ContentDocument];
    Assert.areEqual(0, cds.size(), 'Expected list to be empty but was not');
    // 2. Ensure the Document__c record was deleted
    List<Document__c> docs = [SELECT Id FROM Document__c];
    Assert.areEqual(0, docs.size(), 'Expected list to be empty but was not');
   }

   // * HELPERS
   private static ContentVersion getContentVersion(Id contentVersionId){
    return [SELECT Id,
                   ContentDocumentId
              FROM ContentVersion
             WHERE Id = : contentVersionId];
   }
}