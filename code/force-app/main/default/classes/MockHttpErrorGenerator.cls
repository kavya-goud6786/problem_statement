@isTest
global class MockHttpErrorGenerator implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(500);
        res.setBody('{"error":"Internal Server Error"}');
        return res;
    }
}