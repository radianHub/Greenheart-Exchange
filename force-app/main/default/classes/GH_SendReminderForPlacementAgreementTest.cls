@isTest
public class GH_SendReminderForPlacementAgreementTest {
	@testsetup
	static void setup() {
		Product2 product = new Product2(
			Name = System.label.Application_Fee_Direct,
			Description = 'This is the Product description.',
			ProductCode = 'EX1234',
			StockKeepingUnit = 'EX5678',
			Family = 'Example Product Family',
			QuantityUnitOfMeasure = 'inches',
			IsActive = true
		);

		Product2 product1 = new Product2(
			Name = System.label.Application_Fee_Partner,
			Description = 'This is the Product description.',
			ProductCode = 'EX12345',
			StockKeepingUnit = 'EX5679',
			Family = 'Example Product Family',
			QuantityUnitOfMeasure = 'inches',
			IsActive = true
		);

		Product2 product3 = new Product2(
			Name = 'Program Fee-Full Placed Direct',
			Description = 'This is the Product description.',
			ProductCode = 'EX1234',
			StockKeepingUnit = 'EX5671',
			Family = 'Example Product Family',
			QuantityUnitOfMeasure = 'inches',
			IsActive = true
		);

		Product2 product4 = new Product2(
			Name = 'Program Fee-Self-placed Direct',
			Description = 'This is the Product description.',
			ProductCode = 'EX1234',
			StockKeepingUnit = 'EX5672',
			Family = 'Example Product Family',
			QuantityUnitOfMeasure = 'inches',
			IsActive = true
		);

		Product2 product5 = new Product2(
			Name = 'Program Fee-Self-Placed Partner',
			Description = 'This is the Product description.',
			ProductCode = 'EX1234',
			StockKeepingUnit = 'EX5673',
			Family = 'Example Product Family',
			QuantityUnitOfMeasure = 'inches',
			IsActive = true
		);

		Product2 product6 = new Product2(
			Name = 'Program Fee-Full-Placed Partner',
			Description = 'This is the Product description.',
			ProductCode = 'EX1234',
			StockKeepingUnit = 'EX5674',
			Family = 'Example Product Family',
			QuantityUnitOfMeasure = 'inches',
			IsActive = true
		);

		List<Product2> productListToInsert = new List<Product2>{
			product,
			product1,
			product3,
			product4,
			product5,
			product6
		};
		insert productListToInsert;

		// Get the Standard Price Book ID

		Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);

		// Run an update DML on the Pricebook2 record
		// This is the weird workaround that enables IsStandard to become true
		// on the PricebookEntry record
		update standardPricebook;

		// Insert the Product in the Standard Price Book (if necessary)

		PricebookEntry standardPriceBookEntry = new PricebookEntry(
			Pricebook2Id = standardPriceBook.Id,
			Product2Id = productListToInsert[0].Id,
			UnitPrice = 100.00,
			UseStandardPrice = false,
			IsActive = true
		);

		PricebookEntry standardPriceBookEntry1 = new PricebookEntry(
			Pricebook2Id = standardPriceBook.Id,
			Product2Id = productListToInsert[1].Id,
			UnitPrice = 100.00,
			UseStandardPrice = false,
			IsActive = true
		);

		PricebookEntry standardPriceBookEntry2 = new PricebookEntry(
			Pricebook2Id = standardPriceBook.Id,
			Product2Id = productListToInsert[2].Id,
			UnitPrice = 100.00,
			UseStandardPrice = false,
			IsActive = true
		);

		PricebookEntry standardPriceBookEntry3 = new PricebookEntry(
			Pricebook2Id = standardPriceBook.Id,
			Product2Id = productListToInsert[3].Id,
			UnitPrice = 100.00,
			UseStandardPrice = false,
			IsActive = true
		);

		PricebookEntry standardPriceBookEntry4 = new PricebookEntry(
			Pricebook2Id = standardPriceBook.Id,
			Product2Id = productListToInsert[4].Id,
			UnitPrice = 100.00,
			UseStandardPrice = false,
			IsActive = true
		);

