@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"json": {"deliveryId": "12345", "time": "2025-09-21T10:00:00Z"}}');
        res.setStatusCode(200);
        return res;
    }
}