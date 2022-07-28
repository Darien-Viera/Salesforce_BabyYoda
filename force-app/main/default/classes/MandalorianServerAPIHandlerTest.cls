@isTest
public class MandalorianServerAPIHandlerTest {
  @TestSetup
  public static void makeData() {
    // it's required for the tests to work that the Mandalorian Server credentials and the Entry1 planet access
    // code exist in metadata, so both metadatas are queried, asserted their values, and a case is inserted to test
    // the server status code 200, the case trigger is required to run in order for the corresponding planet to be
    // inserted along the case, so there's an assertion in the end to check if the planet was inserted successfully
    List<Access_Code_Settings__mdt> data = [
      SELECT Id, Planet_Code__c
      FROM Access_Code_Settings__mdt
      WHERE Label = 'Entry1'
      LIMIT 1
    ];
    System.assertEquals(1, data.size(), '> AccessCodeSettings mdt must contain the Entry1 record');
    List<Integration_Credential__mdt> data2 = [
      SELECT Id
      FROM Integration_Credential__mdt
      WHERE Label = 'Mandalorian-Server'
      LIMIT 1
    ];
    System.assertEquals(1, data2.size(), '> IntegrationCredential mdt must contain the Mandalorian Server record');
    String planetCode = data[0].Planet_Code__c;
    Case newCase = new Case();
    newCase.Subject = 'Solicitud de escaneo - TESTPLANET';
    newCase.Description = 'Codigo de acceso al sistema de escaneo interplanetario: ' + planetCode;
    insert newCase;
    List<Planet__c> planetList = [SELECT Id, Code__c FROM Planet__c WHERE Code__c = :planetCode LIMIT 1];
    System.assertEquals(1, planetList.size(), '> CaseTrigger must have inserted one corresponding planet');
  }

  @isTest
  public static void testSingletonMandalorianServerAuth() {
    // positive test for the singleton class
    test.startTest();
    SingletonMandalorianServerAuth instance = SingletonMandalorianServerAuth.getInstance();
    test.stopTest();
    System.assertNotEquals(null, instance.Endpoint, '> getInstance should have returned values for the Endpoint');
    System.assertNotEquals(null, instance.Type, '> getInstance should have returned values for the Type');
    System.assertNotEquals(null, instance.User, '> getInstance should have returned values for the User');
    System.assertNotEquals(null, instance.Password, '> getInstance should have returned values for the Password');
    System.assertNotEquals(0, instance.AccessCodes.size(), '> getInstance should contain values for the AccessCodes');
  }

  @isTest
  public static void testServerAuthIsMissingData() {
    // negative test for the singleton class and for the serverAuthIsMissingData function in the MandalorianServerAPIHandler
    test.startTest();
    SingletonMandalorianServerAuth instance = SingletonMandalorianServerAuth.getInstance();
    Boolean result = MandalorianServerAPIHandler.serverAuthIsMissingData(instance);
    instance.setAuthDataNull();
    Boolean resultNeg = MandalorianServerAPIHandler.serverAuthIsMissingData(instance);
    test.stopTest();
    System.assertEquals(false, result, '> serverAuthIsMissingData should have returned false');
    System.assertEquals(true, resultNeg, '> serverAuthIsMissingData negative should have returned true');
  }

  @isTest
  public static void testResponseWrapper() {
    // positive and negative tests for the auxiliar wrapper object used to return the information related with the callout
    // to the visual component
    test.startTest();
    MandalorianServerAPIHandler.ResponseWrapper resp = new MandalorianServerAPIHandler.ResponseWrapper('SUCCESS', 'a');
    MandalorianServerAPIHandler.ResponseWrapper resp2 = new MandalorianServerAPIHandler.ResponseWrapper('ERROR', 'a');
    MandalorianServerAPIHandler.ResponseWrapper resp3 = new MandalorianServerAPIHandler.ResponseWrapper('WARNING', 'a');
    MandalorianServerAPIHandler.ResponseWrapper resp4 = new MandalorianServerAPIHandler.ResponseWrapper('INFO', 'a');
    MandalorianServerAPIHandler.ResponseWrapper respNeg = new MandalorianServerAPIHandler.ResponseWrapper('', 'a');
    test.stopTest();
    System.assertEquals('SUCCESS', resp.ToastType, '> ResponseWrapper should be of Toast Type SUCCESS');
    System.assertEquals('ERROR', resp2.ToastType, '> ResponseWrapper should be of Toast Type ERROR');
    System.assertEquals('WARNING', resp3.ToastType, '> ResponseWrapper should be of Toast Type WARNING');
    System.assertEquals('INFO', resp4.ToastType, '> ResponseWrapper should be of Toast Type INFO');
    System.assertEquals('ERROR', respNeg.ToastType, '> ResponseWrapper negative should be of Toast Type ERROR');
    System.assertEquals('Invalid toast type passed as argument to the Response Wrapper', respNeg.Payload);
  }

