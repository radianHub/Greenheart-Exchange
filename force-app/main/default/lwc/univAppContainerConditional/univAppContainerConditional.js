import { LightningElement, api, wire } from 'lwc';

import getCurrentUserRecords from '@salesforce/apex/UsersService.getCurrentUserAccountContactOpportunity';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STAGE_FIELD from '@salesforce/schema/Opportunity.StageName';

const FIELDS = ['Opportunity.Id', 'Opportunity.StageName'];

/**
 * @slot univApp
 */

export default class UnivAppContainerConditional extends LightningElement {
	@api recordId;
	@api providedOppId;
	@api stages;
	@api devMode;
	@api appDevName;
	@api canShowRestart;

	//user;
	userOpportunity;
	oppId;
	//opp;

	// * WIRED APEX
	@wire(getRecord, { recordId: '$providedOppId', fields: FIELDS })
	opp;

	@wire(getCurrentUserRecords)
	wiredUser({ error, data }) {
		if (data) {
			//this.user = data;
			this.userOpportunity = data?.Contact?.J1_Opportunity__c;

			this.error = undefined;
		} else if (error) {
			console.log('getCurrentUserRecords error', error);
			//this.alert = `Hmm.. Something's not right. Please refresh the page or contact Greenheart directly for assistance.`;
			//this.alertType = 'error';
			//this.user = undefined;
		}
	}

	connectedCallback() {
		this.oppId = this.providedOppId ? this.providedOppId : this.userOpportunity;
		this.stageList = this.stages.split(',');
	}

	get showSlot() {
		return this.devMode || this.isStage;
	}

	/*get oppId() {
		return this.providedOppId ? this.providedOppId : this.userOpportunity;
	}*/

	get isStage() {
		console.log(this.stageList, this.oppStage);
		return this.stageList.includes(this.oppStage);
	}

	get oppStage() {
		return getFieldValue(this.opp.data, STAGE_FIELD);
	}
}