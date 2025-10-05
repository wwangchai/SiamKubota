public class DealerApiUpsert {
    
    @future(callout=true)
    public static void dealerApiUpsert() {
        try {
            String fullResourcePath;
            
            // Get Resource Path from Custom Metadata
            List<KadsAPI__mdt> configMetaDataList = [
                SELECT Id, APIResourcePaht__c  
                FROM KadsAPI__mdt 
                WHERE QualifiedApiName = 'Dealer'
            ];
            for (KadsAPI__mdt config : configMetaDataList) {
                fullResourcePath = config.APIResourcePaht__c;
            }
            
            RecordType rtDealer = [
                SELECT Id 
                FROM RecordType 
                WHERE DeveloperName = 'Dealer_Master' 
                AND SobjectType = 'Account' 
                LIMIT 1
            ];
            
            // Split and encode filter
            List<String> splitText = fullResourcePath.split('\\?');
            String resourcePath = splitText[0];
            String filter = splitText.size() > 1 ? splitText[1] : '';
            filter = EncodingUtil.urlEncode(filter, 'UTF-8')
                .replace('+', '%20')
                .replace('%26', '&')
                .replace('%3D', '=')
                .replace('%5C', '');
            
            // Callout
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:kadsMasterDataAPI' + resourcePath + '?' + filter);
            request.setMethod('GET');
            request.setHeader('Accept', 'application/json');
            
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> dMap = (Map<String, Object>) resultMap.get('d');
                
                if (dMap != null && dMap.containsKey('results')) {
                    List<Object> resultsList = (List<Object>) dMap.get('results');
                    List<Account> dealerMasterUp = new List<Account>();
                    System.debug('resultsList : '+resultsList);
                    for (Object dealerData : resultsList) {
                        Map<String, Object> dealerDataMap = (Map<String, Object>) dealerData;
                        
                        if (dealerDataMap.get('SalesOrgName') != null && dealerDataMap.get('PlantName') != null) {
                            Account dealer = new Account();
                            dealer.LANDTX__c = String.valueOf(dealerDataMap.get('CountryCode'));
                            dealer.Company_Code_KADS__c = String.valueOf(dealerDataMap.get('CompanyCode'));
                            dealer.Name = String.valueOf(dealerDataMap.get('SalesOrgName')) + '-' + String.valueOf(dealerDataMap.get('PlantName'));
                            dealer.Plant_name__c = String.valueOf(dealerDataMap.get('PlantName'));
                            dealer.Dealer_Code__c = String.valueOf(dealerDataMap.get('DealerCodeSAP'));
                            dealer.Dealer_Name__c = String.valueOf(dealerDataMap.get('SalesOrgName'));
                            dealer.Zone__c = String.valueOf(dealerDataMap.get('ZoneName'));
                            dealer.Sale_Org_Code__c = String.valueOf(dealerDataMap.get('SalesOrgCode'));
                            dealer.Sale_Org_Name__c = String.valueOf(dealerDataMap.get('SalesOrgName'));
                            dealer.Shipto__c = String.valueOf(dealerDataMap.get('Shipto'));
                            dealer.Shipto_name__c = String.valueOf(dealerDataMap.get('ShiptoName'));
                            dealer.Sold_to__c = String.valueOf(dealerDataMap.get('Soldto'));
                            dealer.Dealer_Plant_Code__c = String.valueOf(dealerDataMap.get('PlantCode'));
                            dealer.RecordTypeId = rtDealer.Id;
                            dealerMasterUp.add(dealer);
                        }
                    }
                    
                    Integer batchSize = 50;
                    for (Integer i = 0; i < dealerMasterUp.size(); i += batchSize) {
                        List<Account> batch = new List<Account>();
                        for (Integer j = i; j < Math.min(i + batchSize, dealerMasterUp.size()); j++) {
                            batch.add(dealerMasterUp[j]);
                        }
                        
                        try {
                            List<Database.UpsertResult> results = Database.upsert(batch, Account.Dealer_Plant_Code__c, false);
                            for (Integer k = 0; k < results.size(); k++) {
                                if (!results[k].isSuccess()) {
                                    System.debug('❌ Failed record: ' + JSON.serialize(batch[k]));
                                    for (Database.Error err : results[k].getErrors()) {
                                        System.debug('⚠️ Error: ' + err.getMessage());
                                    }
                                } else {
                                    System.debug('✅ Upserted record ID: ' + results[k].getId());
                                }
                            }
                        } catch (DmlException e) {
                            System.debug('🔥 DML Exception: ' + e.getMessage());
                        }
                    }
                    System.debug('DML statements used: ' + Limits.getDmlStatements());
                    System.debug('DML limit: ' + Limits.getLimitDmlStatements());
                } else {
                    System.debug('⚠️ No "results" key in response.');
                }
            } else {
                System.debug('❌ HTTP Error: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('🔥 Exception: ' + e.getMessage());
        }
    }
}