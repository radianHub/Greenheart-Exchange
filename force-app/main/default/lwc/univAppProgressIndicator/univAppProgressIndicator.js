import { LightningElement, api, wire } from 'lwc';

import getCurrentUserRecords from '@salesforce/apex/UsersService.getCurrentUser';
import getIndicatorSettings from '@salesforce/apex/UniversalAppProgressIndicatorController.getIndicatorSettings';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STAGE_FIELD from '@salesforce/schema/Opportunity.StageName';

const FIELDS = ['Opportunity.Id', 'Opportunity.StageName'];

export default class UnivAppProgressIndicator extends LightningElement {
	@api recordId;
	@api providedOppId;
	@api mdtName;

	currentStage;
	oppId;

	userOpportunity;

	alertMessage;
	alertType;

	steps;

	// * WIRED APEX
	@wire(getRecord, { recordId: '$oppId', fields: FIELDS })
	opp;

	@wire(getCurrentUserRecords)
	wiredUser({ error, data }) {
		if (data) {
			//this.user = data;
			this.userOpportunity = data?.Contact?.J1_Opportunity__c;

			//this.error = undefined;
		} else if (error) {
			console.log('getCurrentUserRecords error', error);
		}
	}

	@wire(getIndicatorSettings, { mdtName: '$mdtName' })
	wiredSettings({ error, data }) {
		if (error) {
			console.error('getIndicatorSettings error', error);
		} else if (data?.error) {
			//this.handleAlert('error', data.error);
			console.error(data.error);
		} else if (data?.settings && data?.steps) {
			console.log('data.steps');
			console.log(typeof data.steps);
			console.log(data.steps);
			this.steps = data.steps;
		} else {
			console.error('An unexpected error occured in getting Indicator Settings.');
			console.log(data);
			console.log(error);
		}
	}

	connectedCallback() {
		this.oppId = this.providedOppId ? this.providedOppId : this.userOpportunity;
		//this.stageList = this.stages.split(',');
	}

	handleAlert(alertType, alertMessage) {
		this.alertType = alertType;
		this.alertMessage = alertMessage;
	}

	/*get showSlot() {
		return this.devMode || this.isStage;
	}*/

	get currentStep() {
		let curStep;
		let foundStage = false;
		for (const step of this.steps) {
			const stageList = step.Stages__c.split(',');
			for (const stage of stageList) {
				if (stage === this.oppStage) {
					curStep = step.StepNum__c;
					foundStage = true;
					break;
				}
			}

			if (foundStage) {
				break;
			}
		}
		return curStep;
	}

	get oppStage() {
		return getFieldValue(this.opp.data, STAGE_FIELD);
	}
}