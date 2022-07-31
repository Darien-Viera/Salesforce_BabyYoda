//Testclass: InterplanetaryCasesControllerTest
public class InterplanetaryCasesController {
  public class QueryWrapper {
    // wrapper object for handling the queried objects based on the Interplanetary
    // Cases Field Set and the field set itself
    @AuraEnabled
    public List<FieldSetMemberWrapper> FieldSetMembers { get; private set; }
    @AuraEnabled
    public List<Case> CaseList { get; private set; }

    public QueryWrapper(List<FieldSetMemberWrapper> fieldSet, List<Case> cases) {
      FieldSetMembers = fieldSet;
      CaseList = cases;
    }
  }

  public class FieldSetMemberWrapper {
    // wrapper object used in the QueryWrapper to send the necessary information for
    // each field set member
    @AuraEnabled
    public String FieldType { get; private set; }
    @AuraEnabled
    public String FieldName { get; private set; }

    private FieldSetMemberWrapper(String type, String name) {
      FieldType = type;
      FieldName = name;
    }
  }

  @AuraEnabled
  public static List<Case> getFiveOldestCases() {
    // returns a case list with the five oldest opened interplanetary cases, a case is
    // considered interplanetary when it contains a link to a planet record
    return [
      SELECT
        Id,
        CaseNumber,
        Status,
        Subject,
        Contact.Id,
        Contact.Name,
        Contact.Email,
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

  @AuraEnabled
  public static QueryWrapper getFiveOldestCasesAndFieldSet() {
    // query over the field set for the interplanetary cases
    List<Schema.FieldSetMember> fieldSet = SObjectType.Case.FieldSets.Interplanetary_Cases_Field_Set.getFields();
    // initializes the list of field set member wrappers
    List<FieldSetMemberWrapper> fieldSetWrapper = processFieldSet(fieldSet);
    // initializes the fields string to be used as query
    String fields = 'Id, ';
    for (Integer i = 0; i < fieldSet.size() - 1; i++) {
      fields += fieldSet[i].getFieldPath() + ', ';
    }
    fields += fieldSet[fieldSet.size() - 1].getFieldPath();
    String query = 'SELECT ' + fields;
    query += ' FROM Case WHERE IsClosed = FALSE AND Planet__c != NULL ORDER BY CreatedDate ASC LIMIT 5';
    List<SObject> casesList = Database.query(query);
    return new QueryWrapper(fieldSetWrapper, (List<Case>) casesList);
  }

  @testVisible
  private static List<FieldSetMemberWrapper> processFieldSet(List<Schema.FieldSetMember> fieldSet) {
    // the Id field for the case is always queried and sent in the mapping
    List<FieldSetMemberWrapper> processed = new List<FieldSetMemberWrapper>{ new FieldSetMemberWrapper('ID', 'Id') };
    for (Schema.FieldSetMember fieldSetElem : fieldSet) {
      String type = String.valueOf(fieldSetElem.getType());
      String name = String.valueOf(fieldSetElem.getFieldPath());
      // adds a new field set wrapper item to the list with the type and name as strings
      processed.add(new FieldSetMemberWrapper(type, name));
    }
    return processed;
  }
}
