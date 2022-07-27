//Testclass: CaseTriggerTest
public class CaseTriggerHelper {
  public static List<Map<String, sObject>> getPlanetsFromCases(List<sObject> newList) {
    List<Map<String, sObject>> mapContainerList = new List<Map<String, sObject>>();
    Map<String, Planet__c> planetMap = new Map<String, Planet__c>();
    Map<String, Case> caseMap = new Map<String, Case>();
    // iterate over the Trigger.new list of Cases and gather the information related to the
    // Planets of said Cases
    for (Case caseElem : (List<Case>) newList) {
      // get the required information for initializing a Planet in the DB
      List<String> splitSubject = caseElem.Subject.split('-');
      List<String> splitDescription = caseElem.Description.split(':');
      if (!isEmailWellFormed(splitSubject, splitDescription))
        continue;
      String planetName = splitSubject[1].trim();
      String planetCode = splitDescription[1].trim();
      // create a new Planet, add it to the Planets list and return the list
      Planet__c newPlanet = new Planet__c();
      newPlanet.Name = planetName;
      newPlanet.Code__c = planetCode;
      // add the planet and the case to the maps using the code external Id as key
      planetMap.put(planetCode, newPlanet);
      caseMap.put(planetCode, caseElem);
    }
    mapContainerList.add(planetMap);
    mapContainerList.add(caseMap);
    return mapContainerList;
  }

  public static Integer setLookupRelationship(Map<String, Planet__c> planetMap, Map<String, Case> caseMap) {
    Integer casesUpdatedCount = 0;
    // iterate over the planet map, if the Id for the map is not null then it was inserted into the DB
    // use the code from the planet map to access the case map and update the relationship
    for (String code : planetMap.keySet()) {
      Planet__c planet = planetMap.get(code);
      if (planet.Id != null) {
        Case caseElem = caseMap.get(code);
        caseElem.Planet__c = planet.Id;
        casesUpdatedCount++;
      }
    }
    return casesUpdatedCount;
  }

  @testVisible
  private static Boolean isEmailWellFormed(List<String> splitSubject, List<String> splitDescription) {
    // if the subject or the body of the email when splitted by the respective characters don't
    // return two elements in each string array, then the email is ill-formed
    if (splitSubject.size() != 2 || splitDescription.size() != 2)
      return false;
    String processedSubj = splitSubject[0].trim().toLowerCase();
    String processedDesc = splitDescription[0].trim().toLowerCase();
    List<String> subjectKeywords = new List<String>{ 'solicitud', 'escaneo' };
    List<String> descKeywords = new List<String>{ 'acceso', 'sistema', 'escaneo', 'interplanetario' };
    // if the subject or the body of the email don't contain their information with the respective
    // keywords then the email is ill-formed
    for (String keyword : subjectKeywords) {
      if (!processedSubj.contains(keyword))
        return false;
    }
    for (String keyword : descKeywords) {
      if (!processedDesc.contains(keyword))
        return false;
    }
    return true;
  }

  public static Integer printDatabaseErrors(Database.UpsertResult[] srList) {
    // error debugging for upsert results
    Integer errorCount = 0;
    for (Database.UpsertResult sr : srList) {
      if (!sr.isSuccess()) {
        for (Database.Error err : sr.getErrors()) {
          printDatabaseError(err);
          errorCount++;
        }
      }
    }
    return errorCount;
  }

  private static void printDatabaseError(Database.Error err) {
    System.debug('> the following error has occurred.');
    System.debug('> ' + err.getStatusCode() + ': ' + err.getMessage());
    System.debug('> fields that affected this error: ' + err.getFields());
  }
}