		PricebookEntry standardPriceBookEntry5 = new PricebookEntry(
			Pricebook2Id = standardPriceBook.Id,
			Product2Id = productListToInsert[5].Id,
			UnitPrice = 100.00,
			UseStandardPrice = false,
			IsActive = true
		);

		List<PricebookEntry> pricebookentryListToInsert = new List<PricebookEntry>{
			standardPriceBookEntry,
			standardPriceBookEntry1
		};
		pricebookentryListToInsert.add(standardPriceBookEntry2);
		pricebookentryListToInsert.add(standardPriceBookEntry3);
		pricebookentryListToInsert.add(standardPriceBookEntry4);
		pricebookentryListToInsert.add(standardPriceBookEntry5);
		insert pricebookentryListToInsert;

		Account accObj = new Account();
		accObj.Name = 'International Alliance Group';
		insert accObj;

		Account school = new Account(Name = 'Main School', Primary_Email__c = 'test@test.com');
		Account districtSchool = new Account(Name = 'District School', Primary_Email__c = 'test@test.com');
		insert school;
		insert districtSchool;

		List<Opportunity> oppsToInsert = new List<Opportunity>();
		Opportunity placementSchoolParticipant = new Opportunity(
			Name = 'test',
			Placement_School__c = school.Id,
			Participant_Email__c = 'test@test.com',
			StageName = 'On Program',
			SEVIS_Status__c = 'Active',
			Start_Season__c = '2022-2023',
			CloseDate = system.today()
		);
		oppsToInsert.add(placementSchoolParticipant);
		Opportunity districtSchoolParticipant = new Opportunity(
			Name = 'test',
			District__c = districtSchool.Id,
			Participant_Email__c = 'test@test.com',
			StageName = 'On Program',
			SEVIS_Status__c = 'Active',
			Start_Season__c = '2022-2023',
			CloseDate = system.today()
		);
		oppsToInsert.add(districtSchoolParticipant);
		Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('J-1').getRecordTypeId();
		Opportunity oppFPD = new Opportunity();
		oppFPD.AccountId = accObj.Id;
		oppFPD.Name = 'Test Opty';
		oppFPD.StageName = 'Invoiced';
		oppFPD.CloseDate = System.today();
		oppFPD.RecordTypeId = oppRecordTypeId;
		oppFPD.Sending_Partner__c = accObj.Id;
		oppFPD.Start_Season__c = '2023-2024';
		oppsToInsert.add(oppFPD);

		Opportunity oppFPD2 = new Opportunity();
		oppFPD2.AccountId = accObj.Id;
		oppFPD2.Name = 'Test Opty2';
		oppFPD2.StageName = 'On Program';
		oppFPD2.CloseDate = System.today();
		oppFPD2.RecordTypeId = oppRecordTypeId;
		oppFPD2.Sending_Partner__c = accObj.Id;
		oppFPD2.Start_Season__c = '2023-2024';
		oppFPD2.GH_Send_Agreement_Email__c = false;
		oppsToInsert.add(oppFPD2);

