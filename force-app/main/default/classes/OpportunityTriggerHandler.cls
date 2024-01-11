public with sharing class OpportunityTriggerHandler extends TriggerHandler {
	List<Opportunity> newOpportunities;
	Map<Id, Opportunity> newOpportunitiesMap;
	List<Opportunity> oldOpportunities;
	Map<Id, Opportunity> oldOpportunitiesMap;

	public OpportunityTriggerHandler() {
		this.newOpportunities = (List<Opportunity>) Trigger.new;
		this.newOpportunitiesMap = (Map<Id, Opportunity>) Trigger.newMap;
		this.oldOpportunities = (List<Opportunity>) Trigger.old;
		this.oldOpportunitiesMap = (Map<Id, Opportunity>) Trigger.oldMap;
	}
	public override void beforeInsert() {
		OpportunityService.removeSpecialCharacterOpty(newOpportunities, oldOpportunitiesMap, 'Before Insert');
	}

	public override void beforeUpdate() {
		OpportunityService.GH_SendReminderForPlacementAgreementHandler(
			newOpportunities,
			oldOpportunitiesMap,
			'Before Update'
		);
		OpportunityService.removeSpecialCharacterOpty(newOpportunities, oldOpportunitiesMap, 'Before Update');
	}

	public override void afterInsert() {
		OpportunityService.enablePartnerTeacher(newOpportunities);
	}

	public override void afterUpdate() {
		OpportunityService.GH_SendReminderForPlacementAgreementHandler(
			newOpportunities,
			oldOpportunitiesMap,
			'After Update'
		);
	}
}