trigger GH_SendReminderForPlacementAgreementTrigger on Opportunity (after update,before insert,before update, after insert) { 
    
    // Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('J-1').getRecordTypeId();
    
    // if(Trigger.isAfter && Trigger.isUpdate && !OpportunityTriggerHandler.isRepeat){
    //     List<Opportunity> oppSharingPartnerBlankList = new List<Opportunity>();
    //     List<Opportunity> oppSharingPartnerList = new List<Opportunity>();
    //     List<Opportunity> oppplacementFPDList = new List<Opportunity>();
    //     List<Opportunity> oppplacementFPPList = new List<Opportunity>();
    //     List<Opportunity> oppplacementSPDList = new List<Opportunity>();
    //     List<Opportunity> oppplacementSPPList = new List<Opportunity>();
    //     List<Opportunity> oppIAGList = new List<Opportunity>();
    //     List<Opportunity> sevisFeeOpp = new List<Opportunity>();
    //     List<Opportunity> oppProgramExtensionList = new List<Opportunity>();
    //     List<Opportunity> oppProgramExtensionWithIAGList = new List<Opportunity>();
    //     List<Opportunity> oppProgramRenewalList = new List<Opportunity>();
    //     List<Opportunity> oppProgramRenewalIAGList = new List<Opportunity>();
    //     List<Opportunity> oppExtensionAppFeeList = new List<Opportunity>();
    //     Map<Id,Boolean> oppHasProgramExtensionMap = new Map<Id,Boolean>();
    //     Map<Id,Boolean> oppHasProgramRenewalMap = new Map<Id,Boolean>();
        
    //     List<Program_Extension__c> programExtensionList = [SELECT Id,J1_Opportunity_Name__c FROM Program_Extension__c WHERE J1_Opportunity_Name__c IN :Trigger.New];
    //     List<Program_Renewal__c> programRenewalList = [SELECT Id,J1_Opportunity_Name__c FROM Program_Renewal__c WHERE J1_Opportunity_Name__c IN :Trigger.New];
    //     for(Program_Extension__c pe : programExtensionList){
    //         oppHasProgramExtensionMap.put(pe.J1_Opportunity_Name__c, True);
    //     }
    //     for(Program_Renewal__c pr : programRenewalList){
    //         oppHasProgramRenewalMap.put(pr.J1_Opportunity_Name__c, True);
    //     }
        
    //     for(Opportunity participant : Trigger.New) {
    //         Opportunity oldDetails = Trigger.oldMap.get(participant.Id);
    //         if(participant.GH_Send_Agreement_Email__c != oldDetails.GH_Send_Agreement_Email__c){
    //             if(participant.GH_Send_Agreement_Email__c){
    //                 GH_SendReminderForPlacementAgreement.sendPlacementAgreementReminder(participant.Id);   
    //             }
    //         }
            
    //         if(participant.StageName == 'Terms & Conditions' && participant.Financial_App_Deposit_Invoice__c != null
    //            && participant.Financial_App_Deposit_Invoice__c != oldDetails.Financial_App_Deposit_Invoice__c
    //            && oppRecordTypeId.equals(participant.RecordTypeId)){
    //                OpportunityTriggerHandler.isRepeat = true;
    //                if(String.isBlank(participant.Sending_Partner__c)){
    //                    oppSharingPartnerBlankList.add(participant);
    //                }else{
    //                    oppSharingPartnerList.add(participant);
    //                }
    //            }
            
    //         if(oppRecordTypeId.equals(participant.RecordTypeId) && participant.StageName =='Invoiced' && participant.StageName != oldDetails.StageName){
    //             OpportunityTriggerHandler.isRepeat = true;
    //             if(participant.Pay_Sevis_Fees__c == 'Yes'){
    //                 sevisFeeOpp.add(participant);
    //             }
    //             if(String.isBlank(participant.Sending_Partner__c)){
    //                 if(participant.Program_Type__c=='Full program Direct'){
    //                     oppplacementFPDList.add(participant);
    //                 }
    //                 if(participant.Program_Type__c=='Self Placed Direct'){
    //                     oppplacementSPDList.add(participant);
    //                 }
    //             }
    //             if(participant.Sending_Partner__c != System.label.International_Alliance_Group_Id){
    //                 if(participant.Program_Type__c=='Full Program Partner'){
    //                     oppplacementFPPList.add(participant);
    //                 }
    //                 if(participant.Program_Type__c=='Self Placed Partner'){
    //                     oppplacementSPPList.add(participant);
    //                 }
    //             }
                
    //             if(participant.Sending_Partner__c ==  System.label.International_Alliance_Group_Id &&
    //                participant.Program_Type__c == 'Self Placed Partner'){
    //                    oppIAGList.add(participant);
    //                }
    //         }
    //         if(oppRecordTypeId.equals(participant.RecordTypeId) && participant.StageName =='On Program' 
    //            && participant.StageName != oldDetails.StageName){
    //                OpportunityTriggerHandler.isRepeat = true;
    //                if(participant.Sending_Partner__c != System.label.International_Alliance_Group_Id){
    //                    if(oppHasProgramExtensionMap.containsKey(participant.Id)){
    //                        oppProgramExtensionList.add(participant);
    //                        oppExtensionAppFeeList.add(participant);
    //                    }
    //                    if(oppHasProgramRenewalMap.containsKey(participant.Id)){
    //                        oppProgramRenewalList.add(participant);
    //                    }
    //                }
    //                else{
    //                    if(oppHasProgramExtensionMap.containsKey(participant.Id)){
    //                        oppProgramExtensionWithIAGList.add(participant);
    //                    }
    //                    if(oppHasProgramRenewalMap.containsKey(participant.Id)){
    //                        oppProgramRenewalIAGList.add(participant);
    //                    }
    //                }
    //            }   
    //     }
    //     if(oppSharingPartnerBlankList.size() > 0){
    //         OpportunityTriggerHandler.addProductsAndPayments(oppSharingPartnerBlankList,System.Label.Application_Fee_Direct);
    //     }
    //     if(oppSharingPartnerList.size() > 0){
    //         OpportunityTriggerHandler.addProductsAndPayments(oppSharingPartnerList,System.Label.Application_Fee_Partner);
    //     }
        
    //     if(oppplacementFPDList.size() > 0){
    //         OpportunityTriggerHandler.addProductsAndPayments(oppplacementFPDList,'Program Fee - Full-Placement - Direct');
    //     }
        
    //     if(oppplacementSPDList.size() > 0){
    //         OpportunityTriggerHandler.addProductsAndPayments(oppplacementSPDList, 'Program Fee - Self-placement - Direct');
    //     }
        
    //     if(oppplacementSPPList.size() > 0){
    //         OpportunityTriggerHandler.addProductsAndPayments(oppplacementSPPList, 'Program Fee - Self-Placement - Partner');
    //     }
        
    //     if(oppplacementFPPList.size() > 0){
    //         OpportunityTriggerHandler.addProductsAndPayments(oppplacementFPPList, 'Program Fee - Full-Placement - Partner');
    //     }
        
    //     if(oppIAGList.size() > 0){
    //         OpportunityTriggerHandler.addProductsAndPayments(oppIAGList,'Program Fee - Self-Placement - IAG');
    //     }
        
    //     if(sevisFeeOpp.size() > 0){
    //         OpportunityTriggerHandler.addProductsAndPayments(sevisFeeOpp,'SEVIS Fee'); 
    //     }
        
    //     if(oppProgramExtensionList.size() > 0){
    //         OpportunityTriggerHandler.addProductsAndPayments(oppProgramExtensionList,'Program Extension');
    //     }
    //     if(oppExtensionAppFeeList.size() > 0){
    //         OpportunityTriggerHandler.addProductsAndPayments(oppExtensionAppFeeList,'Extension Application Fee');
    //     }
    //     if(oppProgramExtensionWithIAGList.size() > 0){
    //         OpportunityTriggerHandler.addProductsAndPayments(oppProgramExtensionWithIAGList,'Program Extension - IAG');
    //     }
    //     if(oppProgramRenewalList.size() > 0){
    //         OpportunityTriggerHandler.addProductsAndPayments(oppProgramRenewalList,'Program Renewal');
    //     }
    //     if(oppProgramRenewalIAGList.size() > 0){
    //         OpportunityTriggerHandler.addProductsAndPayments(oppProgramRenewalIAGList,'Program Renewal - IAG');
    //     }
    // }
    
    // if(Trigger.isBefore){
        
    //     if(trigger.isUpdate && !OpportunityTriggerHandler.isRepeatBefore){
            
    //         Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id,Sending_Partner__r.Cover_Sevis_Fees__c 
    //                                                               FROM Opportunity WHERE Id IN :Trigger.New]);
            
    //         List<Opportunity> listOfRecords = new List<Opportunity>();
     
    //         for(Opportunity opty : Trigger.new){
    //             Opportunity oldDetails = Trigger.oldMap.get(opty.Id);
    //             if(oppRecordTypeId.equals(opty.RecordTypeId) && opty.StageName =='Accepted' && opty.StageName != oldDetails.StageName){
    //                 opty.StageName = 'Invoiced';
                    
    //             }
    //             if(opty.Sending_Partner__c != Null){
    //                 if(oppMap.get(opty.Id).Sending_Partner__r.Cover_Sevis_Fees__c){
    //                     opty.Pay_Sevis_Fees__c = 'No';
    //                 }
    //                 else{
    //                     opty.Pay_Sevis_Fees__c = 'Yes';
    //                 }
    //             }
    //             else{
    //                 opty.Pay_Sevis_Fees__c = 'Yes';
    //             }
                
    //             if(opty.Update_Passport_Name__c != oldDetails.Update_Passport_Name__c){
    //                 if(opty.Update_Passport_Name__c){
    //                     listOfRecords.add(opty);
    //                 }
    //             }
    //         }
            
    //         if(listOfRecords.size() > 0){
    //             UpdatePassportNameToProperCase.updateName(listOfRecords);
    //         }
            
    //         OpportunityTriggerHandler.isRepeatBefore = true;
    //     }
    // }
}