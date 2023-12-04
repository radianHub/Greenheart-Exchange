import { LightningElement, api } from 'lwc';

export default class EmbeddedVideo extends LightningElement {
	//# PUBLIC PROPERTIES
	@api height;
	@api width;
	@api title;
	@api url;
}