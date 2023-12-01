@isTest
private without sharing class DocumentsServiceTest {    
    @isTest 
    private static void getDocumentRecordByIdPositive(){
        // Get picklist values for the Document__c object's "Type__c" field
        Schema.DescribeFieldResult documentType = Document__c.Type__c.getDescribe();

        List<Schema.PicklistEntry> documentTypePicklistValues = documentType.getPicklistValues();
        String firstPicklistValue = documentTypePicklistValues[0].getValue();
        // Insert a Document__c record
        Document__c doc = (Document__c) new SObjectBuilder(Document__c.SobjectType)
        .put(Document__c.Type__c, firstPicklistValue)
        .create()
        .getRecord();  
        
        Test.startTest();
        Document__c document = DocumentsService.getDocumentRecordById(doc.Id);
        Test.stopTest();


        Id expectedId = doc.Id;
        Id actualId = document.Id;
        Assert.areEqual(expectedId, actualId, 'Expected Id ' + expectedId + ' but found ' + actualId);
    }
    @isTest 
    private static void getDocumentRecordByIdNegative(){
        // Insert a Document__c record
        Document__c doc = (Document__c) new SObjectBuilder(Document__c.SobjectType)
        .build()
        .provideDummyIds()
        .getRecord();
        
        Test.startTest();
        Document__c document = DocumentsService.getDocumentRecordById(doc.Id);
        Test.stopTest();


        Id expectedId = null;
        Id actualId = document?.Id;
        Assert.areEqual(expectedId, actualId, 'Expected null ' + ' but found ' + actualId);
    }
}