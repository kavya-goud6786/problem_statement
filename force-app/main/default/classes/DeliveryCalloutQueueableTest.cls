@isTest
public class DeliveryCalloutQueueableTest {
    
    @isTest
    static void testQueueableExecution() {
        // Create test delivery record
        Delivery__c delivery = new Delivery__c(
            Delivery_Address__c = '123 Test Street'
        );
        insert delivery;

        // Register the HTTP mock
        Test.setMock(HttpCalloutMock.class, new DeliveryHttpMock());

        // Enqueue the Queueable job
        Test.startTest();
        System.enqueueJob(new DeliveryCalloutQueueable(delivery.Id));
        Test.stopTest();

        // Assert that the record still exists (basic validation)
        Delivery__c insertedDelivery = [
            SELECT Id, Delivery_Address__c 
            FROM Delivery__c 
            WHERE Id = :delivery.Id 
            LIMIT 1
        ];
        System.assertNotEquals(null, insertedDelivery, 
            'Delivery record should exist after queueable job runs.');
    }
}