@isTest
global class ExceptionMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Simulate a runtime exception during callout
        throw new CalloutException('Simulated callout failure');
    }
}