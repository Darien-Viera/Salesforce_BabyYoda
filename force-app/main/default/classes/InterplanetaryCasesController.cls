//Testclass: InterplanetaryCasesControllerTest
public class InterplanetaryCasesController {
  @AuraEnabled
  public static List<Case> getFiveOldestCasesPendingProcessing() {
    // returns a case list with the five oldest opened interplanetary cases, a case is considered interplanetary
    // when it contains a link to a planet record
    return [
      SELECT
        Id,
        CaseNumber,
        Status,
        Subject,
        SuppliedEmail,
        Contact.Id,
        Contact.Name,
        Successful_Scan__c,
        Description,
        Planet__c,
        Planet__r.Name,
        Planet__r.Code__c,
        CreatedDate
      FROM Case
      WHERE IsClosed = FALSE AND Planet__c != NULL
      ORDER BY CreatedDate ASC
      LIMIT 5
    ];
  }

  @AuraEnabled
  public static void restoreInterplanetaryCases() {
    // auxiliar function used for testing, it restores all interplanetary cases back to New status
    List<Case> caseList = [SELECT Id, Successful_Scan__c, Status FROM Case WHERE Planet__c != NULL];
    for (Case caseElem : caseList) {
      caseElem.Successful_Scan__c = false;
      caseElem.Status = 'New';
    }
    update caseList;
  }
}
