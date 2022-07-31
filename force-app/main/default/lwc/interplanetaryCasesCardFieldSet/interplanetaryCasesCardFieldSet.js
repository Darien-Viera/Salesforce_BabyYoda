import { LightningElement, api, track } from 'lwc';

export default class InterplanetaryCasesCardFieldSet extends LightningElement {
  @api caseElem = null;
  @api pairings = [];
  @track pairingsProcessed = [];
  @track singlesProcessed = [];

  connectedCallback() {
    let idCount = 0;
    this.pairingsProcessed = [];
    this.pairings.forEach((element) => {
      let href = this.caseElem[element.link];
      let thisvalue = this.caseElem[element.value];
      if (href === undefined) {
        this.singlesProcessed.push({ id: idCount, label: element.label, value: thisvalue });
      } else {
        this.pairingsProcessed.push({ id: idCount, label: element.label, link: href, value: thisvalue });
      }
      idCount++;
    });
  }
}
