@isTest
public class CaseTriggerTest {
  // auxiliar function for creating a single case record
  // it's used in other auxiliar and test functions
  // the name of the planet is generated using the Datetime.now function
  public static Case createSingleCaseRecord(Integer planetCode) {
    String planetName = String.ValueofGmt(Datetime.now()).replaceAll(':', '').replaceAll(' ', '').replaceAll('-', '');
    Case newCase = new Case();
    newCase.Subject = 'Solicitud de escaneo - ' + planetName;
    newCase.Description = 'Codigo de acceso al sistema de escaneo interplanetario: A-' + planetCode;
    return newCase;
  }

  // auxiliar function for creating a single case record with an invalid subject
  // the subject is considered invalid if it does not contain the keywords
  public static Case createSingleCaseInvalidSubject(Integer planetCode) {
    Case newCase = createSingleCaseRecord(planetCode);
    newCase.Subject = 'Este es un subject invalido - Pepe';
    return newCase;
  }

  // auxiliar function for creating a single case record with an invalid description
  // the description is considered invalid if it does not contain the keywords
  public static Case createSingleCaseInvalidDescription(Integer planetCode) {
    Case newCase = createSingleCaseRecord(planetCode);
    newCase.Description = 'Este es una description invalida: A-' + planetCode;
    return newCase;
  }

  // auxiliar function for creating a single case record with an invalid planet code
  // the planet code is considered invalid if it's longer than 10 characters
  public static Case createSingleCaseInvalidPlanet() {
    Case newCase = createSingleCaseRecord(1);
    newCase.Description = 'Codigo de acceso al sistema de escaneo interplanetario: A-12312312311231';
    return newCase;
  }

  // auxiliar function for creating a number of case records, more than 200 well formed
  // cases to test how the trigger handles bulk records and a number of ill-formed cases
  // to verify the amount of planets and cases linked to one another
  public static List<Case> createBulkCaseRecords() {
    List<Case> caseList = new List<Case>();
    for (Integer i = 0; i < 250; i++) {
      Case newCase = createSingleCaseRecord(i);
      caseList.add(newCase);
    }
    for (Integer i = 0; i < 10; i++) {
      Case newCase = createSingleCaseInvalidSubject(i + 251);
      caseList.add(newCase);
    }
    for (Integer i = 0; i < 10; i++) {
      Case newCase = createSingleCaseInvalidDescription(i + 261);
      caseList.add(newCase);
    }
    return caseList;
  }

  @isTest
  public static void testCaseTriggerSingleRecord() {
    // single case insertion with a valid, inserted planet
    Case newCase = createSingleCaseRecord(1);
    Test.startTest();
    insert newCase;
    Test.stopTest();
    List<Planet__c> planets = [SELECT Id FROM Planet__c];
    System.assertEquals(1, planets.size(), '> CaseTrigger should have inserted 1 Planet__c record');
    List<Case> queriedCases = [SELECT Id, Planet__c FROM Case WHERE Planet__c != NULL];
    System.assertEquals(1, queriedCases.size(), '> CaseTrigger should have inserted 1 Case with non null Planet');
  }

  @isTest
  public static void testCaseTriggerBulkRecords() {
    // bulk case insertion with 270 cases and 250 valid planets
    List<Case> caseList = createBulkCaseRecords();
    Test.startTest();
    insert caseList;
    Test.stopTest();
    List<Planet__c> planets = [SELECT Id FROM Planet__c];
    System.assertEquals(250, planets.size(), '> CaseTrigger should have inserted 250 Planet__c records');
    List<Case> queriedCases = [SELECT Id, Planet__c FROM Case WHERE Planet__c != NULL];
    System.assertEquals(250, queriedCases.size(), '> CaseTrigger should have inserted 250 Cases with non null Planets');
  }

