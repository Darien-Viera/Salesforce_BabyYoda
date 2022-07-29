import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFiveOldestCasesPendingProcessing from '@salesforce/apex/InterplanetaryCasesController.getFiveOldestCasesPendingProcessing';
import restoreInterplanetaryCases from '@salesforce/apex/InterplanetaryCasesController.restoreInterplanetaryCases';
import handleCallout from '@salesforce/apex/MandalorianServerAPIHandler.handleCallout';

export default class InterplanetaryCasesListView extends LightningElement {
  // @wire is for setting up the wire service for reading salesforce data, cannot be used if there are DML operation involved
  // @track is a private reactive property
  // @api is a public reactive property
  // --> reactive means that if the value for said property changes, the component rerenders
  @track casesList = null;
  @track casesLoaded = false;
  @track loading = false;

  connectedCallback() {
    // initialization function, loads the records from the DB
    this.initRecords(false);
  }

  handleRefreshRecords() {
    // rloads the records from the DB
    this.initRecords(false);
  }

  handleInterplanetaryScan(evt) {
    // set the loading var to true, triggering the spinner to be displayed
    this.loading = true;
    // get the value attribute from the lightning button definition, contains the planet code
    let thisPlanetCode = evt.target.value;
    handleCallout({ planetCode: thisPlanetCode })
      .then((respWrapper) => {
        // after the callout function returns, if the execution was successful, the records are reloaded and a
        // success toast is displayed
        this.initRecords(true);
        this.showToast(respWrapper.ToastType.toLowerCase(), respWrapper.ToastType, respWrapper.Payload);
      })
      .catch((error) => {
        // standard error handling
        let stringy = JSON.stringify(error);
        console.log(stringy);
        this.showToast('error', 'ERROR', 'The interplanetary scan failed! Error details -> ' + stringy);
      })
      .finally(() => {
        // the spinner is hidden in every execution path in the end
        this.loading = false;
      });
  }

  handleRestoreInterplanetaryCases() {
    // set the loading var to true, triggering the spinner to be displayed
    this.loading = true;
    restoreInterplanetaryCases()
      .then(() => {
        // after the function returns, if the execution was successful, the records are reloaded and a
        // success toast is displayed
        this.initRecords(true);
        this.showToast('success', 'SUCCESS', 'The interplanetary cases were restored!');
      })
      .catch((error) => {
        // standard error handling
        let stringy = JSON.stringify(error);
        console.log(stringy);
        this.showToast('error', 'ERROR', 'The interplanetary cases failed to be restored! Error details -> ' + stringy);
      })
      .finally(() => {
        // the spinner is hidden in every execution path in the end
        this.loading = false;
      });
  }

  initRecords(deletionRefresh) {
    // set the loading var to true, triggering the spinner to be displayed
    this.loading = true;
    this.casesList = [];
    // the server side function is called to retrieve the oldest 5 interplanetary cases
    getFiveOldestCasesPendingProcessing()
      .then((returnedCaseList) => {
        // clones the returned case list since the data returned from the server is in readonly mode
        // the cloned objects can be modified freely, in this case three new dynamic fields are being
        // added to each object that will contain the URLs to the Contact, Planet and Case record
        let clonedList = returnedCaseList.map((caseElem) => ({ ...caseElem }));
        clonedList.forEach((caseElem) => {
          caseElem.CaseHref = '/lightning/r/' + caseElem.Id + '/view';
          caseElem.ContactHref = '/lightning/r/' + caseElem.Contact.Id + '/view';
          caseElem.PlanetHref = '/lightning/r/' + caseElem.Planet__c + '/view';
        });
        // the cases list is assigned its new objects and the variable casesLoaded is set to true, to change
        // the display from "cases not found" to display the list of Cases
        this.casesList = clonedList;
        this.casesLoaded = this.casesList.length > 0;
        // a success toast is being launched as a signal that the code ran fine, it's only shown if the refresh
        // was triggered from the page loading naturally or when the user clicked on the refresh button
        if (!deletionRefresh)
          this.showToast(
            'success',
            'SUCCESS',
            'The interplanetary cases were loaded! Records loaded -> ' + this.casesList.length
          );
      })
      .catch((error) => {
        this.casesLoaded = this.casesList.length > 0;
        let stringy = JSON.stringify(error);
        console.log(stringy);
        this.showToast('error', 'ERROR', 'The interplanetary cases failed to be loaded! Error details -> ' + stringy);
      })
      .finally(() => {
        // the spinner is hidden in every execution path in the end
        this.loading = false;
      });
  }

  showToast(variantIn, titleIn, msgIn) {
    // generic toast function, receives the variant type, title and message for the toast
    const evt = new ShowToastEvent({
      title: titleIn,
      message: msgIn,
      variant: variantIn,
      mode: 'dismissable'
    });
    this.dispatchEvent(evt);
  }
}
