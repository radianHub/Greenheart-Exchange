trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    System.debug('Opportunity Trigger Called');
    new OpportunityTriggerHandler().run();
    /*if(Trigger.isUpdate && !OpportunityTriggerHandler.isRepeat){
        List<Opportunity> oppSharingPartnerBlankList = new List<Opportunity>();
        List<Opportunity> oppSharingPartnerList = new List<Opportunity>();
        for(Opportunity opty : Trigger.New){
            if(opty.StageName == 'Terms & Conditions' && opty.Financial_App_Deposit_Invoice__c != null){
                OpportunityTriggerHandler.isRepeat = true;
                if(String.isBlank(opty.Sending_Partner__c)){
                    oppSharingPartnerBlankList.add(opty);
                }else{
                    oppSharingPartnerList.add(opty);
                }
            }
        }
        OpportunityTriggerHandler.AddProductsAndPayments(oppSharingPartnerBlankList,System.Label.Application_Fee_Direct);
        OpportunityTriggerHandler.AddProductsAndPayments(oppSharingPartnerList,System.Label.Application_Fee_Partner);
    }*/

}