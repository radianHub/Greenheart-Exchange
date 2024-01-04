trigger RemoveSpecialCharacterOptyHandler on Opportunity (before update , before insert) {
    // ! LOGIC HAS BEEN MOVED TO THE OPPORTUNITYSERVICE CLASS
    // if(Trigger.isBefore){
    //     if(Trigger.isUpdate){
    //         for(Opportunity opty : Trigger.New){
    //             //Logic for replacing all special characters
    //             Boolean oldValue = Trigger.oldMap.get(opty.Id).Remove_Special_Characters__c;
    //             if(oldValue != opty.Remove_Special_Characters__c){
    //                 if(opty.Remove_Special_Characters__c){
    //                     if(opty.passport_name__c != null)
    //                     {
    //                         opty.Passport_Name__c  = RemoveSpecialCharacterOptyController.replaceSpecialCharacters(opty.Passport_Name__c.unescapeHtml3());
    //                     }
    //                     if(opty.City_of_Birth__c  != null)
    //                     {
    //                         opty.City_of_Birth__c  = RemoveSpecialCharacterOptyController.replaceSpecialCharacters(opty.City_of_Birth__c.unescapeHtml3());
    //                     }
    //                     if(opty.Passport_Last_Name__c  != null)
    //                     {
    //                         opty.Passport_Last_Name__c  = RemoveSpecialCharacterOptyController.replaceSpecialCharacters(opty.Passport_Last_Name__c.unescapeHtml3());
    //                     }
    //                 }
    //             }
                
    //             //Logic for syncing US and Host Address with New Address field to display Map
    //             Boolean isAddressSynced = Trigger.oldMap.get(opty.Id).Sync_US_and_Host_Address__c ;
    //             if(isAddressSynced != opty.Sync_US_and_Host_Address__c ){
    //                 if(opty.Sync_US_and_Host_Address__c ){
    //                     opty.US_Address_With_Map__City__s = opty.US_City__c != null ? opty.US_City__c : '';
    //                     opty.US_Address_With_Map__Street__s = opty.US_Address__c !=null ? opty.US_Address__c : '';                
    //                     opty.US_Address_With_Map__PostalCode__s = opty.US_Postal_Code__c != null ? opty.US_Postal_Code__c : '';
                        
    //                     opty.Host_Address_With_Map__Street__s = opty.Host_School_Address__c != null ? opty.Host_School_Address__c : '';
    //                     opty.Host_Address_With_Map__City__s = opty.Host_School_City__c != null ? opty.Host_School_City__c : '';
    //                     opty.Host_Address_With_Map__PostalCode__s = opty.Host_School_Postal_Code__c != null ? opty.Host_School_Postal_Code__c : ''; 
    //                 }
    //             }
                
    //         }
    //     }
        
    //     if(Trigger.isInsert){
    //         for(Opportunity opty : Trigger.New){
    //             //Logic for replacing all special characters
    //             /*
    //              if(opty.passport_name__c != null)
    //                 {
    //                     opty.Passport_Name__c  = RemoveSpecialCharacterOptyController.replaceSpecialCharacters(opty.Passport_Name__c.unescapeHtml3());
    //                 }
    //                 if(opty.City_of_Birth__c  != null)
    //                 {
    //                     opty.City_of_Birth__c  = RemoveSpecialCharacterOptyController.replaceSpecialCharacters(opty.City_of_Birth__c.unescapeHtml3());
    //                 }
    //                 if(opty.Passport_Last_Name__c  != null)
    //                 {
    //                     opty.Passport_Last_Name__c  = RemoveSpecialCharacterOptyController.replaceSpecialCharacters(opty.Passport_Last_Name__c.unescapeHtml3());
    //                 }
	// 			*/
                
    //             //Logic for syncing US and Host Address with New Address field to display Map                 
    //             opty.US_Address_With_Map__City__s = opty.US_City__c != null ? opty.US_City__c : '';
    //             opty.US_Address_With_Map__Street__s = opty.US_Address__c !=null ? opty.US_Address__c : '';                
    //             opty.US_Address_With_Map__PostalCode__s = opty.US_Postal_Code__c != null ? opty.US_Postal_Code__c : '';
                
    //             opty.Host_Address_With_Map__Street__s = opty.Host_School_Address__c != null ? opty.Host_School_Address__c : '';
    //             opty.Host_Address_With_Map__City__s = opty.Host_School_City__c != null ? opty.Host_School_City__c : '';
    //             opty.Host_Address_With_Map__PostalCode__s = opty.Host_School_Postal_Code__c != null ? opty.Host_School_Postal_Code__c : '';               
    //         }
    //     }
    // }
}