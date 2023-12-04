// * A service class for the Document__c object
public with sharing class DocumentsService {
    // Query for a single document record by passing in an Id
    public static Document__c getDocumentRecordById(String documentId){
        try {
            List<Document__c> documents = [SELECT Id 
                                             FROM Document__c
                                            WHERE Id = : documentId
                                             WITH SECURITY_ENFORCED
                                            LIMIT 1];
            if(!documents.IsEmpty()){
                // Return the first record
                return documents[0];
            } else {
                // Return a blank ContentDocument where the Id is null
                return null;
            }                                               
        } catch (Exception e) {
            System.debug('EXCEPTION ' + e.getMessage() + ' @ ' + e.getStackTraceString());
            throw new DocumentsServiceException('Failed to retrieve Document__c record because of EXCEPTION: ' + e.getMessage());
        }
    }
    public class DocumentsServiceException extends Exception {       
    }
}