import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getDogRecordTypeId from "@salesforce/apex/PetFormController.getDogRecordTypeId";
import getDogBreeds from "@salesforce/apex/PetFormController.getDogBreeds";
import insertPet from "@salesforce/apex/PetFormController.insertPet";

import PET_STATUS from "@salesforce/schema/Pet__c.Status__c"
import PET_BREED from "@salesforce/schema/Pet__c.Breed__c"
import PET from "@salesforce/schema/Pet__c"

const PET_FIELDS = [
	PET_STATUS,
	PET_BREED
]

export default class PetForm extends NavigationMixin(LightningElement) {
	@api recordid
	showSpinner = false
	isBreedListLoaded = false
	isPetRecordTypeLoaded = true
	breedOptions = [{label: '--None--', value: null}]

	petRecord = {
		sobjectType: PET.objectApiName,
		Status__c: 'Created'
	}

	@wire(getRecord, { recordId: '$recordid', fields: PET_FIELDS })
	petRecord({data, error}) {
		if(data){
			this.petRecord.Status__c = data.fields.Status__c?.value

			if(data.fields.Breed__c?.value) this.template.querySelector('[data-id="Breed__c"]').value = data.fields.Breed__c?.value
		}
		if(error) {
			this.handleError(error)
		}
	}

	@wire(getDogBreeds, {})
	wiredBreedList({data, error}) {
		if(data) {
			this.breedOptions = this.breedOptions.concat(data.map(x => {return {label: x, value: x}}))
			this.isBreedListLoaded = true
		}
		if(error) {
			this.handleError(error)
		}
	}

	connectedCallback() {
		this.petRecord.Id = this.recordid
		if(this.recordid) return

		this.isPetRecordTypeLoaded = false
		getDogRecordTypeId({})
		.then(response => {
			this.petRecord.RecordTypeId = response
			this.isPetRecordTypeLoaded = true
		}).catch(error => {
			this.handleError(error?.body?.message)
		})
	}

	handleCancel() {
		this.closeTab()
	}

	handleSubmit() {
		this.showSpinner = true
		let inputs = this.template.querySelectorAll('[data-id]')

		const isValid = [...inputs].reduce((validSoFar, field) => {
			return validSoFar && field.reportValidity();
		}, true);
		this.showSpinner = false

		if(!isValid) return

		this.showSpinner = true
		inputs.forEach(input => this.petRecord[input.fieldName || input.attributes['data-id'].nodeValue] = input.value)

		insertPet({
			record: this.petRecord
		}).then(result => {
			this.showToast()
			this.closeTab()
			this.navigateToRecord(result)
		}).catch(error => {
			this.handleError(error?.body?.message)
		}).finally(
			this.showSpinner = false
		)
	}

	closeTab() {
		this.dispatchEvent(new CustomEvent('closetabrequest'));
	}

	navigateToRecord(recordId) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: recordId,
				objectApiName: PET.objectApiName,
				actionName: 'view'
			}
		});
	}

	handleError(errorMessage) {
		this.isPetRecordTypeLoaded = true
		this.isBreedListLoaded = true

		this.showToast(errorMessage)
	}

	showToast(errorMessage) {
		this.dispatchEvent(new ShowToastEvent({
			title: errorMessage ? 'Error' : 'Success',
			message: errorMessage || 'Record created',
			variant: errorMessage ? 'Error' : 'Success',
		}));
	}

	get isLoading() {
		return this.showSpinner || !this.isPetRecordTypeLoaded || !this.isBreedListLoaded
	}
}