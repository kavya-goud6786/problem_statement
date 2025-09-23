public class DeliveryCalloutQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> deliveryIds;

    public DeliveryCalloutQueueable(List<Id> ids) {
        this.deliveryIds = ids;
    }

    public void execute(QueueableContext context) {
        List<Delivery__c> deliveries = [
            SELECT Id, Delivery_Number__c, Delivery_Status__c, Actual_Delivery_Time__c
            FROM Delivery__c
            WHERE Id IN :deliveryIds
        ];

        for (Delivery__c d : deliveries) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:DeliveryAPI/post');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            Map<String, Object> payload = new Map<String, Object>{
                'deliveryNumber' => d.Delivery_Number__c,
                'status' => d.Delivery_Status__c,
                'actualDeliveryTime' => d.Actual_Delivery_Time__c
            };
            req.setBody(JSON.serialize(payload));

            Http http = new Http();
            HttpResponse res = http.send(req);

            System.debug('📦 Sent delivery update: ' + req.getBody());
            System.debug('🌐 Response: ' + res.getBody());
        }
    }
}