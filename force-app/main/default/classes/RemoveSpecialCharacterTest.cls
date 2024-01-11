@isTest
public class RemoveSpecialCharacterTest {
	static testMethod void testMethod1() {
		String optyName = 'Special ' + '<' + 'Opty';
		optyName = optyName;
		Opportunity opty = new Opportunity();
		opty.StageName = 'Closed Won';
		opty.Passport_Name__c = optyName;
		opty.Passport_Last_Name__c = optyName;
		opty.City_of_Birth__c = optyName;
		opty.CloseDate = System.today();
		opty.Name = optyName;
		insert opty;
		Opportunity opty1 = new Opportunity();
		opty1.StageName = 'Closed Won';
		opty1.CloseDate = System.today();
		opty1.Name = 'Test Data';
		opty1.Passport_Name__c = optyName;
		opty1.Passport_Last_Name__c = optyName;
		opty1.City_of_Birth__c = optyName;
		insert opty1;
		List<Opportunity> optyData = [SELECT Id, Name, Passport_Name__c FROM Opportunity];
		Boolean isUpdated = false;
		Test.startTest();
		List<Opportunity> updatedOpty = new List<Opportunity>();
		for (Opportunity op : optyData) {
			if (!isUpdated) {
				op.Passport_Name__c = 'Special < &gt; Test Data ';
				op.Sync_US_and_Host_Address__c = true;
				isUpdated = false;
			} else {
				op.Passport_Name__c = 'Test Data';
			}
			updatedOpty.add(op);
		}
		update updatedOpty;
		List<Opportunity> updatedOptyData = [SELECT Id, Name, Passport_Name__c FROM Opportunity];
		List<Opportunity> updatedOptyReplaceCheck = new List<Opportunity>();
		for (Opportunity op : updatedOptyData) {
			op.Remove_Special_Characters__c = true;
			updatedOptyReplaceCheck.add(op);
		}
		update updatedOptyReplaceCheck;
		Test.stopTest();
	}
	static testMethod void removeSpecialCharactersTest_BeforeUpdate() {
		String oppName = 'Special ' + '<' + 'Opty';

		List<Opportunity> opps = (List<Opportunity>) new SObjectBuilder(Opportunity.sObjectType)
			.put(Opportunity.Name, oppName)
			.put(Opportunity.Passport_Name__c, oppName)
			.put(Opportunity.Passport_Last_Name__c, oppName)
			.put(Opportunity.City_of_Birth__c, oppName)
			.put(Opportunity.US_Postal_Code__c, '11111')
			.put(Opportunity.Host_School_Address__c, '11111 Test Address')
			.put(Opportunity.Host_School_City__c, 'Test')
			.put(Opportunity.Host_School_Postal_Code__c, '11111')
			.create()
			.getRecords();

		Test.startTest();
		for (Opportunity opp : opps) {
			opp.Passport_Name__c = 'Special < &gt; Test Data ';
			opp.Sync_US_and_Host_Address__c = true;
		}
		update opps;
		Test.stopTest();
	}
}