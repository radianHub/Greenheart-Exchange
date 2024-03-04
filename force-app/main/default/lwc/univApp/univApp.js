import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

import getApp from '@salesforce/apex/UniversalApp.retrieveApp';
import submitSObj from '@salesforce/apex/UniversalApp.submitApp';
import getBoolFieldValue from '@salesforce/apex/UniversalApp.queryForBoolean';
import submitChildObjects from '@salesforce/apex/UniversalApp.submitChildObjects';
import getCurrentUserRecords from '@salesforce/apex/UsersService.getCurrentUser';

export default class UnivApp extends NavigationMixin(LightningElement) {
	// # PUBLIC PROPERTIES
	@api recordId;
	@api oppId; //J1 Opportunity that this UA data is related to
	@api acctId; //Account Id to relate this record to. Primarily for Host Schools to relate records to their account.
	@api isLoadParentId = false;
	@api appDevName;
	@api canShowRestart;

	// # APP DATA
	appData;
	sections = {};
	fieldsetmap = {};
	page;
	sObj = {}; // sObject {attributes:{type:'API_Name__c'}}, Field_1__c: 'value'}
	originalData;
	pageUrl;
	boolResult;
	truePage;
	falsePage;
	boolObject;
	boolField;
	showSpinner = true;
	finished; // After submission - set fields to read-only
	_cssLoaded;

	// # PAGE DATA
	pageIndex = [];
	pageCurrent = 1;
	// * Field and Value Population per Page
	_pageFields; // [AccountId, Custom__c]
	_hasValueIndex = 0;
	_pageHasValue; // [false, true, ...] looks at sObj.hasOwnProperty('Custom__c')
	_valueIndex = 0;
	_pageValues; // [001abc..., value1, ...]

	// # CHILD OBJECT DATA
	childObjects = new Map();

	// # USER RECORDS
	user;
	userAccount;
	userContact;
	userOpportunity;

	// # ERROR/SUCCESS MESSAGING
	alert;
	alertType;
	// Alert Messages
	REQUIRED_FIELDS = 'Required fields are missing.';
	POST_FIELDS_JSON_PARSE = 'Please contact your Salesforce Administrator. The JSON ';
	FLOW_SUCCESS = 'Thank you for completing this form!';

	// # LIFECYCLE HOOKS

	// * ESTABLISH UNIVERSAL APP DATA
	connectedCallback() {
		console.log('Connected Callback');
		console.log('Connected Id: ' + this.recordId);
		console.log(`User's Contact: ` + this.userContact);
		console.log(`User's Account: ` + this.userAccount);
		console.log(`User's Opp: ` + this.userOpportunity);
		/*if (this.isLoadParentOpp) {
			console.log('Set userOpp as recordId: ' + this.userOpportunity);
			this.recordId = this.userOpportunity;
		} else if (this.isLoadParentAcct) {
			console.log('Set userAcct as recordId: ' + this.userAccount);
			this.recordId = this.userAccount;
		}*/
		this.getApp();
	}

	// * SET PAGE STYLING
	renderedCallback() {
		if (this.appData && !this._cssLoaded && this.appData.CSS__c) {
			this._cssLoaded = true;
			let styleElem = document.createElement('style');
			styleElem.innerHTML = this.appData.CSS__c;
			this.template.querySelector('.rh_style').appendChild(styleElem);
		}

		//* HIDE HELPTEXT
		const style = document.createElement('style');
		style.innerText = '.hideHelpText div.slds-form-element__icon { display: none; }';
		let qs = this.template.querySelectorAll('.hideHelpText');

		for (let i = 0; i < qs.length; i++) {
			const element = qs[i];
			element.appendChild(style);
		}
		//this.showSpinner = false;
	}

	// # APEX

	// * GET RECORD ID IF PASSED IN A PARAMETER
	@wire(CurrentPageReference)
	getStateParameters(currentPageReference) {
		const urlValue = currentPageReference.state.c__recordId;
		if (urlValue) {
			this.recordId = urlValue;
		} else {
			this.recordId = null;
		}
	}

