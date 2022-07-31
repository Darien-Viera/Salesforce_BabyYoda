import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFiveOldestCases from '@salesforce/apex/InterplanetaryCasesController.getFiveOldestCases';
import getFiveOldestCasesAndFieldSet from '@salesforce/apex/InterplanetaryCasesController.getFiveOldestCasesAndFieldSet';
import restoreInterplanetaryCases from '@salesforce/apex/InterplanetaryCasesController.restoreInterplanetaryCases';
import handleCallout from '@salesforce/apex/MandalorianServerAPIHandler.handleCallout';

// datatable static columns
const columns = [
  {
    label: 'Case Number',
    fieldName: 'CaseHref',
    type: 'url',
    typeAttributes: {
      label: {
        fieldName: 'CaseNumber'
      },
      target: '_blank'
    },
    hideDefaultActions: true
  },
  {
    label: 'Case Status',
    fieldName: 'Status',
    type: 'text',
    hideDefaultActions: true
  },
  {
    label: 'Planet Name',
    fieldName: 'PlanetName',
    type: 'text',
    hideDefaultActions: true
  },
  {
    label: 'Planet Code',
    fieldName: 'PlanetHref',
    type: 'url',
    typeAttributes: {
      label: {
        fieldName: 'PlanetCode'
      },
      target: '_blank'
    },
    hideDefaultActions: true
  },
  {
    label: 'Contact',
    fieldName: 'ContactHref',
    type: 'url',
    typeAttributes: {
      label: {
        fieldName: 'ContactName'
      },
      target: '_blank'
    },
    hideDefaultActions: true
  },
  {
    label: 'Contact Email',
    fieldName: 'ContactEmail',
    type: 'text',
    hideDefaultActions: true
  },
  {
    label: 'Create Date',
    fieldName: 'CreatedDate',
    type: 'text',
    hideDefaultActions: true
  }
];

export default class InterplanetaryCasesListView extends LightningElement {
  // @wire is for setting up the wire service for reading salesforce data, cannot be used if there are DML operation involved
  // @track is a private reactive property
  // @api is a public reactive property
  // --> reactive means that if the value for said property changes, the component rerenders
  @track loading = false;

  // variables for the first two LWC: Mosaic View and List View
  @track casesList = [];
  @track casesLoaded = false;
  @track caseSelected = null;
  @track preselectedCase = [];
  columns = columns;

  // variables for the LWC that works with the field set: List View with Field Set
  @track casesListFS = [];
  @track casesLoadedFS = false;
  @track caseSelectedFS = null;
  @track preselectedCaseFS = [];
  columnsFS = [];

  connectedCallback() {
    // initialization function, loads the records from the DB
    this.initRecords(false);
    this.initRecordsWithFieldSet(false);
  }

  handleRefreshRecords() {
    // reloads the records from the DB
    this.initRecords(false);
    this.initRecordsWithFieldSet(false);
  }

