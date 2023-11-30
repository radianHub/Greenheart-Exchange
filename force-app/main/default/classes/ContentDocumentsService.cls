public with sharing class ContentDocumentsService {
   // Query for a single document record by passing in an Id
   public static ContentDocument getContentDocumentRecordById(String contentDocumentId){
    try {
        List<ContentDocument> contentDocuments = [SELECT Id 
                                                    FROM ContentDocument
                                                   WHERE Id = : contentDocumentId
                                                    WITH SECURITY_ENFORCED
                                                   LIMIT 1];
        if(!contentDocuments.IsEmpty()){
            // Return the first record
            return contentDocuments[0];
        } else {
            return null;
        }                     
    } catch (Exception e) {
        System.debug('EXCEPTION ' + e.getMessage() + ' @ ' + e.getStackTraceString());
        throw new DocumentsServiceException('Failed to retrieve ContentDocument record because of EXCEPTION: ' + e.getMessage());
    }
}
public class DocumentsServiceException extends Exception {       
}
}