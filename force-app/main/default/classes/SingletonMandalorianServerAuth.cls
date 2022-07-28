//Testclass: MandalorianServerAPIHandlerTest
public class SingletonMandalorianServerAuth {
  public String Endpoint { get; private set; }
  public String Password { get; private set; }
  public String Type { get; private set; }
  public String User { get; private set; }
  public Map<String, Access_Code_Settings__mdt> AccessCodes { get; private set; }
  private static SingletonMandalorianServerAuth instance = null;

  // singleton class that contains the authentication credentials for the Mandalorian Server
  // and the metadata for the planet codes, the singleton pattern is used to avoid doing
  // unnecessary queries over the metadata
  public SingletonMandalorianServerAuth() {
    initCredentials();
    initPlanetAccessCodes();
  }

  // getInstance function for the singleton pattern
  public static SingletonMandalorianServerAuth getInstance() {
    if (instance == null)
      instance = new SingletonMandalorianServerAuth();
    return instance;
  }

  // query and initialize the credentials from the metadata
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

  // query and initialize the planet access codes from the metadata
  private void initPlanetAccessCodes() {
    AccessCodes = new Map<String, Access_Code_Settings__mdt>();
    List<Access_Code_Settings__mdt> data = [SELECT Id, Planet_Code__c, Access_Code__c FROM Access_Code_Settings__mdt];
    for (Access_Code_Settings__mdt elem : data) {
      AccessCodes.put(elem.Planet_Code__c, elem);
    }
  }

  // auxiliar function used for testing
  @testVisible
  private void setAuthDataNull() {
    Endpoint = null;
    Type = null;
    User = null;
    Password = null;
  }
}
