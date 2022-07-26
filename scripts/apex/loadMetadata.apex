// script for inserting a number of metadata entries into the org using the python script
// parseCSVIntoMultiline.py to convert a csv into a multiline string

// the first line of this script must be a string named data, copied from the
// file generated with the python script mentioned before
String data =
  'External_id__c;Access_Code__c\n' +
  'A-00001;jPnR\\5625\n' +
  'AM-00002;t$Th\\5199\n' +
  'B-00003;qoby\\@@59\n' +
  'BI-00004;FQwC\\7485\n' +
  'CN-00005;qBBt\\2339\n' +
  'C-00006;ZNJZ\\537@\n' +
  'C-00007;KLSd\\9@76\n' +
  'C-00008;oyaN\\841@\n' +
  'CD-00009;lvgr\\2716\n' +
  'C-00010;TZeZ\\5414\n' +
  'C-00011;aHBN\\16@6\n' +
  'D-00012;cGHy\\9562\n' +
  'D-00013;G$mf\\2@35\n' +
  'D-00014;ghjU\\258@\n' +
  'D-00015;LXVh\\61@2\n' +
  'E-00016;tRZw\\839@\n' +
  'E-00017;$VjP\\9859\n' +
  'F-00018;dCMt\\558@\n' +
  'G-00019;pj$k\\1635\n' +
  'GA-00020;fopy\\@339\n' +
  'HK-00021;qS$$\\2288\n' +
  'H-00022;XCEv\\3071\n' +
  'I-00023;Xpqo\\1578\n' +
  'I-00024;jcpF\\5694\n' +
  'J-00025;Tgto\\2@0@\n' +
  'K-00026;MXon\\@577\n' +
  'K-00027;GHhT\\636\n' +
  'K-00028;FHHa\\943\n' +
  'M-00029;JzKF\\1225\n' +
  'M-00030;HqjE\\7698\n' +
  'MC-00031;EZA$\\5@88\n' +
  'M-00032;hQyE\\@603\n' +
  'M-00033;PWav\\820\n' +
  'M-00034;YGcK\\92@\n' +
  'N-00035;Vauj\\570\n' +
  'NH-00036;FSYl\\229\n' +
  'O-00037;aRqr\\9@7\n' +
  'OM-00038;ngdO\\1@5\n' +
  'PM-00039;m$mM\\309\n' +
  'Q-00040;YW$L\\363\n' +
  'R-00041;AFF$\\@43\n' +
  'R-00042;UnUu\\20@\n' +
  'S-00043;nZmp\\84\n' +
  'S-00044;nkqn\\619\n' +
  'S-00045;LRHQ\\7@3\n' +
  'S-00046;JVOn\\375\n' +
  'S-00047;aHVY\\505\n' +
  'S-00048;kdna\\829\n' +
  'S-00049;tOTs\\2@\n' +
  'T-00050;wVnV\\@0\n' +
  'T-00051;bWxd\\42\n' +
  'T-00052;Zm$a\\77\n' +
  'T-00053;alxf\\30\n' +
  'T-00054;XOSo\\98\n' +
  'T-00055;JDrm\\37\n' +
  'U-00056;RXgm\\30\n' +
  'U-00057;HnkY\\87\n' +
  'V-00058;gtqP\\85\n' +
  'YI-00059;Fz$m\\2@\n' +
  'Z-00060;TYKp\\@4';

// prepare the required variables to iterate over the data string
// each line will be splitted one from the other using the newline character
// values inside a line will be splitted using the semicolon character
String[] dataArray = data.split('\n');
String[] fieldsArray = dataArray[0].split(';');
Integer numberOfFields = fieldsArray.size();
List<String> errors = new List<String>();
// the mdContainer object is used to deploy the metadata records into the org
Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
Integer count = 0;
for (Integer i = 1; i < dataArray.size(); i++) {
  String[] dataInfo = dataArray[i].split(';');
  // if the information for a metadata does not contain the same number of fields
  // provided in the header of the metadata string, an error is added and said
  // metadata is skipped
  if (dataInfo.size() != numberOfFields) {
    errors.add(dataArray[i]);
    continue;
  }
  // a new metadata is created and the value for each field is added dynamically
  Metadata.CustomMetadata newMetadataRecord = new Metadata.CustomMetadata();
  newMetadataRecord.fullName = 'Access_Code_Settings.Entry' + i;
  newMetadataRecord.label = 'Entry' + i;
  for (Integer j = 0; j < numberOfFields; j++) {
    // the external id field is being mapped with the Planet_Code__c field
    String field = (fieldsArray[j].toLowerCase() == 'external_id__c') ? 'Planet_Code__c' : fieldsArray[j];
    Metadata.CustomMetadataValue fieldData = new Metadata.CustomMetadataValue();
    fieldData.field = field;
    fieldData.value = dataInfo[j];
    newMetadataRecord.values.add(fieldData);
  }
  mdContainer.addMetadata(newMetadataRecord);
  count++;
}
// since we are not handling the callback the second argument for the enqueueDeployment
// function is null, also the function runs async so in the context of an script it's hard
// to post the metadata deployment final status
System.debug('> inserting ' + count + ' metadata records');
Metadata.Operations.enqueueDeployment(mdContainer, null);
if (errors.size() > 0) {
  System.debug('> issues found in the data');
  System.debug('> ' + dataArray[0]);
  for (String err : errors) {
    System.debug('> ' + err);
  }
}