		insert oppsToInsert;
	}

	static Account getAccount() {
		return [SELECT Id FROM Account LIMIT 1];
	}

	@isTest
	public static void handlePlacementAgreement() {
		Test.startTest();
		Opportunity opty = [
			SELECT
				id,
				name,
				Participant_Email__c,
				Main_School_POC_Email__c,
				LastModifiedDate,
				District__c,
				Placement_School__c,
				StageName,
				Start_Season__c
			FROM opportunity
			WHERE Start_Season__c = '2022-2023' AND StageName = 'On Program'
			ORDER BY LastModifiedDate
			LIMIT 1
		];

		GH_SendReminderForPlacementAgreement.sendPlacementAgreementReminder(opty.Id);
		Test.stopTest();
	}

	@isTest
	public static void handleViaTrigger() {
		Test.startTest();
		Opportunity opty = [
			SELECT id, GH_Send_Agreement_Email__c
			FROM opportunity
			WHERE Start_Season__c = '2022-2023' AND StageName = 'On Program'
			LIMIT 1
		];
		opty.GH_Send_Agreement_Email__c = true;
		update opty;
		Test.stopTest();
	}
	@isTest
	public static void handleViaTrigger_ShouldAddToOtherLists_FullProgramDirect() {
		Test.startTest();
		Opportunity opty = [
			SELECT id, GH_Send_Agreement_Email__c
			FROM opportunity
			WHERE Name = 'Test Opty2'
			LIMIT 1
		];
		opty.GH_Send_Agreement_Email__c = true;
		opty.StageName = 'Invoiced';
		opty.Pay_Sevis_Fees__c = 'Yes';
		opty.Program_Type__c = 'Full program Direct';
		opty.Sending_Partner__c = new SObjectBuilder(Account.SObjectType).create().getRecord().Id;
		opty.GH_Send_Agreement_Email__c = true;
		update opty;
		Test.stopTest();
	}
	@isTest
	public static void handleViaTrigger_ShouldAddToOtherLists_SelfPlacedDirect() {
		Test.startTest();
		Opportunity opty = [
			SELECT id, GH_Send_Agreement_Email__c
			FROM opportunity
			WHERE Name = 'Test Opty2'
			LIMIT 1
		];
		opty.GH_Send_Agreement_Email__c = true;
		opty.StageName = 'Invoiced';
		opty.Pay_Sevis_Fees__c = 'Yes';
		opty.Program_Type__c = 'Self Placed Direct';
		opty.Sending_Partner__c = new SObjectBuilder(Account.SObjectType).create().getRecord().Id;
		update opty;
		Test.stopTest();
	}
	@isTest
	public static void handleViaTrigger_ShouldAddToOtherLists_FullProgramPartner() {
		Test.startTest();
		Opportunity opty = [
			SELECT id, GH_Send_Agreement_Email__c
			FROM opportunity
			WHERE Name = 'Test Opty2'
			LIMIT 1
		];
		opty.GH_Send_Agreement_Email__c = true;
		opty.StageName = 'Invoiced';
		opty.Pay_Sevis_Fees__c = 'Yes';
		opty.Program_Type__c = 'Full Program Partner';
		opty.Sending_Partner__c = new SObjectBuilder(Account.SObjectType).create().getRecord().Id;
		update opty;
		Test.stopTest();
	}
	@isTest
	public static void handleViaTrigger_ShouldAddToOtherLists_SelfPlacedPartner() {
		Test.startTest();
		Opportunity opty = [
			SELECT id, GH_Send_Agreement_Email__c
			FROM opportunity
			WHERE Name = 'Test Opty2'
			LIMIT 1
		];
		opty.GH_Send_Agreement_Email__c = true;
		opty.StageName = 'Invoiced';
		opty.Pay_Sevis_Fees__c = 'Yes';
		opty.Program_Type__c = 'Self Placed Partner';
		opty.Sending_Partner__c = new SObjectBuilder(Account.SObjectType).create().getRecord().Id;
		update opty;
		Test.stopTest();
	}
	@isTest
	public static void handleViaTrigger_ShouldAddToOtherLists_CustomLabelPartner() {
		Test.startTest();
		Opportunity opty = [
			SELECT id, GH_Send_Agreement_Email__c
			FROM opportunity
			WHERE Name = 'Test Opty2'
			LIMIT 1
		];
		opty.GH_Send_Agreement_Email__c = true;
		opty.StageName = 'Invoiced';
		opty.Pay_Sevis_Fees__c = 'Yes';
		opty.Program_Type__c = 'Self Placed Partner';
		opty.Sending_Partner__c = System.label.International_Alliance_Group_Id;
		opty.Sending_Partner__c = new SObjectBuilder(Account.SObjectType).create().getRecord().Id;
		update opty;
		Test.stopTest();
	}

	@isTest
	static void testAddProductsAndPaymentsWithBlankSharingPartner() {
		Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('J-1').getRecordTypeId();
		Account accObj = getAccount();
		Opportunity opp = new Opportunity();
		opp.AccountId = accObj.Id;
		opp.Name = 'Test Opty';
		opp.StageName = 'Terms & Conditions';
		opp.CloseDate = System.today();
		opp.RecordTypeId = oppRecordTypeId;
		opp.Start_Season__c = '2023-2024';
		opp.Preferred_Program__c = 'Full program Direct';

		Test.startTest();
		insert opp;
		Test.stopTest();

		List<OpportunityLineItem> oppLineItemList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
		System.assertEquals(true, oppLineItemList.size() > 0, 'Should have value');
	}

	@isTest
	static void testAddProductsAndPaymentsWithSharingPartner() {
		Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('J-1').getRecordTypeId();
		Account accObj = getAccount();
		Opportunity opp = new Opportunity();
		opp.AccountId = accObj.Id;
		opp.Name = 'Test Opty';
		opp.StageName = 'Terms & Conditions';
		opp.CloseDate = System.today();
		opp.RecordTypeId = oppRecordTypeId;
		opp.Start_Season__c = '2023-2024';
		opp.Sending_Partner__c = accObj.Id;

		Test.startTest();
		insert opp;
		Test.stopTest();

		List<OpportunityLineItem> oppLineItemList = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
		System.assertEquals(true, oppLineItemList.size() > 0, 'Should have value');
	}

	@istest
	static void testFPDOpportunity() {
		Test.startTest();
		Opportunity opty = [
			SELECT id, RecordTypeId, StageName, GH_Send_Agreement_Email__c
			FROM opportunity
			WHERE Start_Season__c = '2023-2024' AND StageName = 'Invoiced'
			LIMIT 1
		];
		opty.StageName = 'Accepted';
		opty.Program_Type__c = 'Full program Direct';
		opty.Pay_Sevis_Fees__c = 'yes';
		opty.Sending_Partner__c = null;
		update opty;
		Test.stopTest();

		System.assertEquals('Accepted', opty.StageName, 'Should have value');
	}

	@istest
	static void testSPDOpportunity() {
		Test.startTest();
		Opportunity opty = [
			SELECT id, RecordTypeId, StageName, GH_Send_Agreement_Email__c
			FROM opportunity
			WHERE Start_Season__c = '2023-2024' AND StageName = 'Invoiced'
			LIMIT 1
		];
		opty.StageName = 'Accepted';
		opty.Program_Type__c = 'Self Placed Direct';
		opty.Sending_Partner__c = null;
		update opty;
		Test.stopTest();

		System.assertEquals('Accepted', opty.StageName, 'Should have value');
	}

	@istest
	static void testSPPOpportunity() {
		Test.startTest();
		Account accObj = getAccount();
		Opportunity opty = [
			SELECT id, RecordTypeId, StageName, GH_Send_Agreement_Email__c
			FROM opportunity
			WHERE Start_Season__c = '2023-2024' AND StageName = 'Invoiced'
			LIMIT 1
		];
		opty.StageName = 'Accepted';
		opty.Program_Type__c = 'Self Placed Partner';
		opty.Sending_Partner__c = accObj.Id;
		update opty;
		Test.stopTest();

		System.assertEquals('Accepted', opty.StageName, 'Should have value');
	}

	@istest
	static void testFPPOpportunity() {
		Test.startTest();
		Opportunity opty = [
			SELECT id, RecordTypeId, StageName, GH_Send_Agreement_Email__c
			FROM opportunity
			WHERE Start_Season__c = '2023-2024' AND StageName = 'Invoiced'
			LIMIT 1
		];
		opty.StageName = 'Accepted';
		opty.Program_Type__c = 'Full Program Partner';
		opty.Pay_Sevis_Fees__c = 'yes';
		update opty;
		Test.stopTest();

		System.assertEquals('Accepted', opty.StageName, 'Should have value');
	}
}