	// * WIRED APEX
	@wire(getCurrentUserRecords)
	wiredUser({ error, data }) {
		if (data) {
			this.user = data;
			this.userAccount = data?.Contact?.AccountId;
			this.userContact = data?.ContactId;
			this.userOpportunity = data?.Contact?.J1_Opportunity__c;

			this.error = undefined;
		} else if (error) {
			console.log('getCurrentUserRecords error', error);
			this.alert = `Hmm.. Something's not right. Please refresh the page or contact Greenheart directly for assistance.`;
			this.alertType = 'error';
			this.user = undefined;
		}
	}

	getApp() {
		getApp({ appDevName: this.appDevName, recordId: this.recordId, isLoadParentId: this.isLoadParentId })
			.then((result) => {
				console.log(this.appDevName);
				if (result.error) {
					this.alert = result.error;
					this.alertType = 'error';
					this.showSpinner = false;
				} else if (result.data) {
					console.log(result.data);
					this.originalData = result.data;
					let cloneData = JSON.parse(JSON.stringify(result.data));
					cloneData.sections.forEach((e) => {
						if (this.sections.hasOwnProperty(e.Page__c)) {
							this.sections[e.Page__c].push(e);
							this.sections[e.Page__c].sort((a, b) => a.Order__c - b.Order__c);
						} else {
							this.sections[e.Page__c] = [e];
						}
						this.pageIndex.push(e.Page__c);
					});
					this.pageIndex = [...new Set(this.pageIndex.sort())];
					this.pageIndex.sort(function (a, b) {
						return a - b;
					});
					this.appData = cloneData.application;
					this.boolObject = this.appData.Object_with_Boolean__c;
					this.boolField = this.appData.Boolean_Field__c;
					this.truePage = this.appData.Page_Redirect_if_True__c;
					this.falsePage = this.appData.Page_Redirect_if_False__c;
					this.page = this.sections[this.pageIndex[0]];
					this.fieldsetmap = cloneData.fieldsetmap;
					this.showSpinner = false;
				}
			})
			.catch((error) => {
				this.alert = JSON.stringify(error);
				this.alertType = 'error';
				this.showSpinner = false;
			});
	}

	// * SUBMITS THE RECORD AND CALLS A PAGE REDIRECT BASED ON A RETURNED BOOLEAN VALUE
	submitSObj() {
		this.showSpinner = true;

		let urlRecordId;

		for (const fieldApiName of Object.keys(this.files)) {
			this.sObj[fieldApiName] = true;
		}

		submitSObj({
			sObj: this.sObj,
			application: this.appDevName,
			filesString: JSON.stringify(Object.values(this.files)),
		})
			.then((result) => {
				console.log('Submission RecordId ' + result.data);
				if (result.data) {
					this.alert = this.FLOW_SUCCESS;
					this.alertType = 'success';
					urlRecordId = result.data;

					if (this.childObjects.size > 0) {
						let childObjs = [];
						this.childObjects.forEach((value, key) => {
							let obj = {
								objectName: key,
								parentField: value.get('parentField'),
								records: value.get('records'),
							};
							childObjs.push(obj);
						});
						// * SAVE CHILD OBJECTS
						//console.log(childObjs);
						submitChildObjects({ childObjs: childObjs, parentId: result.data })
							.then((childResult) => {
								console.log(childResult);
							})
							.catch((err) => {
								this.alert = JSON.stringify(err);
								this.alertType = 'error';
							});
					}

					if (this.boolField != null && this.boolObject != null) {
						getBoolFieldValue({
							fieldName: this.boolField,
							objName: this.boolObject,
							recordId: urlRecordId,
						})
							.then((boolResult) => {
								this.boolResult = boolResult[this.boolField];
								if (this.boolResult && this.truePage != null) {
									console.log('True Value, Page: ' + this.truePage);
									this.lwcRedirect(this.truePage);
								} else if (!this.boolResult && this.falsePage != null) {
									console.log('False Value, Page: ' + this.falsePage);
									this.lwcRedirect(this.falsePage);
								}
							})
							.catch((error) => {
								this.alert = JSON.stringify(error);
								this.alertType = 'error';
							});
					} else if (this.appData.Page_Redirect__c) {
						this.lwcRedirect(this.appData.Page_Redirect__c);
					}
					this.showSpinner = false;
				} else if (result.error) {
					this.alert = result.error;
					this.alertType = 'error';
					this.showSpinner = false;
				}
			})
			.catch((error) => {
				this.alert = JSON.stringify(error);
				this.alertType = 'error';
				this.finished = false;
				this.showSpinner = false;
			})
			.finally(() => this.clearPagePopulation());
		// console.log('Global RecordId '+this.recordId);
	}

