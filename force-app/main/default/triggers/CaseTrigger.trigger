//Testclass: CaseTriggerTest
trigger CaseTrigger on Case(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  // the string result is not being used for any useful logic now but to assert that the
  // placeholder functions are NOT IMPLEMENTED yet, the SUCCESS or FAIL status from the
  // runBeforeInsert handler function could be used in future functionalities
  String result = null;
  switch on (Trigger.operationType) {
    when BEFORE_INSERT {
      result = CaseTriggerHandler.runBeforeInsert(Trigger.new);
    }
    when BEFORE_UPDATE {
      result = CaseTriggerHandler.runBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
    when BEFORE_DELETE {
      result = CaseTriggerHandler.runBeforeDelete(Trigger.oldMap);
    }
    when AFTER_INSERT {
      result = CaseTriggerHandler.runAfterInsert(Trigger.newMap);
    }
    when AFTER_UPDATE {
      result = CaseTriggerHandler.runAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
    when AFTER_DELETE {
      result = CaseTriggerHandler.runAfterDelete(Trigger.oldMap);
    }
    when AFTER_UNDELETE {
      result = CaseTriggerHandler.runAfterUndelete(Trigger.newMap);
    }
  }
  System.debug('> trigger executed ' + Trigger.operationType);
  System.debug('> return status ' + result);
}
