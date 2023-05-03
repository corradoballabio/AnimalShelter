import { LightningElement, api } from 'lwc';

export default class PetIcon extends LightningElement {
  @api pet
  @api isSelected

  get cssClasses() {
    return 'slds-button slds-button_neutral slds-var-p-around_x-small slds-var-m-vertical_x-small pet-result' + (this.isSelected ? ' highlighted' : '')
  }
}