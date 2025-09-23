public with sharing class DeliveryCalloutInvoker {
    public class Request {
        @InvocableVariable(required=true)
        public Id recordId;
    }

    @InvocableMethod(label='Send Delivery Update (enqueue)')
    public static void sendDeliveryUpdate(List<Request> requests) {
        List<Id> ids = new List<Id>();
        for (Request r : requests) {
            ids.add(r.recordId);
        }
        System.enqueueJob(new DeliveryCalloutQueueable(ids));
    }
}