@isTest
public class MandalorianServerMock {
  // http mock classes for testing the different callout statuses that can be returned
  // from the Mandalorian Server: 200, 400, 401, 500, in addition to positive and negative
  // mocks for both types of testing and a mock for an unknown return status 9999,
  // notice that the negative cases consist in the body for the response not having the
  // expected key
  public class MandalorianServerMock200 implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"found" : true}');
      res.setStatusCode(200);
      return res;
    }
  }

  public class MandalorianServerMock200Negative implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"negative" : true}');
      res.setStatusCode(200);
      return res;
    }
  }

  public class MandalorianServerMock400 implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"error" : "Bad planet access code positive testing"}');
      res.setStatusCode(400);
      return res;
    }
  }

  public class MandalorianServerMock400Negative implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"negative" : "Bad planet access code"}');
      res.setStatusCode(400);
      return res;
    }
  }

  public class MandalorianServerMock401 implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"error" : "Bad or missing authentication positive testing"}');
      res.setStatusCode(401);
      return res;
    }
  }

  public class MandalorianServerMock401Negative implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"negative" : "Bad or missing authentication"}');
      res.setStatusCode(401);
      return res;
    }
  }

  public class MandalorianServerMock500 implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"error" : "Internal server error positive testing"}');
      res.setStatusCode(500);
      return res;
    }
  }

  public class MandalorianServerMock500Negative implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"negative" : "Internal server error"}');
      res.setStatusCode(500);
      return res;
    }
  }

  public class MandalorianServerMockWrongStatus implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"crazy" : "The server went crazy :P"}');
      res.setStatusCode(9999);
      return res;
    }
  }
}
