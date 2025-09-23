@isTest
public class DeliveryApiClientTest {
    // --- Mocks (inner classes) ---
    private class SuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            // body shaped like httpbin's JSON -> your code expects result.get('json')
            res.setBody('{"json":{"deliveryId":"D123","time":"2025-09-21T10:00:00Z"}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class FailureMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Server error"}');
            return res;
        }
    }

    private class ExceptionMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Force the callout to throw so the catch block runs
            throw new CalloutException('Simulated callout failure');
        }
    }

    // --- Tests ---
    @isTest
    static void testSendDelivery_Success() {
        // Create test delivery (use only writeable fields)
        Delivery__c d = new Delivery__c(Delivery_Address__c = 'Success Street');
        insert d;

        // Register success mock
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        DeliveryApiClient.sendDelivery(d.Id);
        Test.stopTest();

        // Query the fields your class writes back
        Delivery__c after = [
            SELECT Id, API_Delivery_Id__c, API_Delivery_Time_c__c
            FROM Delivery__c
            WHERE Id = :d.Id
            LIMIT 1
        ];

        System.assertEquals('D123', after.API_Delivery_Id__c, 'API ID should be set from mock');
        System.assertEquals('2025-09-21T10:00:00Z', after.API_Delivery_Time_c__c, 'API time should be set from mock');
    }

    @isTest
    static void testSendDelivery_Failure() {
        Delivery__c d = new Delivery__c(Delivery_Address__c = 'Failure Street');
        insert d;

        // Register failure mock (non-200)
        Test.setMock(HttpCalloutMock.class, new FailureMock());

        Test.startTest();
        DeliveryApiClient.sendDelivery(d.Id);
        Test.stopTest();

        // On failure your code should not update the API fields
        Delivery__c after = [
            SELECT Id, API_Delivery_Id__c, API_Delivery_Time_c__c
            FROM Delivery__c
            WHERE Id = :d.Id
            LIMIT 1
        ];

        System.assertEquals(null, after.API_Delivery_Id__c, 'API ID should NOT be set on failure');
        System.assertEquals(null, after.API_Delivery_Time_c__c, 'API time should NOT be set on failure');
    }

    @isTest
    static void testSendDelivery_Exception() {
        Delivery__c d = new Delivery__c(Delivery_Address__c = 'Exception Street');
        insert d;

        // Register mock that throws to hit the catch block
        Test.setMock(HttpCalloutMock.class, new ExceptionMock());

        Test.startTest();
        DeliveryApiClient.sendDelivery(d.Id);
        Test.stopTest();

        // Ensure record still exists and fields were not set
        Delivery__c after = [
            SELECT Id, API_Delivery_Id__c, API_Delivery_Time_c__c
            FROM Delivery__c
            WHERE Id = :d.Id
            LIMIT 1
        ];
        System.assertNotEquals(null, after, 'Delivery record must still exist after exception');
        System.assertEquals(null, after.API_Delivery_Id__c, 'API ID should NOT be set when exception thrown');
        System.assertEquals(null, after.API_Delivery_Time_c__c, 'API time should NOT be set when exception thrown');
    }
}