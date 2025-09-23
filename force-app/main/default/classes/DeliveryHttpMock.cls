@isTest
global class DeliveryHttpMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success","message":"Mock delivery created"}');
        res.setStatusCode(200);
        return res;
    }
}