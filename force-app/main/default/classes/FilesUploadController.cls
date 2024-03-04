// * CONTROLLER FOR THE filesUpload LWC
public with sharing class FilesUploadController {
    @AuraEnabled
    public static void deleteContentDocumentAndDocument(String contentDocumentId, string documentId){
        try {
            // Query for contentDocumentId using abstracted logic from service class
            ContentDocument contentDocumentToDelete = ContentDocumentsService.getContentDocumentRecordById(contentDocumentId);
            // Delete the ContentDocument record
            deleteContentDocument(contentDocumentToDelete);
            // Query for the Document__c record from service class
            Document__c documentToDelete = DocumentsService.getDocumentRecordById(documentId);
            // Delete the Document__c record
            deleteDocument(documentToDelete);
        } catch (Exception e) {
            System.debug('EXCEPTION ' + e.getMessage() + ' @ ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }


    // * HELPERS
    private static void deleteContentDocument(ContentDocument contentDocumentToDelete){
        // Delete (IF returned list not null)
        if(contentDocumentToDelete != null && SObjectHelper.isObjectDeletable('ContentDocument')) {
            delete contentDocumentToDelete;
        // If the object is present but not deletable, throw an error message    
        } 
    }
    private static void deleteDocument(Document__c documentToDelete){
        // Delete (IF returned list not null)
        if(documentToDelete != null && SObjectHelper.isObjectDeletable('Document__c')) {
            delete documentToDelete;
        } 
    }
}