// TODO: Create record types for Teacher and Host School (for documents). Assign Teacher to Teacher and Partners. Assign Host School to Host School only.
// TODO: Update picklist for Type field on Document object. Update which picklist values are available by record type
// TODO: onunload event, delete records on unload - ON HOLD
// * SALESFORCE IMPORTS
import { LightningElement, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// * LIGHTNING DATA SERVICE IMPORTS
import DOCUMENT_OBJECT from '@salesforce/schema/Document__c';
import NAME_FIELD from '@salesforce/schema/Document__c.Name';
import TYPE_FIELD from '@salesforce/schema/Document__c.Type__c';
import CONTACT_FIELD from '@salesforce/schema/Document__c.Contact__c';
import ACCOUNT_FIELD from '@salesforce/schema/Document__c.Account__c';
import OPPORTUNITY_FIELD from '@salesforce/schema/Document__c.Opportunity__c';

// * RENDER TEMPLATE IMPORTS
import filesUploadBase from './filesUpload.html';
import recordEditForm from './recordEditForm.html';

// * APEX IMPORTS
import deleteContentDocumentAndDocument from '@salesforce/apex/FilesUploadController.deleteContentDocumentAndDocument';
import getCurrentUserAccountContactOpportunity from '@salesforce/apex/UsersService.getCurrentUserAccountContactOpportunity';

// * CONSTANTS
const ERROR_TITLE = 'An error occurred on upload';
const SUCCESS_TITLE = 'File(s) successfully uploaded';


export default class FilesUpload extends LightningElement {
    objectName = DOCUMENT_OBJECT;
    fields = {
        name: NAME_FIELD,
        type: TYPE_FIELD,
        contact: CONTACT_FIELD,
        account: ACCOUNT_FIELD,
        opportunity: OPPORTUNITY_FIELD 
    };

    // * PUBLIC PROPERTIES
    @api cardTitle;
    @api buttonLabel;
    @api buttonIcon;
    @api defaultDocumentType;
    @api hideDocumentType;
    @api acceptedFileTypes;

    // Document__c recordId. Populated in the handleSuccess method
    doumentId;

    // ContentDocument recordId. Populated when the Salesforce file is uploaded in the UI
    contentDocumentId;

    // * Booleans
    isProcessing = false;
    isDone = false;

    selectedTemplate = 'filesUpload';

    documentName;
    userSelectedDocumentType;
    fileName;

    // User information
    user;
    userAccount;
    userContact;
    userOpportunity;

    // * LIFECYCLE METHODS
    render(){
        return this.selectedTemplate === 'filesUpload' ? filesUploadBase 
        : this.selectedTemplate === 'recordEditForm' ? recordEditForm 
        : finalTemplate;
    }

    // * WIRED APEX
    @wire(getCurrentUserAccountContactOpportunity)
    wiredUser({error, data}) {
        if(data) {
            this.user = data;
            this.userAccount = data?.Contact?.AccountId;
            this.userContact = data?.ContactId;
            this.userOpportunity = data?.Contact?.J1_Opportunity__c;
            
            this.error = undefined;
        } else if (error) {
            this.showError(error);
            this.user = undefined;
        }
    }

    // * IMPERATIVE APEX
    deleteContentDocumentAndDocument(){
        deleteContentDocumentAndDocument({contentDocumentId: this.contentDocumentId, documentId: this.documentId})
        .then(() => {
            console.log('Successfully delete the Document and ContentDocument records.');
        })
        .catch((error) => {
            this.showError(error);
        })
        .finally(() => {
            this.isProcessing = false;
        })
    }

    // * HANDLERS
    handleUploadFinished(event){
        this.fileName = event.detail.files[0].name;
        this.contentDocumentId = event.detail.files[0].documentId;
    }

    handleSuccess(event){
        this.documentId = event.detail.id;
        // Set the template to the Lightning Record Edit form html file
        this.selectedTemplate = 'recordEditForm';
    }

    handleDone(){
        this.isDone = true;
        this.showSuccess(SUCCESS_TITLE, 'Your file has been uploaded into the system.');
        this.resetForm();
    }

    handleCancel(){
        // Call Apex to delete existing Document__c and ContentDocument that were just created
        this.deleteContentDocumentAndDocument();
        this.showInfo('Cancelled', 'Document creation was cancelled');
        // deleteFileAndParentDocument(/* Pass in contentDocumentId to delete and documentId (custom object record) to delete */) 
        this.resetForm();
    }

    handleError(error){
        this.showError(error);
    }

    // * HELPERS
    resetForm(){
        // Switch to the base template
        this.selectedTemplate = 'filesUpload';
        // Reset the form
        let inputFields = this.template.querySelectorAll('lightning-input-field');
        this.documentId = '';
        this.fileName = '';
        this.isDone = false;
        if(inputFields){
            Array.from(inputFields).forEach(field => {
                field.reset();
            });
        }
    }

    showToast(title, message, variant, mode='dismissable') {
        const showToastEvt = new ShowToastEvent({
            title,
            message, 
            variant,
            mode
         } );
        this.dispatchEvent(showToastEvt);
    }

    showError(error){
        this.showToast(ERROR_TITLE, error.body.message, 'error');
    }
    showSuccess(title, message){
        this.showToast(title, message, 'success');
    }
    showInfo(title, message){
        this.showToast(title, message, 'info');
    }

    // * GETTERS
    get isLoading(){
        return this.isProcessing ? true : false;
    }

    get acceptedFormats(){
        return this.acceptedFileTypes;
    }
}