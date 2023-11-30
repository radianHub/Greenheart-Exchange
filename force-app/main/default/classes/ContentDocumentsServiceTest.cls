@isTest
private without sharing class ContentDocumentsServiceTest {
    @isTest
    // Test purpose: retrieve the contentDocumentRecord, passing in an Id (use dummy Id?)
    // Expected outcome: the returned Content Document record is the same as the created Content Document record
    private static void getContentDocumentRecordByIdPositive(){
        // Create ContentVersion
        ContentVersion cv = (ContentVersion) new SObjectBuilder(ContentVersion.SObjectType)
        .create()
        .getRecord();

        ContentVersion queriedCv = getContentVersion(cv.Id);

        Test.startTest();
        ContentDocument queriedCd = ContentDocumentsService.getContentDocumentRecordById(queriedCv.ContentDocumentId);
        Test.stopTest();
        Assert.areEqual(queriedCv.ContentDocumentId, queriedCd.Id, 'Method did not return expected Id.');
    }
    @isTest
    // Test purpose: retrieve the contentDocumentRecord, passing in an Id (use dummy Id?)
    // Expected outcome: the returned Content Document record is the same as the created Content Document record
    private static void getContentDocumentRecordByIdNegative(){
        // Create ContentVersion
        ContentVersion cv = (ContentVersion) new SObjectBuilder(ContentVersion.SObjectType)
        .build()
        .provideDummyIds()
        .getRecord();

        Test.startTest();
        ContentDocument queriedCd = ContentDocumentsService.getContentDocumentRecordById(cv.Id);
        Test.stopTest();
        
        Assert.areEqual(null, queriedCd, 'Expected null but returned a value.');
    }
    

    // * HELPERS
    static Integer NUM = 1;

   private static String getFakeId(Schema.SObjectType sot)
   {
      String result = String.valueOf(NUM++);
      return sot.getDescribe().getKeyPrefix() + 
         '0'.repeat(12-result.length()) + result;
   }
   private static ContentVersion getContentVersion(Id contentVersionId){
    return [SELECT Id,
                   ContentDocumentId
              FROM ContentVersion
             WHERE Id = : contentVersionId];
   }
}