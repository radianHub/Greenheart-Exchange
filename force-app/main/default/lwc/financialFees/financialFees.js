import { LightningElement, wire } from 'lwc';

// * APEX IMPORTS
import getCurrentUserAccountContactOpportunity from '@salesforce/apex/UsersService.getCurrentUser';

// * TOAST EVENT
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FinancialFees extends LightningElement {
	user;
	userContact;
	userOpportunity;
	error;
	isSettingData = false;

	// * WIRE

	@wire(getCurrentUserAccountContactOpportunity)
	wiredUser({ error, data }) {
		if (data) {
			this.isSettingData = true;
			this.user = data;
			this.userContact = data?.ContactId;
			this.userOpportunity = data?.Contact?.J1_Opportunity__c;
			console.log(this.userContact);

			this.error = undefined;
			this.isSettingData = false;
		} else if (error) {
			this.user = undefined;
			this.error = error;
			this.showError('Title', error);
			console.log(this.error);
		}
	}

	// * ERRORS

	showNotification(title, message, variant, mode = 'dismissable') {
		const evt = new ShowToastEvent({
			title,
			message,
			variant,
			mode,
		});
		this.dispatchEvent(evt);
	}

	showError(title, error) {
		this.showNotification(title, error.body.message, 'error');
	}

	// * GETTERS
	get opportunityId() {
		console.log(this.userOpportunity);
		return this.userOpportunity === null && this.userOpportunity === undefined ? null : this.userOpportunity;
	}

	get isLoading() {
		return this.isSettingData ? true : false;
	}
}