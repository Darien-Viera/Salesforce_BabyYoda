@isTest
public class InterplanetaryCasesControllerTest {
  @TestSetup
  public static void makeData() {
    // using the testing functions from the CaseTriggerTest class to create a number of records to test
    List<Case> caseList = CaseTriggerTest.createBulkCaseRecords();
    insert caseList;
    // verifying that the field set is well formed: it exists, it contains at least one field and the required fields
    // are available in it
    List<Schema.FieldSetMember> fieldSet = null;
    try {
      fieldSet = SObjectType.Case.FieldSets.Interplanetary_Cases_Field_Set.getFields();
    } catch (Exception e) {
      System.assert(false, '> The Interplanetary Cases Field Set should exist');
    }
    System.assertNotEquals(0, fieldSet.size(), '> The Interplanetary Cases Field Set ');
    List<String> requiredFields = new List<String>{ 'Planet__c', 'Planet__r.Name', 'Planet__r.Code__c' };
    for (Schema.FieldSetMember fieldSetMember : fieldSet) {
      Integer index = requiredFields.indexOf(String.valueOf(fieldSetMember.getFieldPath()));
      if (index != -1)
        requiredFields.remove(index);
    }
    System.assertEquals(0, requiredFields.size(), '> The Interplanetary Cases Field Set is missing required fields');
  }

  @isTest
  public static void testGetFiveOldestCases() {
    Test.startTest();
    List<Case> returnedCases = InterplanetaryCasesController.getFiveOldestCases();
    Test.stopTest();
    // verifying the amount of cases returned, must be five
    System.assertEquals(5, returnedCases.size(), '> getFiveOldestCases should have returned 5 Case records');
    // verifying that the cases returned have a linked planet and are not closed
    for (Case caseElem : returnedCases) {
      System.assertNotEquals(
        null,
        caseElem.Planet__c,
        '> getFiveOldestCases should have returned 5 Case records with linked Planets'
      );
      System.assertNotEquals(
        'Closed',
        caseElem.Status,
        '> getFiveOldestCases should have returned 5 Case records with IsClosed on false'
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

  @isTest
  public static void testGetFiveOldestCasesAndFieldSet() {
    Test.startTest();
    InterplanetaryCasesController.QueryWrapper returnedWrapper = InterplanetaryCasesController.getFiveOldestCasesAndFieldSet();
    Test.stopTest();
    // verifying the amount of cases returned, must be five
    System.assertEquals(
      5,
      returnedWrapper.CaseList.size(),
      '> getFiveOldestCasesAndFieldSet should have returned 5 Case records'
    );
    // verifying that the cases returned have a linked planet and are not closed
    for (Case caseElem : returnedWrapper.CaseList) {
      System.assertNotEquals(
        null,
        caseElem.Planet__c,
        '> getFiveOldestCasesAndFieldSet should have returned 5 Case records with linked Planets'
      );
      System.assertNotEquals(
        'Closed',
        caseElem.Status,
        '> getFiveOldestCasesAndFieldSet should have returned 5 Case records with IsClosed on false'
      );
    }
  }

  @isTest
  public static void testProcessFieldSet() {
    List<Schema.FieldSetMember> fieldSet = SObjectType.Case.FieldSets.Interplanetary_Cases_Field_Set.getFields();
    test.startTest();
    List<InterplanetaryCasesController.FieldSetMemberWrapper> fieldSetWrapperList = InterplanetaryCasesController.processFieldSet(
      fieldSet
    );
    test.stopTest();
    System.assertEquals(
      'ID',
      fieldSetWrapperList[0].FieldType,
      '> The first field set wrapper member type should be ID'
    );
    System.assertEquals(
      'Id',
      fieldSetWrapperList[0].FieldName,
      '> The first field set wrapper member name should be Id'
    );
    for (Integer i = 1; i < fieldSetWrapperList.size(); i++) {
      System.assertEquals(
        String.valueOf(fieldSet[i - 1].getType()),
        fieldSetWrapperList[i].FieldType,
        '> Type mismatch between original field set member and wrapper item'
      );
      System.assertEquals(
        String.valueOf(fieldSet[i - 1].getFieldPath()),
        fieldSetWrapperList[i].FieldName,
        '> Field path mismatch between original field set member and wrapper item'
      );
    }
  }
}
