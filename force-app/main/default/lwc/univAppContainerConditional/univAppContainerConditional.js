import { LightningElement, api, wire } from 'lwc';

import getCurrentUserRecords from '@salesforce/apex/UsersService.getCurrentUser';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STAGE_FIELD from '@salesforce/schema/Opportunity.StageName';

const FIELDS = ['Opportunity.Id', 'Opportunity.StageName'];

export default class UnivAppContainerConditional extends LightningElement {
	@api recordId;
	@api providedOppId;
	@api stages;
	@api devMode;
	@api appDevName;
	@api canShowRestart;

	userOpportunity;
	oppId;

	// * WIRED APEX
	@wire(getRecord, { recordId: '$oppId', fields: FIELDS })
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

	get showApp() {
		return this.devMode || this.isStage;
	}

	get isStage() {
		console.log(this.stageList, this.oppStage);
		return this.stageList.includes(this.oppStage);
	}

	get oppStage() {
		return getFieldValue(this.opp.data, STAGE_FIELD);
	}
}