  @isTest
  public static void testHandleCallout200() {
    // server status 200 callout positive testing, the case is queried at the end to check that the Successful Scan and
    // Status fields were updated correctly
    Test.setMock(HttpCalloutMock.class, new MandalorianServerMock.MandalorianServerMock200());
    List<Access_Code_Settings__mdt> data = [
      SELECT Id, Planet_Code__c
      FROM Access_Code_Settings__mdt
      WHERE Label = 'Entry1'
      LIMIT 1
    ];
    String planetCode = data[0].Planet_Code__c;
    test.startTest();
    MandalorianServerAPIHandler.ResponseWrapper res = MandalorianServerAPIHandler.handleCallout(data[0].Planet_Code__c);
    test.stopTest();
    System.assertEquals('SUCCESS', res.ToastType, '> ResponseWrapper should be of Toast Type SUCCESS');
    System.assertEquals('Scan successful! Was Baby Yoda found? -> true', res.Payload);
    List<Case> caseList = [
      SELECT Id, IsClosed, Successful_Scan__c, Planet__r.Code__c
      FROM Case
      WHERE Planet__r.Code__c = :planetCode
      LIMIT 1
    ];
    System.assertEquals(
      true,
      caseList[0].Successful_Scan__c,
      '> handleCallout should have marked the case as true in the Successful Scan field'
    );
    System.assertEquals(
      true,
      caseList[0].IsClosed,
      '> handleCallout should have marked the case as true in the IsClosed field'
    );
  }

  @isTest
  public static void testHandleCallout200Negative() {
    // server status 200 callout negative testing, the case is queried at the end to check that the Successful Scan and
    // Status fields were left untouched
    Test.setMock(HttpCalloutMock.class, new MandalorianServerMock.MandalorianServerMock200Negative());
    List<Access_Code_Settings__mdt> data = [
      SELECT Id, Planet_Code__c
      FROM Access_Code_Settings__mdt
      WHERE Label = 'Entry1'
      LIMIT 1
    ];
    String planetCode = data[0].Planet_Code__c;
    test.startTest();
    MandalorianServerAPIHandler.ResponseWrapper res = MandalorianServerAPIHandler.handleCallout(planetCode);
    test.stopTest();
    System.assertEquals('ERROR', res.ToastType, '> handleCallout should be of Toast Type ERROR');
    System.assertEquals('Unexpected body returned \nPayload returned: {"negative" : true}', res.Payload);
    List<Case> caseList = [
      SELECT Id, IsClosed, Successful_Scan__c, Planet__r.Code__c
      FROM Case
      WHERE Planet__r.Code__c = :planetCode
      LIMIT 1
    ];
    System.assertEquals(
      false,
      caseList[0].Successful_Scan__c,
      '> handleCallout should have left the case marked as false in the Successful Scan field'
    );
    System.assertEquals(
      false,
      caseList[0].IsClosed,
      '> handleCallout should have left the case marked as false in the IsClosed field'
    );
  }

  @isTest
  public static void testHandleCallout400() {
    Test.setMock(HttpCalloutMock.class, new MandalorianServerMock.MandalorianServerMock400());
    List<Access_Code_Settings__mdt> data = [
      SELECT Id, Planet_Code__c
      FROM Access_Code_Settings__mdt
      WHERE Label = 'Entry1'
      LIMIT 1
    ];
    String planetCode = data[0].Planet_Code__c;
    test.startTest();
    MandalorianServerAPIHandler.ResponseWrapper res = MandalorianServerAPIHandler.handleCallout(planetCode);
    test.stopTest();
    System.assertEquals('WARNING', res.ToastType, '> handleCallout should be of Toast Type WARNING');
    System.assertEquals('Bad planet access code positive testing', res.Payload);
  }