  handleInterplanetaryScan(evt) {
    // set the loading var to true, triggering the spinner to be displayed
    this.loading = true;
    // get the value attribute from the lightning button definition, contains the planet code
    let thisPlanetCode = evt.target.value;
    handleCallout({ planetCode: thisPlanetCode })
      .then((respWrapper) => {
        // after the callout function returns, if the execution was successful (not a warning, error o info
        // toast type), the records are reloaded and the toast is displayed
        if (respWrapper.ToastType.toLowerCase() === 'success') {
          this.initRecords(true);
          this.initRecordsWithFieldSet(true);
        }
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
        this.initRecordsWithFieldSet(true);
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

  handleRowSelection(evt) {
    let selectedRow = evt.detail.selectedRows;
    this.caseSelected = selectedRow[0];
    this.preselectedCase = [selectedRow[0].Id];
  }

  handleRowSelectionFS(evt) {
    let selectedRow = evt.detail.selectedRows;
    this.caseSelectedFS = selectedRow[0];
    this.preselectedCaseFS = [selectedRow[0].Id];
  }

  initRecords(deletionRefresh) {
    // set the loading var to true, triggering the spinner to be displayed
    this.loading = true;
    this.casesList = [];
    this.casesLoaded = false;
    this.caseSelected = null;
    this.preselectedCase = [];
    // the server side function is called to retrieve the oldest 5 interplanetary cases
    getFiveOldestCases()
      .then((returnedCaseList) => {
        // clones the returned case list since the data returned from the server is in readonly mode
        // the cloned objects can be modified freely, in this case a number of new dynamic fields are being
        // added to each object that will contain the URLs to the Contact, Planet and Case record
        let clonedList = this.prepareCasesForDatatable(returnedCaseList);
        // the cases list is assigned its new objects and the variable casesLoaded is set to true, to change
        // the display from "cases not found" to display the list of Cases
        this.casesList = clonedList;
        this.casesLoaded = this.casesList.length > 0;
        this.caseSelected = clonedList[0];
        if (this.casesLoaded) {
          this.preselectedCase = [this.casesList[0].Id];
        }
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

  prepareCasesForDatatable(returnedCaseList) {
    let clonedList = returnedCaseList.map((caseElem) => ({ ...caseElem }));
    clonedList.forEach((caseElem) => {
      // adding the links to the records
      caseElem.CaseHref = '/lightning/r/' + caseElem.Id + '/view';
      caseElem.ContactHref = '/lightning/r/' + caseElem.Contact.Id + '/view';
      caseElem.PlanetHref = '/lightning/r/' + caseElem.Planet__c + '/view';
      // flattening the fields in the records (the datatable does not index past the first element of the path, so
      // fields like Contact.Email will not be displayed, in this case we add a new field called ContactEmail and store
      // the value in it)
      caseElem.PlanetCode = caseElem.Planet__r.Code__c;
      caseElem.PlanetName = caseElem.Planet__r.Name;
      caseElem.ContactName = caseElem.Contact.Name;
      caseElem.ContactEmail = caseElem.Contact.Email;
    });
    return clonedList;
  }

  initRecordsWithFieldSet(deletionRefresh) {
    // set the loading var to true, triggering the spinner to be displayed
    this.loading = true;
    this.casesListFS = [];
    this.casesLoadedFS = false;
    this.caseSelectedFS = null;
    this.preselectedCaseFS = [];
    this.columnsFS = [];
    getFiveOldestCasesAndFieldSet()
      .then((casesWrapper) => {
        // process the references to related objects and the Id field adding them as url columns
        let clonedListsWithLinks = this.prepareCasesForDatatableLinksFS(
          casesWrapper.FieldSetMembers,
          casesWrapper.CaseList
        );
        // process the rest of the objects adding them as text columns
        let clonedListsAllProcessed = this.prepareCasesForDatatableRestOfItemsFS(
          clonedListsWithLinks[0],
          clonedListsWithLinks[1]
        );
        this.casesListFS = clonedListsAllProcessed;
        this.casesLoadedFS = this.casesListFS.length > 0;
        this.caseSelectedFS = clonedListsAllProcessed[0];
        if (this.casesLoadedFS) {
          this.preselectedCaseFS = [this.casesListFS[0].Id];
        }
        // a success toast is being launched as a signal that the code ran fine, it's only shown if the refresh
        // was triggered from the page loading naturally or when the user clicked on the refresh button
        if (!deletionRefresh)
          this.showToast(
            'success',
            'SUCCESS',
            'The interplanetary cases were loaded! Records loaded -> ' + this.casesListFS.length
          );
      })
      .catch((error) => {
        this.casesLoadedFS = this.casesListFS.length > 0;
        let stringy = JSON.stringify(error);
        console.log(stringy);
        this.showToast('error', 'ERROR', 'The interplanetary cases failed to be loaded! Error details -> ' + stringy);
      })
      .finally(() => {
        // the spinner is hidden in every execution path in the end
        this.loading = false;
      });
  }

  prepareCasesForDatatableLinksFS(fieldSetMembers, caseList) {
    // the idea is to try to pair the columns for the datatable to display links to the related records
    // for example, the Planet Id is a required field in the field set, same as the Planet Code, so
    // we'll try to pair both of them in an URL type column with the link pointing at the record and showing
    // the Planet Code as the label
    // by default, we are not going to show Ids in the datatable unless they are paired
    // clones the elements in the field set list and add a new property to each record to avoid processing
    // fields that have been paired with another one
    let fieldSetMembersCheckmark = fieldSetMembers.map((fieldSetMember) => ({ ...fieldSetMember }));
    let caseListCloned = caseList.map((caseElem) => ({ ...caseElem }));
    fieldSetMembersCheckmark.forEach((element) => {
      element.Processed = false;
    });
    // at first only the pairs will be processed, marked as processed and then the rest of the fields
    for (let i = 0; i < fieldSetMembersCheckmark.length; i++) {
      let element = fieldSetMembersCheckmark[i];
      // if the element was processed, continue to the next (return early pattern)
      if (element.Processed) continue;
      if (element.FieldType.toLowerCase() === 'id') {
        // process the Id field, which is the Case Id
        // we'll try to pair the Case Id with the Case Number, so we look for that field
        let indexCaseNumber = this.searchFieldByName(fieldSetMembersCheckmark, 'casenumber');
        // if the Case Number is not found, continue to the next (return early pattern)
        if (indexCaseNumber === null) continue;
        let elementCaseNumber = fieldSetMembersCheckmark[indexCaseNumber];
        // mark both elements as processed
        element.Processed = true;
        elementCaseNumber.Processed = true;
        // add the link to the record Case to each Case in the list
        caseListCloned.forEach((caseElem) => {
          caseElem.CaseHref = '/lightning/r/' + caseElem.Id + '/view';
        });
        // add the column to the list of columns for the datatable
        this.columnsFS.push({
          label: 'Case Number',
          fieldName: 'CaseHref',
          type: 'url',
          typeAttributes: {
            label: {
              fieldName: 'CaseNumber'
            },
            target: '_blank'
          },
          hideDefaultActions: true
        });
      } else if (element.FieldType.toLowerCase() === 'reference') {
        // process a reference field, a.k.a a related record
        let fieldPathValues = this.getFieldPathForSearching(element);
        // if the path could not be built, move to the next item in the list
        if (fieldPathValues === null || fieldPathValues.length !== 3) continue;
        let indexFieldPath = this.searchFieldByName(fieldSetMembersCheckmark, fieldPathValues[2]);
        if (indexFieldPath === null) continue;
        let elementPaired = fieldSetMembersCheckmark[indexFieldPath];
        // mark both elements as processed
        element.Processed = true;
        elementPaired.Processed = true;
        // create the link field for the datatable
        let hrefName = fieldPathValues[1] + 'Href';
        // flattening the fields in the records
        let flattenAttribute = fieldPathValues[1] + 'Name';
        // the planet related record is treated as an special case, it get's paired with the code
        // instead of the name
        if (element.FieldName.toLowerCase() === 'planet__c') {
          flattenAttribute = fieldPathValues[1] + 'Code';
        }
        // add the link to the related record to each Case in the list
        caseListCloned.forEach((caseElem) => {
          caseElem[hrefName] = '/lightning/r/' + caseElem[element.FieldName] + '/view';
          // same as above, the planet relationship being treated as an special case
          if (element.FieldName.toLowerCase() === 'planet__c') {
            caseElem[flattenAttribute] = caseElem[fieldPathValues[1] + '__r'].Code__c;
          } else {
            if (fieldPathValues[0]) {
              // if it's a custom field
              caseElem[flattenAttribute] = caseElem[fieldPathValues[1] + '__r'].Name;
            } else {
              // if not
              caseElem[flattenAttribute] = caseElem[fieldPathValues[1]].Name;
            }
          }
        });
        // add the column to the list of columns for the datatable
        this.columnsFS.push({
          label: fieldPathValues[1],
          fieldName: hrefName,
          type: 'url',
          typeAttributes: {
            label: {
              fieldName: flattenAttribute
            },
            target: '_blank'
          },
          hideDefaultActions: true
        });
      }
    }
    return [fieldSetMembersCheckmark, caseListCloned];
  }

  prepareCasesForDatatableRestOfItemsFS(fieldSetMembers, caseList) {
    for (let i = 0; i < fieldSetMembers.length; i++) {
      let element = fieldSetMembers[i];
      // if the element was processed, continue to the next (return early pattern)
      if (element.Processed) continue;
      element.Processed = true;
      // check if the field path has depth of 1 or more
      if (element.FieldName.indexOf('.') !== -1) {
        // flattening the fields in the records
        let flattenFieldName = element.FieldName.replace('.', '');
        // relationships bigger than depth 1 are ignored to facilitate things
        if (flattenFieldName.indexOf('.') !== -1) continue;
        // "beautifying" the field name
        flattenFieldName = flattenFieldName.replaceAll('__c', '').replaceAll('__r', '');
        let fieldIndexes = element.FieldName.split('.');
        caseList.forEach((caseElem) => {
          if (fieldIndexes.length === 2) {
            caseElem[flattenFieldName] = caseElem[fieldIndexes[0]][fieldIndexes[1]];
          }
        });
        let flattenFieldNameWithSpaces = element.FieldName.replace('.', ' ')
          .replaceAll('__c', '')
          .replaceAll('__r', '')
          .replaceAll('_', ' ');
        this.columnsFS.push({
          label: flattenFieldNameWithSpaces,
          fieldName: flattenFieldName,
          type: 'text',
          hideDefaultActions: true
        });
      } else {
        // if the field is not a relationship we only add a new column to the datatable columns
        // with the column name "beautified"
        let flattenFieldName = element.FieldName.replaceAll('__c', '').replaceAll('__r', '').replaceAll('_', ' ');
        this.columnsFS.push({
          label: flattenFieldName,
          fieldName: element.FieldName,
          type: 'text',
          hideDefaultActions: true
        });
      }
    }
    return caseList;
  }

  searchFieldByName(fieldSetMembersCheckmark, fieldName) {
    // search for the field in the list, fieldName should be lower case
    for (let i = 0; i < fieldSetMembersCheckmark.length; i++) {
      if (fieldSetMembersCheckmark[i].FieldName.toLowerCase() === fieldName) return i;
    }
    return null;
  }

  getFieldPathForSearching(element) {
    // the idea is to build the field path for relationships, based on if the object is a custom object or a default one
    // both the name of the field removing the __c or Id and the path for said field are returned
    // returns true if it was a custom field, false otherwise
    let endingFieldName = element.FieldName.toLowerCase().substring(
      element.FieldName.length - 3,
      element.FieldName.length
    );
    if (endingFieldName === '__c') {
      // if it's a custom object we'll change the __c for a __r to query for the field Name, i.e. reference__r.Name
      let cleanFieldName = element.FieldName.substring(0, element.FieldName.length - 3);
      let cleanFieldNamePath = cleanFieldName.toLowerCase() + '__r.name';
      // if the element is the Planet relationship, we are mapping the Code instead of the Name
      if (element.FieldName.toLowerCase() === 'planet__c') {
        cleanFieldNamePath = cleanFieldName.toLowerCase() + '__r.code__c';
      }
      return [true, cleanFieldName, cleanFieldNamePath];
    }
    endingFieldName = element.FieldName.toLowerCase().substring(element.FieldName.length - 2, element.FieldName.length);
    if (endingFieldName === 'id') {
      // this works for default objects such as contacts, which is queried as ContactId, but the path to the name is
      // Contact.Name
      let cleanFieldName = element.FieldName.substring(0, element.FieldName.length - 2);
      let cleanFieldNamePath = cleanFieldName.toLowerCase() + '.name';
      return [false, cleanFieldName, cleanFieldNamePath];
    }
    return null;
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
