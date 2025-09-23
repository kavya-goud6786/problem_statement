public class DeliveryApiClient {
    @future(callout=true)
    public static void sendDelivery(Id deliveryId) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://httpbin.org/post');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        // Build request body
        Delivery__c d = [
            SELECT Id, Actual_Delivery_Time__c 
            FROM Delivery__c 
            WHERE Id = :deliveryId 
            LIMIT 1
        ];
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('deliveryId', d.Id);
        payload.put('time', String.valueOf(d.Actual_Delivery_Time__c));
        
        req.setBody(JSON.serialize(payload));
        
        HttpResponse res;
        try {
            res = http.send(req);
        } catch (Exception e) {
            System.debug('HTTP callout failed: ' + e.getMessage());
            return; // exit if callout fails
        }
       
        if (res.getStatusCode() == 200) {
            // Parse response
            Map<String, Object> result = 
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> jsonPart = 
                (Map<String, Object>) result.get('json');
            
            String parsedId   = (String) jsonPart.get('deliveryId');
            String parsedTime = (String) jsonPart.get('time');
            
            System.debug('Parsed deliveryId: ' + parsedId);
            System.debug('Parsed time: ' + parsedTime);

            // Save values back to Delivery__c
            d.API_Delivery_Id__c   = parsedId;
            d.API_Delivery_Time_c__c = parsedTime;
            update d;
        } else {
            System.debug('Callout failed with status code: ' + res.getStatusCode());
        }
    }
}