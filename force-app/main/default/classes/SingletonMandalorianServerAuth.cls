//Testclass: MandalorianServerAPIHandlerTest
public class SingletonMandalorianServerAuth {
  public String Endpoint { get; private set; }
  public String Password { get; private set; }
  public String Type { get; private set; }
  public String User { get; private set; }
  public Map<String, Access_Code_Settings__mdt> AccessCodes { get; private set; }
  private static SingletonMandalorianServerAuth instance = null;

  public SingletonMandalorianServerAuth() {
    initCredentials();
    initPlanetAccessCodes();
  }

  public static SingletonMandalorianServerAuth getInstance() {
    if (instance == null)
      instance = new SingletonMandalorianServerAuth();
    return instance;
  }

  private void initCredentials() {
    List<Integration_Credential__mdt> data = [
      SELECT Id, EndPoint__c, Password__c, Type__c, User__c
      FROM Integration_Credential__mdt
      WHERE Label = 'Mandalorian-Server'
      LIMIT 1
    ];
    if (data.size() != 1)
      return;
    Endpoint = data[0].EndPoint__c;
    Type = data[0].Type__c;
    User = data[0].User__c;
    Password = data[0].Password__c;
  }

  private void initPlanetAccessCodes() {
    AccessCodes = new Map<String, Access_Code_Settings__mdt>();
    List<Access_Code_Settings__mdt> data = [SELECT Id, Planet_Code__c, Access_Code__c FROM Access_Code_Settings__mdt];
    for (Access_Code_Settings__mdt elem : data) {
      AccessCodes.put(elem.Planet_Code__c, elem);
    }
  }

  @testVisible
  private void setAuthDataNull() {
    Endpoint = null;
    Type = null;
    User = null;
    Password = null;
  }
}
