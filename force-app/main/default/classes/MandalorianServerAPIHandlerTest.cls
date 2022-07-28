@isTest
public class MandalorianServerAPIHandlerTest {
  @TestSetup
  public static void makeData() {
    List<Access_Code_Settings__mdt> data = [SELECT Id, Planet_Code__c, Access_Code__c FROM Access_Code_Settings__mdt];
    System.assertNotEquals(0, data.size(), '> AccessCodeSettings mdt must contain at least one record');
    List<Integration_Credential__mdt> data2 = [
      SELECT Id
      FROM Integration_Credential__mdt
      WHERE Label = 'Mandalorian-Server'
      LIMIT 1
    ];
    System.assertNotEquals(0, data2.size(), '> IntegrationCredential mdt must contain the Mandalorian Server record');
  }

  @isTest
  public static void testSingletonMandalorianServerAuth() {
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
}