	// # PRIVATE METHODS

	//* DIRECTS TO VF OR COMMUNITY PAGE BASED ON APP SETTING
	lwcRedirect(page) {
		if (this.appData.vfPageRedirect__c) {
			this.lwcVfRedirect(page);
		} else {
			this.lwcCommPageRedirect(page);
		}
	}

	// * REDIRECTS TO DIFFERENT APP/VF_PAGE
	lwcVfRedirect(/*recordId, */ vfPage) {
		console.log('Redirecting to VF Page: ' + vfPage);
		this.pageUrl = window.location.origin + '/apex/' + vfPage /*+ '?id=' + recordId*/;
		window.location.assign(this.pageUrl);
	}

	// * REDIRECTS TO DIFFERENT APP/COMMUNITY_PAGE
	lwcCommPageRedirect(commPage) {
		console.log('Redirecting to Community Page: ' + commPage);
		this[NavigationMixin.Navigate]({
			type: 'comm__namedPage',
			attributes: {
				name: commPage,
			},
		});
	}

	// * PREPARES PROPERTIES FOR UPCOMING VALUES
	clearPagePopulation() {
		this._pageFields = null;
		this._hasValueIndex = 0;
		this._pageHasValue = null;
		this._valueIndex = 0;
		this._pageValues = null;
	}

	// * PREPARES THE UPCOMING PAGE
	setPage() {
		this.clearPagePopulation();
		this.page = this.sections[this.pageIndex[this.pageCurrent - 1]];
	}

	// * POPULATES THE PAGE PROPERTIES
	populateProperties() {
		this._pageFields = this.currentPage.reduce((prev, cur) => {
			prev.push(
				...cur.rows.reduce((p, c) => {
					p.push(...c.fields.map((f) => f.api));
					return p;
				}, [])
			);
			return prev;
		}, []);
	}

	// * POPULATES THE PAGE VALUES
	populateValues() {
		this._valueIndex = 0;
		if (!this._pageFields) {
			this.populateProperties();
		}
		this._pageValues = this._pageFields.filter((f) => this.sObj.hasOwnProperty(f)).map((e) => this.sObj[e]);
	}

	// * CHECKS FIELD VALIDATION AND SETS THE SOBJ PROPERTY FOR INSERT
	setObjectFields(alert, alertType) {
		let isValid = [...this.template.querySelectorAll('lightning-input-field')].reduce((validSoFar, inp) => {
			this.sObj[inp.fieldName] = inp.value;
			let valid = inp.reportValidity();

			return validSoFar && valid;
		}, true);

		if (!isValid && alert) {
			this.alert = alert;
			this.alertType = alertType;
			this.showSpinner = false;
			this.finished = false;
		}

		return isValid;
	}