  @isTest
  public static void testHandleCallout400Negative() {
    Test.setMock(HttpCalloutMock.class, new MandalorianServerMock.MandalorianServerMock400Negative());
    List<Access_Code_Settings__mdt> data = [
      SELECT Id, Planet_Code__c
      FROM Access_Code_Settings__mdt
      WHERE Label = 'Entry1'
      LIMIT 1
    ];
    String planetCode = data[0].Planet_Code__c;
    test.startTest();
    MandalorianServerAPIHandler.ResponseWrapper res = MandalorianServerAPIHandler.handleCallout(planetCode);
    test.stopTest();
    System.assertEquals('WARNING', res.ToastType, '> handleCallout should be of Toast Type WARNING');
    System.assertEquals('Bad planet access code', res.Payload);
  }

  @isTest
  public static void testHandleCallout401() {
    Test.setMock(HttpCalloutMock.class, new MandalorianServerMock.MandalorianServerMock401());
    List<Access_Code_Settings__mdt> data = [
      SELECT Id, Planet_Code__c
      FROM Access_Code_Settings__mdt
      WHERE Label = 'Entry1'
      LIMIT 1
    ];
    String planetCode = data[0].Planet_Code__c;
    test.startTest();
    MandalorianServerAPIHandler.ResponseWrapper res = MandalorianServerAPIHandler.handleCallout(planetCode);
    test.stopTest();
    System.assertEquals('WARNING', res.ToastType, '> handleCallout should be of Toast Type WARNING');
    System.assertEquals('Bad or missing authentication positive testing', res.Payload);
  }

  @isTest
  public static void testHandleCallout401Negative() {
    Test.setMock(HttpCalloutMock.class, new MandalorianServerMock.MandalorianServerMock401Negative());
    List<Access_Code_Settings__mdt> data = [
      SELECT Id, Planet_Code__c
      FROM Access_Code_Settings__mdt
      WHERE Label = 'Entry1'
      LIMIT 1
    ];
    String planetCode = data[0].Planet_Code__c;
    test.startTest();
    MandalorianServerAPIHandler.ResponseWrapper res = MandalorianServerAPIHandler.handleCallout(planetCode);
    test.stopTest();
    System.assertEquals('WARNING', res.ToastType, '> handleCallout should be of Toast Type WARNING');
    System.assertEquals('Bad or missing authentication', res.Payload);
  }

  @isTest
  public static void testHandleCallout500() {
    Test.setMock(HttpCalloutMock.class, new MandalorianServerMock.MandalorianServerMock500());
    List<Access_Code_Settings__mdt> data = [
      SELECT Id, Planet_Code__c
      FROM Access_Code_Settings__mdt
      WHERE Label = 'Entry1'
      LIMIT 1
    ];
    String planetCode = data[0].Planet_Code__c;
    test.startTest();
    MandalorianServerAPIHandler.ResponseWrapper res = MandalorianServerAPIHandler.handleCallout(planetCode);
    test.stopTest();
    System.assertEquals('WARNING', res.ToastType, '> handleCallout should be of Toast Type WARNING');
    System.assertEquals('Internal server error positive testing', res.Payload);
  }

  @isTest
  public static void testHandleCallout500Negative() {
    Test.setMock(HttpCalloutMock.class, new MandalorianServerMock.MandalorianServerMock500Negative());
    List<Access_Code_Settings__mdt> data = [
      SELECT Id, Planet_Code__c
      FROM Access_Code_Settings__mdt
      WHERE Label = 'Entry1'
      LIMIT 1
    ];
    String planetCode = data[0].Planet_Code__c;
    test.startTest();
    MandalorianServerAPIHandler.ResponseWrapper res = MandalorianServerAPIHandler.handleCallout(planetCode);
    test.stopTest();
    System.assertEquals('WARNING', res.ToastType, '> handleCallout should be of Toast Type WARNING');
    System.assertEquals('Internal server error', res.Payload);
  }

  @isTest
  public static void testHandleCalloutWrongStatus() {
    Test.setMock(HttpCalloutMock.class, new MandalorianServerMock.MandalorianServerMockWrongStatus());
    List<Access_Code_Settings__mdt> data = [
      SELECT Id, Planet_Code__c
      FROM Access_Code_Settings__mdt
      WHERE Label = 'Entry1'
      LIMIT 1
    ];
    String planetCode = data[0].Planet_Code__c;
    test.startTest();
    MandalorianServerAPIHandler.ResponseWrapper res = MandalorianServerAPIHandler.handleCallout(planetCode);
    test.stopTest();
    System.assertEquals('ERROR', res.ToastType, '> handleCallout should be of Toast Type ERROR');
    System.assertEquals(
      'Unexpected status code returned \nPayload returned: {"crazy" : "The server went crazy :P"}',
      res.Payload
    );
  }
}
