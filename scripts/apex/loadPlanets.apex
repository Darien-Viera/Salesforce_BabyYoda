// script for inserting a number of planets into the DB using the python script
// parsePlanetsIntoMultiline.py to convert a csv into a multiline string

// the first line of this script must be a string named planets, copied from the
// file generated with the python script mentioned before and renamed to planets
String planets =
  'Name;External_id__c\n' +
  'Alderaan;A-00001\n' +
  'Aleen Minor;AM-00002\n' +
  'Bespin;B-00003\n' +
  'Bestine IV;BI-00004\n' +
  'Cato Neimoidia;CN-00005\n' +
  'Cerea;C-00006\n' +
  'Champala;C-00007\n' +
  'Chandrila;C-00008\n' +
  'Concord Dawn;CD-00009\n' +
  'Corellia;C-00010\n' +
  'Coruscant;C-00011\n' +
  'Dagobah;D-00012\n' +
  'Dantooine;D-00013\n' +
  'Dathomir;D-00014\n' +
  'Dorin;D-00015\n' +
  'Endor;E-00016\n' +
  'Eriadu;E-00017\n' +
  'Felucia;F-00018\n' +
  'Geonosis;G-00019\n' +
  'Glee Anselm;GA-00020\n' +
  'Haruun Kal;HK-00021\n' +
  'Hoth;H-00022\n' +
  'Iktotch;I-00023\n' +
  'Iridonia;I-00024\n' +
  'Jakku;J-00025\n' +
  'Kalee;K-00026\n' +
  'Kamino;K-00027\n' +
  'Kashyyyk;K-00028\n' +
  'Malastare;M-00029\n' +
  'Mirial;M-00030\n' +
  'Mon Cala;MC-00031\n' +
  'Mustafar;M-00032\n' +
  'Muunilinst;M-00033\n' +
  'Mygeeto;M-00034\n' +
  'Naboo;N-00035\n' +
  'Nal Hutta;NH-00036\n' +
  'Ojom;O-00037\n' +
  'Ord Mantell;OM-00038\n' +
  'Polis Massa;PM-00039\n' +
  'Quermia;Q-00040\n' +
  'Rodia;R-00041\n' +
  'Ryloth;R-00042\n' +
  'Saleucami;S-00043\n' +
  'Serenno;S-00044\n' +
  'Shili;S-00045\n' +
  'Skako;S-00046\n' +
  'Socorro;S-00047\n' +
  'Stewjon;S-00048\n' +
  'Sullust;S-00049\n' +
  'Tatooine;T-00050\n' +
  'Tholoth;T-00051\n' +
  'Toydaria;T-00052\n' +
  'Trandosha;T-00053\n' +
  'Troiken;T-00054\n' +
  'Tund;T-00055\n' +
  'Umbara;U-00056\n' +
  'Utapau;U-00057\n' +
  'Vulpter;V-00058\n' +
  'Yavin IV;YI-00059\n' +
  'Zolan;Z-00060';

// prepare the required variables to iterate over the planets string
// each line will be splitted one from the other using the newline character
// values inside a line will be splitted using the semicolon character
String[] planetsArray = planets.split('\n');
String[] fieldsArray = planetsArray[0].split(';');
Integer numberOfFields = fieldsArray.size();
List<String> errors = new List<String>();
// the planetsToUpsert list will be filled with the planets records to upsert
List<Planet__c> planetsToUpsert = new List<Planet__c>();
for (Integer i = 1; i < planetsArray.size(); i++) {
  String[] planetInfo = planetsArray[i].split(';');
  // if the information for a planet does not contain the same number of fields
  // provided in the header of the planets string, an error is added and said
  // planet is skipped
  if (planetInfo.size() != numberOfFields) {
    errors.add(planetsArray[i]);
    continue;
  }
  // a new planet is created and the value for each field is added dynamically
  Planet__c newPlanet = new Planet__c();
  SObjectType planetSObjectType = Schema.getGlobalDescribe().get('Planet__c');
  Map<String, Schema.SObjectField> planetFieldsMap = planetSObjectType.getDescribe().fields.getMap();
  for (Integer j = 0; j < numberOfFields; j++) {
    // the external id field is being mapped with the Code__c field
    String fieldToGet = (fieldsArray[j].toLowerCase() == 'external_id__c') ? 'Code__c' : fieldsArray[j];
    SObjectField field = planetFieldsMap.get(fieldToGet);
    newPlanet.put(field, planetInfo[j]);
  }
  planetsToUpsert.add(newPlanet);
}
if (planetsToUpsert.size() > 0) {
  System.debug('> ' + planetsToUpsert.size() + ' planets will be inserted');
  // check if any of the provided fields can be used as the key for the upsert
  Boolean idFieldFound = false;
  Boolean externalIdFieldFound = false;
  // the field SObjectField specifies which field is going to be used as key
  SObjectField field = null;
  for (Integer i = 1; i < fieldsArray.size(); i++) {
    if (fieldsArray[i].toLowerCase() == 'external_id__c') {
      externalIdFieldFound = true;
      field = Planet__c.fields.Code__c;
    } else if (fieldsArray[i].toLowerCase() == 'id') {
      // id takes precedence over external id, so the code is breaking from the for
      // cycle as soon as it is found
      idFieldFound = true;
      field = Planet__c.fields.Id;
      break;
    }
  }
  if (field != null) {
    // upserting the records
    System.debug('> upserting planets');
    Database.UpsertResult[] srList = Database.upsert(planetsToUpsert, field, false);
    for (Database.UpsertResult sr : srList) {
      if (!sr.isSuccess()) {
        for (Database.Error err : sr.getErrors()) {
          System.debug('> the following error has occurred.');
          System.debug(err.getStatusCode() + ': ' + err.getMessage());
          System.debug('> fields that affected this error: ' + err.getFields());
        }
      }
    }
  } else {
    // inserting the records
    System.debug('> inserting planets');
    Database.SaveResult[] srList = Database.insert(planetsToUpsert, false);
    for (Database.SaveResult sr : srList) {
      if (!sr.isSuccess()) {
        for (Database.Error err : sr.getErrors()) {
          System.debug('> the following error has occurred.');
          System.debug(err.getStatusCode() + ': ' + err.getMessage());
          System.debug('> fields that affected this error: ' + err.getFields());
        }
      }
    }
  }
}
if (errors.size() > 0) {
  System.debug('> issues found in the data');
  System.debug('> ' + planetsArray[0]);
  for (String err : errors) {
    System.debug('> ' + err);
  }
}