	// * DYNAMICALLY RENDERS A FIELD BASED ON ANOTHER FIELDS VALUE
	dynamicRequire(event) {
		this.setPage();

		const cField = event.target.fieldName;
		const cValue = event.target.value.toString();
		console.log('Field: ' + cField + ', Value: ' + cValue);

		let oIndex;
		let cRequire = {};
		let fieldToRequire = [];
		let fieldToUnrequire = [];
		let fieldIndex = null;
		let fieldSetMap = this.fieldsetmap;
		let keys = Object.keys(fieldSetMap);
		let fieldData;
		let requireFieldMap = new Map();
		let unrequireFieldMap = new Map();

		console.log(this.page);
		this.page.forEach((e) => {
			if ('conditionalRequire__c' in e) {
				console.log('Require Sections ', e);
				oIndex = e.Order__c - 1;
				let cJson = JSON.parse(e.conditionalRequire__c);
				cRequire[oIndex] = cJson;
			}
		});

		for (let key in cRequire) {
			if (Object.prototype.hasOwnProperty.call(cRequire, key)) {
				// eslint-disable-next-line no-loop-func
				keys.forEach((fieldSet) => {
					if (fieldSet === this.page[key].Section_Field_Set__c) {
						console.log('Field Set ' + fieldSet);
						console.log('Require Map ', cRequire[key]);
						cRequire[key].Fields.forEach((e) => {
							console.log('Require Object ', e);
							if (
								cField == e.controllingField &&
								e.controllingValues.includes(cValue) &&
								!e.controllingValues.includes('require')
							) {
								console.log('Controlling Value ' + e.controllingValues);
								console.log('Controlling Field ' + e.controllingField);
								console.log('Field to Require ' + e.api);
								fieldToRequire.push(e.api);
							} else if (
								cField == e.controllingField &&
								e.controllingValues.includes('require') &&
								cValue != ''
							) {
								console.log('Controlling Value ' + e.controllingValues);
								console.log('Controlling Field ' + e.controllingField);
								console.log('Field to Require ' + e.api);
								fieldToRequire.push(e.api);
							}
							if (
								cField == e.controllingField &&
								!e.controllingValues.includes(cValue) &&
								!e.controllingValues.includes('require')
							) {
								console.log('Field to Unrequire ' + e.api);
								fieldToUnrequire.push(e.api);
							} else if (
								cField == e.controllingField &&
								e.controllingValues.includes('require') &&
								cValue == ''
							) {
								console.log('Field to Unrequire ' + e.api);
								fieldToUnrequire.push(e.api);
							}
						});
						fieldSetMap[fieldSet].forEach((section) => {
							if (fieldToRequire.length > 0) {
								fieldToRequire.forEach((actionField) => {
									if (actionField === section.api) {
										fieldIndex = fieldSetMap[fieldSet].indexOf(section);
										fieldData = fieldSetMap[fieldSet][fieldIndex];
										requireFieldMap.set(actionField, fieldData);
										console.log(fieldData);
									}
								});
							}
							if (fieldToUnrequire.length > 0) {
								fieldToUnrequire.forEach((actionField) => {
									if (actionField === section.api) {
										fieldIndex = fieldSetMap[fieldSet].indexOf(section);
										fieldData = fieldSetMap[fieldSet][fieldIndex];
										unrequireFieldMap.set(actionField, fieldData);
									}
								});
							}
						});
					}
				});
			}
		}

		if (fieldToRequire.length > 0) {
			requireFieldMap.forEach((e) => {
				e.req = true;
			});
		}

		if (fieldToUnrequire.length > 0) {
			unrequireFieldMap.forEach((e) => {
				e.req = false;
			});
		}
	}

	// * DYNAMICALLY RENDERS AN APP SECTION BASED ON A FIELDS VALUE
	dynamicRender(event) {
		this.setPage();
		const field = event.target.fieldName;
		const value = event.target.value;
		console.log('Field: ' + field + ', Value: ' + value);

		let cRender = [];
		let cField;
		let cValue;
		let sectionRender = [];
		let sectionUnrender = [];

		this.page.forEach((e) => {
			if ('conditionalRender__c' in e) {
				console.log('Render Sections ', e);
				let cJson = JSON.parse(e.conditionalRender__c);
				cRender.push(cJson);
			}
		});

		cRender.forEach((e) => {
			e.Fields.forEach((cf) => {
				if (field === cf.controllingField && value === cf.controllingValue) {
					cf.actionSections.forEach((aS) => {
						cField = cf.controllingField;
						cValue = cf.controllingValue;
						console.log('Controlling Field: ' + cField);
						console.log('Controlling Value: ' + cValue);
						console.log('Sections to Render: ' + aS);
						sectionRender.push(aS);
					});
				}
				if (field === cf.controllingField && value !== cf.controllingValue) {
					cf.actionSections.forEach((aS) => {
						console.log('Section to Unrender ' + aS);
						sectionUnrender.push(aS);
					});
				}
			});
		});

		if (sectionUnrender.length > 0) {
			sectionUnrender.forEach((s) => {
				console.log('Sections ' + s);
				/*const sectionToUnrender = this.template.querySelectorAll('.' + s);
				sectionToUnrender.forEach((a) => {
					a.style = 'display:none';
				});*/
				this.page.forEach((p) => {
					if (p.DeveloperName === s) {
						p.DisplayByDefault__c = false;
					}
				});
			});
		}
		if (sectionRender.length > 0) {
			sectionRender.forEach((s) => {
				console.log('Sections ' + s);
				/*const sectionToRender = this.template.querySelectorAll('.' + s);
				sectionToRender.forEach((a) => {
					a.style = 'display:block';
				});*/
				this.page.forEach((p) => {
					if (p.DeveloperName === s) {
						p.DisplayByDefault__c = true;
					}
				});
			});
		}
	}

