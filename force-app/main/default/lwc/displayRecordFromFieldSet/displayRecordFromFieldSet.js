import { LightningElement, api, wire } from 'lwc';
import getRecordData from '@salesforce/apex/DisplayRecordFromFieldSetController.getRecordData';

export default class DisplayRecordFromFieldSet extends LightningElement {
	@api recordId;
	@api fieldSetApiName;
	@api numberOfColumns;

	wrapper;
	record;

	loadingData = true;

	error;

	// # APEX

	// *
	@wire(getRecordData, {
		stringId: '$recordToView',
		fieldSetApiName: '$fieldSetApiName',
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

	// *
	get recordToView() {
		if (this.recordId) {
			return this.recordId;
		}
		return null;
	}

	// *
	get fields() {
		let fields = [...Object.keys(this.record)];

		const index = fields.indexOf('Id');
		if (index > -1) {
			fields.splice(index, 1);
		}

		return fields;
	}

	// *
	get retrievedRecordId() {
		return this.record.Id;
	}

	// *
	get recordName() {
		if (this.record?.Name) {
			return this.record.Name;
		}
		return this.objectLabel;
	}

	// *
	get objectApiName() {
		return this.wrapper?.objectApiName;
	}

	// *
	get objectLabel() {
		return this.wrapper?.objectLabel;
	}

	// *
	get iconName() {
		if (this.objectApiName === undefined || this.objectApiName.includes('__c')) {
			return 'standard:work_plan';
		}
		return 'standard:' + this.objectApiName.toLowerCase();
	}

	// *
	get showRecordForm() {
		if (this.record && this.fields?.length > 0) {
			return true;
		}
		return false;
	}

	// *
	get isLoading() {
		if (this.loadingData) {
			return true;
		}
		return false;
	}
}