//Testclass: CaseTriggerTest
public class CaseTriggerHandler {
  public static String runBeforeInsert(List<SObject> newList) {
    List<Map<String, SObject>> mapContainerList = CaseTriggerHelper.getPlanetsFromCases(newList);
    // the getPlanetsFromCases function must return two maps: <Code, Planet__c> and <Code, Case>
    if (mapContainerList.size() != 2)
      return 'FAIL';
    Map<String, Planet__c> planetMap = (Map<String, Planet__c>) mapContainerList[0];
    Map<String, Case> caseMap = (Map<String, Case>) mapContainerList[1];
    // since the external Id field Code__c is defined to contain only unique values, it's used
    // as filter for upserting the Planets records
    Database.UpsertResult[] srList = Database.upsert(planetMap.values(), Planet__c.fields.Code__c, false);
    // update the Case objects with the relationship to the inserted planets
    Integer casesUpdatedCount = CaseTriggerHelper.setLookupRelationship(planetMap, caseMap);
    // handle and print the errors
    Integer errorCount = CaseTriggerHelper.printDatabaseErrors(srList);
    // planets inserted == cases updated
    // planetMap.size() - errorCount == casesUpdatedCount
    System.debug('> cases processed ' + newList.size());
    System.debug('> planets inserted ' + (planetMap.size() - errorCount));
    System.debug('> cases updated ' + casesUpdatedCount);
    System.debug('> errors found ' + errorCount);
    return 'SUCCESS';
  }

  public static String runBeforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
    return 'NOT IMPLEMENTED';
  }

  public static String runBeforeDelete(Map<Id, SObject> oldMap) {
    return 'NOT IMPLEMENTED';
  }

  public static String runAfterInsert(Map<Id, SObject> newMap) {
    return 'NOT IMPLEMENTED';
  }

  public static String runAfterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
    return 'NOT IMPLEMENTED';
  }

  public static String runAfterDelete(Map<Id, SObject> oldMap) {
    return 'NOT IMPLEMENTED';
  }

  public static String runAfterUndelete(Map<Id, SObject> newMap) {
    return 'NOT IMPLEMENTED';
  }
}