	// # HANDLERS

	@track files = {};

	handleSelectFile(event) {
		const apiName = event.detail.fieldApiName;
		const fieldLabel = event.detail.fieldLabel;
		const fieldDocumentType = event.detail.fieldDocumentType;
		const file = event.detail.file;

		let reader = new FileReader();
		let base64;
		let filename = fieldLabel + ' - ' + file.name;

		reader.onload = () => {
			base64 = reader.result.split(',')[1];
			let obj = { ...this.files };
			obj[apiName] = { fileName: filename, base64: base64, documentType: fieldDocumentType };
			this.files = obj;
		};
		reader.readAsDataURL(file);
	}

	// * HANDLES A CUSTOM ALERT EVENT
	handleAlert(event) {
		this.alert = event.detail.alert;
		this.alertType = event.detail.alertType;
	}

	// * BUILDS A MAP OF CHILD OBJECT RECORDS
	updateChild(e) {
		const objName = e.detail.objectName;
		const parentField = e.detail.parentField;
		const data = e.detail.records;

		const childDataMap = new Map();
		childDataMap.set('parentField', parentField);
		childDataMap.set('records', data);

		if (data.length > 0) {
			this.childObjects.set(objName, childDataMap);
		} else {
			if (this.childObjects.get(objName)) {
				this.childObjects.remove(objName);
			}
		}
	}

	// * HANDLES THE DYNAMIC RENDERING AND REQUIRE OF FIELDS
	onChangeHandler(event) {
		this.setPage();
		this.dynamicRender(event);
		this.dynamicRequire(event);
	}

	// * RESETS THE APP
	restart() {
		this.pageCurrent = 1;
		this.setPage();
		this.alert = '';
		this.finished = false;
	}

	// * GOES TO THE PREVIOUS PAGE
	previous() {
		if (!this.finished) {
			this.alert = '';
		}
		this.setObjectFields();
		this.pageCurrent--;
		this.setPage();
	}

	// * GOES TO THE NEXT PAGE
	next() {
		if (!this.finished) {
			this.alert = '';
		}
		if (this.setObjectFields(this.REQUIRED_FIELDS, 'error')) {
			this.pageCurrent++;
			this.setPage();
			console.log(this.page);
		}
	}

	// * SETS THE RECORD ID IF AVAILABLE AND HANDLES THE SUBMISSION OF THE RECORD
	finish() {
		this.alert = '';
		this.finished = true;
		this.showSpinner = true;
		if (this.setObjectFields(this.REQUIRED_FIELDS, 'error')) {
			//this.canShowRestart = true;
			if (this.appData.Post_Submit_Fields__c) {
				let fieldsJSON;
				try {
					fieldsJSON = JSON.parse(this.appData.Post_Submit_Fields__c);
					Object.keys(fieldsJSON).forEach((field) => (this.sObj[field] = fieldsJSON[field]));
				} catch (error) {
					this.alert = error.toString();
					this.alertType = 'error';
					this.finished = false;
					this.showSpinner = false;
				}
			}
			if (!this.alert) {
				this.sObj.sobjectType = this.appData.Object__c;
				if (this.appData.ParentOppField__c) {
					if (this.oppId) {
						this.sObj[this.appData.ParentOppField__c] = this.oppId;
					} else if (this.userOpportunity) {
						this.sObj[this.appData.ParentOppField__c] = this.userOpportunity;
					}
				}
				if (this.appData.ParentAcctField__c) {
					if (this.acctId) {
						this.sObj[this.appData.ParentAcctField__c] = this.acctId;
					} else if (this.userAccount) {
						this.sObj[this.appData.ParentAcctField__c] = this.userAccount;
					}
				}
				if (this.recordId) {
					this.sObj.Id = this.recordId;
				}
				console.log('Submitting SObject');
				console.log(this.sObj);
				this.submitSObj();
			}
		}
	}

	// # GETTERS/SETTERS

	// * DETERMINES WETHER OR NOT TO SHOW RESTART IF APPLICABLE
	get showRestart() {
		return this.canShowRestart && this.finished;
	}

	// * DETERMINES WETHER OR NOT TO SHOW THE PREVIOUS BUTTON
	get showPrevious() {
		return this.pageCurrent > 1;
	}

