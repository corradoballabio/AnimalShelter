import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import noResults from "@salesforce/label/c.NoResultsMessage"
import noAccount from "@salesforce/label/c.NoAccountErrorMessage"
import searchPets from '@salesforce/apex/AdoptionFormController.searchPets'
import insertRequest from '@salesforce/apex/AdoptionFormController.insertRequest'

import CASE_ACCOUNT from "@salesforce/schema/Case.AccountId"
import CASE_SUPPLIEDNAME from "@salesforce/schema/Case.SuppliedName"
import CASE_EMAIL from "@salesforce/schema/Case.SuppliedEmail"
import CASE_PHONE from "@salesforce/schema/Case.SuppliedPhone"
import CASE_COUNTRY from "@salesforce/schema/Case.Country__c"
import CASE_PREFERREDBREED from "@salesforce/schema/Case.PreferredBreed__c"
import ADOPTIONREQUEST from "@salesforce/schema/AdoptionRequest__c"

const CASE_FIELDS = [
	CASE_ACCOUNT,
	CASE_SUPPLIEDNAME,
	CASE_EMAIL,
	CASE_PHONE,
	CASE_COUNTRY,
	CASE_PREFERREDBREED
]

export default class AdoptionForm extends NavigationMixin(LightningElement) {
	@api recordId
	@track queryResults
	case
	isLoading = true
	adoptionRequestRecord = {
		sobjectType: ADOPTIONREQUEST.objectApiName,
		Status__c: 'Created'
	}
	sections = {
		adopterData: 'Data of the Adopter',
		searchFilters: 'Filter the available Pets',
		results: 'Results'
	}
	labels = {
		noResults: noResults,
		noAccount: noAccount
	}

	@wire(getRecord, { recordId: '$recordId', fields: CASE_FIELDS })
	caseObject({data, error}) {
		if(data) {
			if(!data.fields.AccountId?.value) {
				this.showToast(this.labels.noAccount)
				this.closeModal()
			}

			this.case = data.fields
			this.adoptionRequestRecord.Case__c = data.id
			this.adoptionRequestRecord.Account__c = this.case.AccountId.value

			this.isLoading = false
		} else if (error) {
			this.showToast(error)
			this.closeModal()
		}
	}

	get activeSections() {
		return Object.keys(this.sections)
	}

	get suppliedName() {
		return this.case?.SuppliedName.value
	}

	get suppliedEmail() {
		return this.case?.SuppliedEmail.value
	}

	get suppliedPhone() {
		return this.case?.SuppliedPhone.value
	}

	get suppliedBreed() {
		return this.case?.PreferredBreed__c.value
	}

	get suppliedCountry() {
		return this.case?.Country__c.value
	}

	get noResults() {
		return !this.queryResults?.length
	}

	searchPets() {
		this.isLoading = true

		let filters = Object.values(this.template.querySelectorAll('[data-filter-id]'))
		filters = filters?.filter(x => x.value).map(x => `${x.attributes['data-filter-id'].nodeValue} = '${x.value}'`)

		searchPets({
			filters: filters
		}).then(result => {
			this.queryResults = result
		}).catch(error => {
			this.showToast(error)
		}).finally(() => {
			this.isLoading = false
		})
	}

	petSelected(event) {
		let petId = event.currentTarget.dataset.id
		this.adoptionRequestRecord.Pet__c = petId

		this.queryResults = this.queryResults.map(pet => {
			return {...pet, ...{isSelected: pet.Id === petId}}
		})
	}

	handleSubmit() {
		this.isLoading = true
		insertRequest({
			record: this.adoptionRequestRecord
		}).then((result) => {
			this.showToast()
			this.closeModal(null)
			this.navigateToRecord(result)
		}).catch(error => {
			this.showToast(error)
		}).finally(() => {
			this.isLoading = false
		})
	}

	navigateToRecord(recordId) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: recordId,
				objectApiName: ADOPTIONREQUEST.objectApiName,
				actionName: 'view'
			}
		});
	}

	showToast(errorMessage) {
		this.dispatchEvent(new ShowToastEvent({
			title: errorMessage ? 'Error' : 'Success',
			message: errorMessage || 'Record created',
			variant: errorMessage ? 'Error' : 'Success',
		}));
	}

	closeModal() {
		this.dispatchEvent(new CloseActionScreenEvent());
	}
}