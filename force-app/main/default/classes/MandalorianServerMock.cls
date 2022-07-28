@isTest
public class MandalorianServerMock {
  public class MandalorianServerMock200 implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"found" : true}');
      res.setStatusCode(200);
      return res;
    }
  }

  public class MandalorianServerMock400 implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"error" : "Bad planet access code"}');
      res.setStatusCode(400);
      return res;
    }
  }

  public class MandalorianServerMock401 implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"error" : "Bad or missing authentication"}');
      res.setStatusCode(401);
      return res;
    }
  }

  public class MandalorianServerMock500 implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"error" : "Internal server error"}');
      res.setStatusCode(500);
      return res;
    }
  }
}
