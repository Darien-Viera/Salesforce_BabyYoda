//Testclass: MandalorianServerAPIHandlerTest
public class MandalorianServerAPIHandler {
  public class ResponseWrapper {
    // wrapper object for handling the response from the callout containing a toast type to be used in the LWC and
    // a payload for displaying information about the callout in said toast
    public String ToastType { get; private set; }
    public String Payload { get; private set; }

    public ResponseWrapper(String toast, String pay) {
      if (!(new List<String>{ 'SUCCESS', 'ERROR', 'WARNING', 'INFO' }.contains(toast))) {
        ToastType = 'ERROR';
        Payload = 'Invalid toast type passed as argument to the Response Wrapper';
      } else {
        ToastType = toast;
        Payload = pay;
      }
    }
  }

  public static ResponseWrapper handleCallout(String planetCode) {
    SingletonMandalorianServerAuth mandoServerMeta = SingletonMandalorianServerAuth.getInstance();
    // if the metadata is not found in the DB during the singleton initialization, or if some
    // value is missing from it, return early with info toast
    if (serverAuthIsMissingData(mandoServerMeta))
      return new ResponseWrapper('INFO', 'Authentication Metadata was not found or is missing data');
    String planetAccessCode = mandoServerMeta.AccessCodes.get(planetCode).Access_Code__c;
    // if the planet access code is not found on the metadata, return early with info toast
    if (planetAccessCode == null)
      return new ResponseWrapper('INFO', 'Planet Access Code not found for requested planet');
    return sendCallout(planetCode, planetAccessCode, mandoServerMeta);
  }

  private static ResponseWrapper sendCallout(
    String planetCode,
    String planetAccessCode,
    SingletonMandalorianServerAuth mandoServerMeta
  ) {
    try {
      // get the authentication type, user and password from the metadata
      Blob headerValue = Blob.valueOf(mandoServerMeta.User + ':' + mandoServerMeta.Password);
      String authHeader = mandoServerMeta.Type + ' ' + EncodingUtil.base64Encode(headerValue);
      // set information required by the http request: endpoint, method, header containing the auth details
      HttpRequest req = new HttpRequest();
      // the endpoint is store in metadata and the planet code is appended to fetch the scan for said planet
      req.setEndpoint(mandoServerMeta.Endpoint + planetAccessCode);
      req.setMethod('GET');
      req.setHeader('Authorization', authHeader);
      Http http = new Http();
      HTTPResponse res = http.send(req);
      return switchOnHTTPResponseStatusCode(planetCode, res.getStatusCode(), res.getBody());
    } catch (Exception e) {
      return new ResponseWrapper('ERROR', e.getMessage());
    }
  }

  @testVisible
  private static Boolean serverAuthIsMissingData(SingletonMandalorianServerAuth mandoServerMeta) {
    return (mandoServerMeta.Endpoint == null ||
    mandoServerMeta.Password == null ||
    mandoServerMeta.Type == null ||
    mandoServerMeta.User == null);
  }

  private static ResponseWrapper switchOnHTTPResponseStatusCode(String planetCode, Integer statusCode, String body) {
    // this function switchs on each possible status code returned by the callout and handles their respective
    // actions in separate functions, also returns a generic error if the status code is not a predefined one
    switch on statusCode {
      when 200 {
        return handleStatusCode200(planetCode, body);
      }
      when 400, 401, 500 {
        return handleStatusCode400_401_500(statusCode, body);
      }
      when else {
        return new ResponseWrapper('ERROR', 'Unexpected status code returned \nPayload returned: ' + body);
      }
    }
  }

  private static ResponseWrapper handleStatusCode200(String planetCode, String body) {
    // if the status code is 200 then we proceed to deserialize the body, cast the object value to
    // boolean, close the case and return a success message toast
    Map<String, Object> deserializedJSON = (Map<String, Object>) JSON.deserializeUntyped(body);
    Object foundValue = deserializedJSON.get('found');
    // if the value was not found or cannot be casted to boolean, return an error toast stating that
    // there are issues in the returned body
    if (foundValue == null || !(foundValue instanceof Boolean)) {
      return new ResponseWrapper('ERROR', 'Unexpected body returned \nPayload returned: ' + body);
    }
    Boolean value = (Boolean) foundValue;
    // planets are unique but multiple cases can be linked to the same planet, so if we find Baby Yoda
    // all cases related with the scanned planet are closed
    List<Case> caseList = [
      SELECT Id, Successful_Scan__c, Planet__r.Code__c
      FROM Case
      WHERE Planet__r.Code__c = :planetCode
    ];
    for (Case caseElem : caseList) {
      caseElem.Successful_Scan__c = value;
      caseElem.Status = 'Closed';
    }
    update caseList;
    return new ResponseWrapper('SUCCESS', 'Scan successful! Was Baby Yoda found? -> ' + value);
  }

  private static ResponseWrapper handleStatusCode400_401_500(Integer statusCode, String body) {
    // same as above, deserialize the body, cast the object value to string and return a
    // warning message toast
    Map<String, Object> deserializedJSON = (Map<String, Object>) JSON.deserializeUntyped(body);
    Object errorMsg = deserializedJSON.get('error');
    // the toast message is obtained from the body returned by the callout, but since the status code
    // returned is enough to determine the message, if we fail to obtain the message from the body, a
    // standard error message is sent
    String errorMsgString = null;
    if (errorMsg == null || !(errorMsg instanceof String)) {
      switch on statusCode {
        when 400 {
          errorMsgString = 'Bad planet access code';
        }
        when 401 {
          errorMsgString = 'Bad or missing authentication';
        }
        when 500 {
          errorMsgString = 'Internal server error';
        }
      }
    }
    errorMsgString = (errorMsgString == null) ? (String) errorMsg : errorMsgString;
    return new ResponseWrapper('WARNING', errorMsgString);
  }
}
