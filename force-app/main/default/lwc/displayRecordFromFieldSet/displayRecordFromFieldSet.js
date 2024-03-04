import { LightningElement, api, wire } from 'lwc';
import getRecordData from '@salesforce/apex/DisplayRecordFromFieldSetController.getRecordData';
import getCurrentUserRecords from '@salesforce/apex/UsersService.getCurrentUser';

export default class DisplayRecordFromFieldSet extends LightningElement {
	@api recordId;
	@api fieldSetApiName;
	@api showTitle;
	@api titleOverride;
	@api showIcon;
	@api titleIcon;
	@api numberOfColumns;
	@api conditionalHostSchool = false;
	@api loadFromUserRecord;

	wrapper;
	record;

	loadingData = true;

	error;

	// # APEX

	@wire(getCurrentUserRecords)
	wiredUser({ error, data }) {
		if (data) {
			this.user = data;
			const userAccountId = data?.Contact?.AccountId;
			const userContactId = data?.ContactId;
			const userOpportunityId = data?.Contact?.J1_Opportunity__c;

			// assign recordId
			if (this.loadFromUserRecord) {
				if (this.loadFromUserRecord == 'Account' && userAccountId) {
					this.recordId = userAccountId;
				} else if (this.loadFromUserRecord == 'Opportunity' && userOpportunityId) {
					this.recordId = userOpportunityId;
				} else if (this.loadFromUserRecord == 'Contact' && userContactId) {
					this.recordId = userContactId;
				}
			}

			this.error = undefined;
		} else if (error) {
			console.log('getCurrentUserRecords error', error);
			this.alert = `Hmm.. Something's not right. Please refresh the page or contact Greenheart directly for assistance.`;
			this.alertType = 'error';
			this.user = undefined;
		}
	}

	// * RETRIEVES SPECIFIED RECORD
	@wire(getRecordData, {
		stringId: '$recordId',
		fieldSetApiName: '$fieldSetApiName',
		conditionalHostSchool: '$conditionalHostSchool',
	})
	wiredGetRecordData({ data, error }) {
		if (data) {
			this.wrapper = data;
			this.record = data.record;

			this.error = undefined;
			this.loadingData = false;
		} else if (error) {
			console.log('error', error);
			this.error = error;
			this.wrapper = undefined;
			this.loadingData = false;
		}
	}

	// # GETTERS

	// * DETERMINES IF THERE IS A RETURNED RECORD
	/*get recordToView() {
		if (this.recordId) {
			return this.recordId;
		}
		return null;
	}*/

	// * GETS FIELDS FOR RECORD FORM
	get fields() {
		return this.wrapper?.fields;
	}

	// * RETURNS RECORD ID OF QUERIED RECORD
	get retrievedRecordId() {
		return this.record.Id;
	}

	// * RETURNS QUERIED RECORD NAME
	get title() {
		if (!this.showTitle) {
			return null;
		}

		if (this.titleOverride) {
			return this.titleOverride;
		}

		if (this.record?.Name) {
			return this.record.Name;
		}
		return this.objectLabel;
	}

	// * RETURNS QUERIED RECORD OBJECT API NAME
	get objectApiName() {
		return this.wrapper?.objectApiName;
	}

	// * RETURNS QUERIED RECORD OBJECT LABEL
	get objectLabel() {
		return this.wrapper?.objectLabel;
	}

	// * DETERMINES WHICH ICON TO DISPLAY
	get iconName() {
		if (!this.showTitle || !this.showIcon) {
			return null;
		}

		if (this.objectApiName === undefined || this.objectApiName.includes('__c')) {
			return this.titleIcon;
		}
		return 'standard:' + this.objectApiName.toLowerCase();
	}

	// * DETERMINES IF FORM SHOULD BE DISPLAYED
	get showRecordForm() {
		if (this.record && this.fields?.length > 0) {
			return true;
		}
		return false;
	}

	// * DETERMINES IF THE ENTIRE COMPONENT SHOULD BE DISPLAYED
	get displayRecord() {
		return this.wrapper?.displayRecord;
	}

	// * DISPLAYS SPINNER
	get isLoading() {
		if (this.loadingData) {
			return true;
		}
		return false;
	}
}