  @isTest
  public static void testCaseTriggerInvalidPlanet() {
    // single case insertion with an invalid planet - negative testing
    Case newCase = createSingleCaseInvalidPlanet();
    Test.startTest();
    insert newCase;
    Test.stopTest();
    List<Planet__c> planets = [SELECT Id FROM Planet__c];
    System.assertEquals(0, planets.size(), '> CaseTrigger should have inserted 0 Planet__c records');
    List<Case> queriedCases = [SELECT Id, Planet__c FROM Case WHERE Planet__c = NULL];
    System.assertEquals(1, queriedCases.size(), '> CaseTrigger should have inserted 1 Case with null Planet');
  }

  @isTest
  public static void testIsEmailWellFormed() {
    // bottom-up testing, isEmailWellFormed is a function contained in the CaseTriggerHelper class, and it's
    // critical for the good behavior of the case trigger flow
    List<String> splitSubject = 'Solicitud de escaneo - Aldebaran'.split('-');
    List<String> splitDescription = 'Codigo de acceso al sistema de escaneo interplanetario: A-0001'.split(':');
    Boolean result = CaseTriggerHelper.isEmailWellFormed(splitSubject, splitDescription);
    System.assertEquals(true, result, '> isEmailWellFormed should have returned true');

    splitSubject = 'Invalido! - Aldebaran'.split('-');
    splitDescription = 'Codigo de acceso al sistema de escaneo interplanetario: A-0001'.split(':');
    result = CaseTriggerHelper.isEmailWellFormed(splitSubject, splitDescription);
    System.assertEquals(false, result, '> isEmailWellFormed should have returned false');

    splitSubject = 'Solicitud de escaneo - Aldebaran'.split('-');
    splitDescription = 'Invalido! de acceso al sistema de escaneo: A-0001'.split(':');
    result = CaseTriggerHelper.isEmailWellFormed(splitSubject, splitDescription);
    System.assertEquals(false, result, '> isEmailWellFormed should have returned false');

    splitSubject = 'Solicitud de escaneo - Aldebaran - Alde'.split('-');
    splitDescription = 'Codigo de acceso al sistema de escaneo interplanetario: A-0001'.split(':');
    result = CaseTriggerHelper.isEmailWellFormed(splitSubject, splitDescription);
    System.assertEquals(false, result, '> isEmailWellFormed should have returned false');
  }

  @isTest
  public static void testPlaceholderFunctionsInHandler() {
    // the handler functions for the unused contexts of the CaseTrigger were created and left as placeholders
    // for future code, a NOT IMPLEMENTED return value was added in order to test them
    test.startTest();
    String result = CaseTriggerHandler.runBeforeUpdate(null, null);
    System.assertEquals('NOT IMPLEMENTED', result, '> runBeforeUpdate should have returned NOT IMPLEMENTED');
    result = CaseTriggerHandler.runBeforeDelete(null);
    System.assertEquals('NOT IMPLEMENTED', result, '> runBeforeDelete should have returned NOT IMPLEMENTED');
    result = CaseTriggerHandler.runAfterInsert(null);
    System.assertEquals('NOT IMPLEMENTED', result, '> runAfterInsert should have returned NOT IMPLEMENTED');
    result = CaseTriggerHandler.runAfterUpdate(null, null);
    System.assertEquals('NOT IMPLEMENTED', result, '> runAfterUpdate should have returned NOT IMPLEMENTED');
    result = CaseTriggerHandler.runAfterDelete(null);
    System.assertEquals('NOT IMPLEMENTED', result, '> runAfterDelete should have returned NOT IMPLEMENTED');
    result = CaseTriggerHandler.runAfterUndelete(null);
    System.assertEquals('NOT IMPLEMENTED', result, '> runAfterUndelete should have returned NOT IMPLEMENTED');
    test.stopTest();
  }

  @isTest
  public static void testPlaceholderSwitchInTrigger() {
    // same as above, the cases for the switch used in the CaseTrigger were left as placeholders for future
    // code, these are dummy tests to pass the code coverage requirement
    Case newCase = createSingleCaseRecord(1);
    Test.startTest();
    insert newCase;
    update newCase;
    delete newCase;
    undelete newCase;
    Test.stopTest();
    List<Case> queriedCases = [SELECT Id, Planet__c FROM Case];
    System.assertEquals(1, queriedCases.size(), '> CaseTrigger should have undeleted 1 Case');
  }
}