	// * DETERMINES WETHER OR NOT TO SHOW THE NEXT BUTTON
	get showNext() {
		return this.pageCurrent < this.pageTotal;
	}

	// * DETERMINES WETHER OR NOT TO SHOW THE FINISH BUTTON
	get showFinish() {
		return this.pageCurrent === this.pageTotal && this.pageTotal > 0;
	}

	// * SETS THE ALERT BANNER COLOR
	get alertClass() {
		return (
			'rh_alert-div slds-scoped-notification slds-media slds-media_center slds-m-bottom_small slds-theme_' +
			this.alertType
		);
	}

	// * SETS THE ALERT CONTAINER
	get alertSpan() {
		return 'slds-icon_container slds-icon-utility-' + this.alertType;
	}

	// * SETS THE ALERT ICON
	get alertIcon() {
		return 'utility:' + this.alertType;
	}

	// * RETURNS THE TOTAL NUMBER OF PAGES
	get pageTotal() {
		return this.pageIndex.length;
	}

	// * DETERMINES IF THE APP IS MORE THAN 1 PAGE
	get multiplePages() {
		return this.pageIndex.length > 1;
	}

	// * RETURNS A FIELDS VALUE
	get value() {
		if (!this._pageValues) {
			this.populateValues();
		}
		return this._pageValues[this._valueIndex++];
	}

	// * DETERMINES IF A FIELD HAS A VALUES
	get hasValue() {
		if (!this._pageFields) {
			this.populateProperties();
		}
		// Handle both true and false calls (twice per field)
		return this.sObj.hasOwnProperty(this._pageFields[Math.floor(this._hasValueIndex++ / 2)]);
	}

	// * DETERMINES IF THE USER'S RELATED OPP/ACCOUNT SHOULD BE USED AS RECORDID
	get isLoadParentOpp() {
		return this.appData?.ParentOppField__c === 'Id' && this.isLoadParentId && this.userOpportunity;
	}

	get isLoadParentAcct() {
		return this.appData?.ParentAcctField__c === 'Id' && this.isLoadParentId && this.userAccount;
	}

	// * RETURNS THE CURRENT PAGE
	/**
	 * Current page getter
	 * @yields {Array} - Structed objects for LWC HTML iteration
	 * ________________________________
	 *
	 * data: {section custom meta data},
	 * rows: [{
	 *      id: 123,
	 *      fields : [{
	 *          api: AccountId,
	 *          req: true (Boolean),
	 *          label: Contact,
	 *          type: ID (Schema.DisplayType)
	 *          value: Field Value
	 *      }]
	 * }]
	 */
	get currentPage() {
		let curPage = [];
		if (this.page) {
			curPage = [
				...this.page.map((s) => {
					let sect = { data: s };
					/*if (!s.DisplayByDefault__c) {
						sect.display = 'display:none';
					}*/

					if (s.Section_Field_Set__c) {
						sect.columnClass =
							'field-div slds-col slds-size_1-of-1 slds-medium-size_1-of-' +
							s.Section_Field_Columns__c +
							' ' +
							s.DeveloperName;

						let cols = parseInt(s.Section_Field_Columns__c);
						let directionRows = s.Section_Field_Flow__c == 'Left Right';
						let fieldArray = this.fieldsetmap[s.Section_Field_Set__c];
						let rows = Math.ceil(fieldArray.length / cols);
						let fieldRows = []; // {id:iterRow, fields:[{field}, {from}, {fieldArray}]}

						for (let i = 0; i < rows; i++) {
							// Handle left to right (rows) scenario
							if (directionRows) {
								let startIndex = i * cols;
								let endIndex = (i + 1) * cols;
								fieldRows.push({
									id: i,
									fields: fieldArray.slice(startIndex, endIndex),
								});

								// Handle top down (columns) scenario
							} else {
								let fieldSlice = [];
								for (let j = 0; j < cols; j++) {
									let rcIndex = i + j * rows;
									if (rcIndex < fieldArray.length) {
										fieldSlice.push(fieldArray[rcIndex]);
									}
								}
								fieldRows.push({
									id: i,
									fields: fieldSlice,
								});
							}
						}
						sect.rows = fieldRows;
					}
					return sect;
				}),
			];
		}
		this.showSpinner = false;
		return curPage;
	}
}