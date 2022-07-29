@isTest
public class InterplanetaryCasesControllerTest {
  @TestSetup
  public static void makeData() {
    // using the testing functions from the CaseTriggerTest class to create a number of records to test
    List<Case> caseList = CaseTriggerTest.createBulkCaseRecords();
    insert caseList;
  }

  @isTest
  public static void testGetFiveOldestCasesPendingProcessing() {
    Test.startTest();
    List<Case> returnedCases = InterplanetaryCasesController.getFiveOldestCasesPendingProcessing();
    Test.stopTest();
    // verifying the amount of cases returned, must be five
    System.assertEquals(
      5,
      returnedCases.size(),
      '> getFiveOldestCasesPendingProcessing should have returned 5 Case records'
    );
    // verifying that the cases returned have a linked planet and are not closed
    for (Case caseElem : returnedCases) {
      System.assertNotEquals(
        null,
        caseElem.Planet__c,
        '> getFiveOldestCasesPendingProcessing should have returned 5 Case records with linked Planets'
      );
      System.assertNotEquals(
        'Closed',
        caseElem.Status,
        '> getFiveOldestCasesPendingProcessing should have returned 5 Case records with IsClosed on false'
      );
    }
  }

  @isTest
  public static void testRestoreInterplanetaryCases() {
    // query through the inserted interplanetary cases and close them, call the function to restore them,
    // query again and there should be 250 interplanetary cases with the status in New
    List<Case> caseList = [SELECT Id, Status FROM Case WHERE Planet__c != NULL];
    for (Case caseElem : caseList) {
      caseElem.Status = 'Closed';
    }
    Test.startTest();
    InterplanetaryCasesController.restoreInterplanetaryCases();
    Test.stopTest();
    caseList = [SELECT Id, Status FROM Case WHERE Planet__c != NULL];
    System.assertEquals(250, caseList.size(), '> restoreInterplanetaryCases should have restored 250 Case records');
  }
}
