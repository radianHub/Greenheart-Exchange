public with sharing class OpportunityService {
    public static Boolean isRepeat = false;
    public static Boolean isRepeatBefore = false;

    public static void removeSpecialCharacterOpty(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunitiesMap, String triggerContext){
        // Logic for Before Update triggering context    
        if(triggerContext == 'Before Update'){
                for(Opportunity opty : newOpportunities){
                    // Logic for replacing all special characters
                    Boolean oldValue = oldOpportunitiesMap.get(opty.Id).Remove_Special_Characters__c;
                    if(oldValue != opty.Remove_Special_Characters__c){
                        if(opty.Remove_Special_Characters__c){
                            if(opty.passport_name__c != null)
                            {
                                opty.Passport_Name__c  = RemoveSpecialCharacterOptyController.replaceSpecialCharacters(opty.Passport_Name__c.unescapeHtml3());
                            }
                            if(opty.City_of_Birth__c  != null)
                            {
                                opty.City_of_Birth__c  = RemoveSpecialCharacterOptyController.replaceSpecialCharacters(opty.City_of_Birth__c.unescapeHtml3());
                            }
                            if(opty.Passport_Last_Name__c  != null)
                            {
                                opty.Passport_Last_Name__c  = RemoveSpecialCharacterOptyController.replaceSpecialCharacters(opty.Passport_Last_Name__c.unescapeHtml3());
                            }
                        }
                    }
                    
                    //Logic for syncing US and Host Address with New Address field to display Map
                    Boolean isAddressSynced = oldOpportunitiesMap.get(opty.Id).Sync_US_and_Host_Address__c ;
                    if(isAddressSynced != opty.Sync_US_and_Host_Address__c ){
                        if(opty.Sync_US_and_Host_Address__c ){
                            opty.US_Address_With_Map__City__s = opty.US_City__c != null ? opty.US_City__c : '';
                            opty.US_Address_With_Map__Street__s = opty.US_Address__c !=null ? opty.US_Address__c : '';                
                            opty.US_Address_With_Map__PostalCode__s = opty.US_Postal_Code__c != null ? opty.US_Postal_Code__c : '';
                            
                            opty.Host_Address_With_Map__Street__s = opty.Host_School_Address__c != null ? opty.Host_School_Address__c : '';
                            opty.Host_Address_With_Map__City__s = opty.Host_School_City__c != null ? opty.Host_School_City__c : '';
                            opty.Host_Address_With_Map__PostalCode__s = opty.Host_School_Postal_Code__c != null ? opty.Host_School_Postal_Code__c : ''; 
                        }
                    }
                    
                }
            }
            
            // Logic for Before Insert triggering context
            if(triggerContext == 'Before Insert'){
                for(Opportunity opty : newOpportunities){
                    //Logic for syncing US and Host Address with New Address field to display Map                 
                    opty.US_Address_With_Map__City__s = opty.US_City__c != null ? opty.US_City__c : '';
                    opty.US_Address_With_Map__Street__s = opty.US_Address__c !=null ? opty.US_Address__c : '';                
                    opty.US_Address_With_Map__PostalCode__s = opty.US_Postal_Code__c != null ? opty.US_Postal_Code__c : '';
                    
                    opty.Host_Address_With_Map__Street__s = opty.Host_School_Address__c != null ? opty.Host_School_Address__c : '';
                    opty.Host_Address_With_Map__City__s = opty.Host_School_City__c != null ? opty.Host_School_City__c : '';
                    opty.Host_Address_With_Map__PostalCode__s = opty.Host_School_Postal_Code__c != null ? opty.Host_School_Postal_Code__c : '';               
                }
            }
    }
    
    // Must run after insert
    // Populates the related parent's J1 Opportunity field
    public static void populateParentContactJ1Opportunity(List<Opportunity> newOpportunities){
        Id j1RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('J_1').getRecordTypeId();
        System.debug('J1 record type Id: ' + j1RecordTypeId);

        List<Id> parentJ1Contacts = new List<Id>();
        Map<Id, Id> contactIdToOpportunityId = new Map<Id, Id>();
        for(Opportunity opp : newOpportunities){
            System.debug('opp record type: ' + opp.RecordTypeId);
            System.debug('opp ContactId: ' + opp.ContactId);
            // Filter list down to J-1 Opportunities
            if(opp.RecordTypeId == j1RecordTypeId){
                parentJ1Contacts.add(opp.ContactId);
                contactIdToOpportunityId.put(opp.ContactId, opp.Id);
            }
        }
        List<Contact> contactsToUpdate = [SELECT Id 
                                            FROM Contact 
                                           WHERE Id IN : parentJ1Contacts];

        if(contactsToUpdate.isEmpty()){
            System.debug('Did not find any parent J1 Contacts');
            return;
        }

        // For each contact, we will update the J1 Opportunity field to match the Id pulled 
        // from the contactIdToOpportunityId Map we generated above 
        for(Contact con : contactsToUpdate){
            Id j1OpportunityId = contactIdToOpportunityId.get(con.Id);
            // Update J1 Opportunity field
            con.J1_Opportunity__c = j1OpportunityId;
            con.J1_Opportunity__c = j1OpportunityId;
        }                                           
        update contactsToUpdate;
    }

    public static void GH_SendReminderForPlacementAgreementHandler(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunitiesMap, String triggerContext){
        // Get the J-1 Opportunity Record type
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('J-1').getRecordTypeId();
    
        // * PROCESSING FOR AFTER UPDATE
        if(triggerContext == 'After Update' && !isRepeat){
            
            // Initialize empty Lises and Maps needed throughout the logic
            List<Opportunity> oppSharingPartnerBlankList = new List<Opportunity>();
            List<Opportunity> oppSharingPartnerList = new List<Opportunity>();
            List<Opportunity> oppplacementFPDList = new List<Opportunity>();
            List<Opportunity> oppplacementFPPList = new List<Opportunity>();
            List<Opportunity> oppplacementSPDList = new List<Opportunity>();
            List<Opportunity> oppplacementSPPList = new List<Opportunity>();
            List<Opportunity> oppIAGList = new List<Opportunity>();
            List<Opportunity> sevisFeeOpp = new List<Opportunity>();
            List<Opportunity> oppProgramExtensionList = new List<Opportunity>();
            List<Opportunity> oppProgramExtensionWithIAGList = new List<Opportunity>();
            List<Opportunity> oppProgramRenewalList = new List<Opportunity>();
            List<Opportunity> oppProgramRenewalIAGList = new List<Opportunity>();
            List<Opportunity> oppExtensionAppFeeList = new List<Opportunity>();
            Map<Id,Boolean> oppHasProgramExtensionMap = new Map<Id,Boolean>();
            Map<Id,Boolean> oppHasProgramRenewalMap = new Map<Id,Boolean>();
           
            // Get Program Extenstions & Program Renewals
            List<Program_Extension__c> programExtensionList = getProgramExtensionsFromOpportunities(newOpportunities);
            List<Program_Renewal__c> programRenewalList = getProgramRenewalsFromOpportunities(newOpportunities);

            // Loop through the queried Program Extensions and populate the oppHasProgramExtensionMap
            for(Program_Extension__c pe : programExtensionList){
                oppHasProgramExtensionMap.put(pe.J1_Opportunity_Name__c, True);
            }

            // Loop through the queried Program Extensions and populate the oppHasProgramRenewalMap
            for(Program_Renewal__c pr : programRenewalList){
                oppHasProgramRenewalMap.put(pr.J1_Opportunity_Name__c, True);
            }
            
            for(Opportunity participant : newOpportunities) {
                Opportunity oldDetails = oldOpportunitiesMap.get(participant.Id);

                // Evaluate whether the Agreement Email should be sent
                Boolean shouldSendAgreementEmail = (participant.GH_Send_Agreement_Email__c != oldDetails.GH_Send_Agreement_Email__c) && participant.GH_Send_Agreement_Email__c ? true : false;
                
                if(shouldSendAgreementEmail){
                    GH_SendReminderForPlacementAgreement.sendPlacementAgreementReminder(participant.Id);   
                }
                
                // Evaluate whether the Opportunity should be added to either the oppSharingPartnerBlankList or oppSharingPartnerList
                Boolean shouldAddToOppSharingList = (participant.StageName == 'Terms & Conditions' && participant.Financial_App_Deposit_Invoice__c != null
                && participant.Financial_App_Deposit_Invoice__c != oldDetails.Financial_App_Deposit_Invoice__c
                && oppRecordTypeId.equals(participant.RecordTypeId) ) ? true : false;

                if(shouldAddToOppSharingList){
                       isRepeat = true;
                       if(String.isBlank(participant.Sending_Partner__c)){
                           oppSharingPartnerBlankList.add(participant);
                       }else{
                           oppSharingPartnerList.add(participant);
                       }
                   }
                
                Boolean shouldAddToOtherLists = ( oppRecordTypeId.equals(participant.RecordTypeId) 
                                                && participant.StageName =='Invoiced' 
                                                && participant.StageName != oldDetails.StageName ) ? true : false;
                if(shouldAddToOtherLists){
                    isRepeat = true;
                    if(participant.Pay_Sevis_Fees__c == 'Yes'){
                        sevisFeeOpp.add(participant);
                    }
                    if(String.isBlank(participant.Sending_Partner__c)){
                        if(participant.Program_Type__c=='Full program Direct'){
                            oppplacementFPDList.add(participant);
                        }
                        if(participant.Program_Type__c=='Self Placed Direct'){
                            oppplacementSPDList.add(participant);
                        }
                    }
                    if(participant.Sending_Partner__c != System.label.International_Alliance_Group_Id){
                        if(participant.Program_Type__c=='Full Program Partner'){
                            oppplacementFPPList.add(participant);
                        }
                        if(participant.Program_Type__c=='Self Placed Partner'){
                            oppplacementSPPList.add(participant);
                        }
                    }
                    
                    if(participant.Sending_Partner__c ==  System.label.International_Alliance_Group_Id &&
                       participant.Program_Type__c == 'Self Placed Partner'){
                           oppIAGList.add(participant);
                       }
                }

                Boolean isOnProgram = ( oppRecordTypeId.equals(participant.RecordTypeId) && participant.StageName =='On Program' 
                && participant.StageName != oldDetails.StageName ) ? true : false;

                if(isOnProgram){
                       isRepeat = true;
                       if(participant.Sending_Partner__c != System.label.International_Alliance_Group_Id){
                           if(oppHasProgramExtensionMap.containsKey(participant.Id)){
                               oppProgramExtensionList.add(participant);
                               oppExtensionAppFeeList.add(participant);
                           }
                           if(oppHasProgramRenewalMap.containsKey(participant.Id)){
                               oppProgramRenewalList.add(participant);
                           }
                       }
                       else{
                           if(oppHasProgramExtensionMap.containsKey(participant.Id)){
                               oppProgramExtensionWithIAGList.add(participant);
                           }
                           if(oppHasProgramRenewalMap.containsKey(participant.Id)){
                               oppProgramRenewalIAGList.add(participant);
                           }
                       }
                   }   
            }
            if(oppSharingPartnerBlankList.size() > 0){
                addProductsAndPayments(oppSharingPartnerBlankList,System.Label.Application_Fee_Direct);
            }
            if(oppSharingPartnerList.size() > 0){
                addProductsAndPayments(oppSharingPartnerList,System.Label.Application_Fee_Partner);
            }
            
            if(oppplacementFPDList.size() > 0){
                addProductsAndPayments(oppplacementFPDList,'Program Fee - Full-Placement - Direct');
            }
            
            if(oppplacementSPDList.size() > 0){
                addProductsAndPayments(oppplacementSPDList, 'Program Fee - Self-placement - Direct');
            }
            
            if(oppplacementSPPList.size() > 0){
                addProductsAndPayments(oppplacementSPPList, 'Program Fee - Self-Placement - Partner');
            }
            
            if(oppplacementFPPList.size() > 0){
                addProductsAndPayments(oppplacementFPPList, 'Program Fee - Full-Placement - Partner');
            }
            
            if(oppIAGList.size() > 0){
                addProductsAndPayments(oppIAGList,'Program Fee - Self-Placement - IAG');
            }
            
            if(sevisFeeOpp.size() > 0){
                addProductsAndPayments(sevisFeeOpp,'SEVIS Fee'); 
            }
            
            if(oppProgramExtensionList.size() > 0){
                addProductsAndPayments(oppProgramExtensionList,'Program Extension');
            }
            if(oppExtensionAppFeeList.size() > 0){
                addProductsAndPayments(oppExtensionAppFeeList,'Extension Application Fee');
            }
            if(oppProgramExtensionWithIAGList.size() > 0){
                addProductsAndPayments(oppProgramExtensionWithIAGList,'Program Extension - IAG');
            }
            if(oppProgramRenewalList.size() > 0){
                addProductsAndPayments(oppProgramRenewalList,'Program Renewal');
            }
            if(oppProgramRenewalIAGList.size() > 0){
                addProductsAndPayments(oppProgramRenewalIAGList,'Program Renewal - IAG');
            }
        }
        
        // * PROCESSING FOR BEFORE UPDATE    
        if(triggerContext == 'Before Update' && !isRepeatBefore){
            
            Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>(getOpportunitiesFromOpportunities(newOpportunities));
            
            List<Opportunity> listOfRecords = new List<Opportunity>();
        
            for(Opportunity opty : newOpportunities){
                Opportunity oldDetails = oldOpportunitiesMap.get(opty.Id);

                Boolean shouldUpdateStageName = ( oppRecordTypeId.equals(opty.RecordTypeId) && opty.StageName =='Accepted' && opty.StageName != oldDetails.StageName ) ? true : false;

                if(shouldUpdateStageName){
                    opty.StageName = 'Invoiced';
                    
                }

                if(opty.Sending_Partner__c != Null){
                    if(oppMap.get(opty.Id).Sending_Partner__r.Cover_Sevis_Fees__c){
                        opty.Pay_Sevis_Fees__c = 'No';
                    }
                    else{
                        opty.Pay_Sevis_Fees__c = 'Yes';
                    }
                }
                else{
                    opty.Pay_Sevis_Fees__c = 'Yes';
                }
                
                if(opty.Update_Passport_Name__c != oldDetails.Update_Passport_Name__c){
                    if(opty.Update_Passport_Name__c){
                        listOfRecords.add(opty);
                    }
                }
            }
            
            if(listOfRecords.size() > 0){
                UpdatePassportNameToProperCase.updateName(listOfRecords);
            }
            
            isRepeatBefore = true;
        }
    }


    
    // * EXISTING LOGIC MOVED HERE FROM OPPORTUNITYTRIGGERHANDLER
    
    public static void addProductsAndPayments(List<Opportunity> listOfOpportunity,String productName){
        String invoiceNumber;
        List<String> productNameForInvoiceList = new List<String>{'Program Fee - Full-Placement - Direct',
            'Program Fee - Self-placement - Direct','Program Fee - Self-Placement - Partner','Program Fee - Full-Placement - Partner', 
            'Program Fee - Self-Placement - IAG','Program Renewal - IAG','Program Renewal','Program Extension - IAG','Extension Application Fee'
            ,'Program Extension'};
        List<Payment__c> listOfPayments = new List<Payment__c>();
        List<OpportunityLineItem> listOfOppLineItem = new List<OpportunityLineItem>();
        String priceBookName = System.Label.PE_AND_PR_PRICEBOOK_NAME;
        List<pricebook2> priceBook = [Select Id,Name from pricebook2 where name =: priceBookName AND isActive = true];            
        String productsName = productName;
        List<String> uniqueProductsToBeAdded = new List<String>();
        uniqueProductsToBeAdded.add(productsName);
        
        if(productNameForInvoiceList.contains(productName)){
            invoiceNumber = createInvoiceNumber();
        }
        if(productName == 'SEVIS Fee'){
            invoiceNumber = createSFInvoiceNumber();
        }
        
        if(uniqueProductsToBeAdded.size() > 0){
            if(priceBook.size() > 0){
                Map<Id,PricebookEntry> mapOfProducts = new Map<Id,PricebookEntry>([SELECT Id, Name, Pricebook2Id, Product2Id, UnitPrice, IsActive FROM PricebookEntry where Pricebook2Id =: priceBook[0].Id AND Name IN : uniqueProductsToBeAdded AND IsActive = true]);
                for(PricebookEntry priceBookDetails : mapOfProducts.values()){
                    for(Opportunity opty : listOfOpportunity){
                        OpportunityLineItem oppLineItem = new OpportunityLineItem();
                        oppLineItem.OpportunityId = opty.Id;
                        oppLineItem.PricebookEntryId = priceBookDetails.Id;
                        oppLineItem.UnitPrice = priceBookDetails.UnitPrice; 
                        oppLineItem.Quantity = 1;
                        oppLineItem.ServiceDate = System.today();
                        
                        Payment__c paymentObj = new Payment__c();
                        paymentObj.Name = priceBookDetails.Name;
                        paymentObj.Opportunity__c = opty.Id;
                        if(invoiceNumber != null){
                            oppLineItem.Invoice_Number__c = invoiceNumber;
                            paymentObj.Invoice_Number__c = invoiceNumber;
                        }else{
                            oppLineItem.Invoice_Number__c = opty.Financial_App_Deposit_Invoice__c;
                            paymentObj.Invoice_Number__c = opty.Financial_App_Deposit_Invoice__c;
                        }
                        listOfOppLineItem.add(oppLineItem);
                        listOfPayments.add(paymentObj);
                    }
                }
            }
        }
        
        if(listOfOppLineItem.size() > 0){
            insert listOfOppLineItem;
        }
        
        if(listOfPayments.size() > 0){
            insert listOfPayments;
        }       
    }
    
    
    public static String createInvoiceNumber(){
        String newInvoiceNumber = '0';
        Integer iCharLen = 6;
        String strZero = '0';
        List<Payment__c> allPaymentInvoice = [Select Invoice_Number__c from Payment__c 
                                              where invoice_Number__c != null 
                                              and Name Not IN ('Application Fee - Direct', 'Application Fee - Partner') and Invoice_Number__c like 'PF%' 
                                              order by createddate desc LIMIT 10];
        for(Payment__c payment : allPaymentInvoice){
            List<String> listOfInvoiceNumber = payment.Invoice_Number__c.split('-');
            if(listOfInvoiceNumber[1].isNumeric()){
                Integer newInvoice = Integer.valueOf(listOfInvoiceNumber[1])+1;   
                newInvoiceNumber = String.valueOf(Integer.valueOf(listOfInvoiceNumber[1])+1);
                break;
            }
        }
        
        if (newInvoiceNumber.length() < iCharLen){ 
            newInvoiceNumber = strZero.repeat(iCharLen - newInvoiceNumber.length()) + newInvoiceNumber; 
        }
        
        newInvoiceNumber = System.Label.PE_Invoice_Prefix+'-'+newInvoiceNumber;
        return newInvoiceNumber;
    }
    
    public static String createSFInvoiceNumber(){
        String newInvoiceNumber = '1';
        Integer iCharLen = 5;
        String strZero = '0';
        List<Payment__c> allPaymentInvoice = [Select Invoice_Number__c from Payment__c 
                                              where invoice_Number__c != null 
                                              and Name = 'SEVIS Fee' and Invoice_Number__c like 'SF%'
                                              order by createddate desc limit 10];
        for(Payment__c payment : allPaymentInvoice){
            List<String> listOfInvoiceNumber = payment.Invoice_Number__c.split('-');
            if(listOfInvoiceNumber[1].isNumeric()){
                Integer newInvoice = Integer.valueOf(listOfInvoiceNumber[1])+1;   
                newInvoiceNumber = String.valueOf(Integer.valueOf(listOfInvoiceNumber[1])+1);
                break;
            }
        }
        
        if (newInvoiceNumber.length() < iCharLen){ 
            newInvoiceNumber = '1' + strZero.repeat(iCharLen - newInvoiceNumber.length()) + newInvoiceNumber; 
        }
        
        newInvoiceNumber = System.Label.Sevis_Fee_Invoice_Number+'-'+newInvoiceNumber;
        return newInvoiceNumber;
    }


    // * HELPERS
    private static List<Program_Extension__c> getProgramExtensionsFromOpportunities(List<Opportunity> newOpportunities){
        return [SELECT Id,J1_Opportunity_Name__c FROM Program_Extension__c WHERE J1_Opportunity_Name__c IN :newOpportunities];
    }
    private static List<Program_Renewal__c> getProgramRenewalsFromOpportunities(List<Opportunity> newOpportunities){
        return [SELECT Id,J1_Opportunity_Name__c FROM Program_Renewal__c WHERE J1_Opportunity_Name__c IN :newOpportunities];
    }
    private static List<Opportunity> getOpportunitiesFromOpportunities(List<Opportunity> newOpportunities){
        return [SELECT Id,Sending_Partner__r.Cover_Sevis_Fees__c FROM Opportunity WHERE Id IN :newOpportunities];
    }
}