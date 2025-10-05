public class DealerAssetController {
     
    @AuraEnabled
    public static  List<Asset> getDealerAsset(Id recordId){
        
        String accountId;
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        String loginDealerCode = [Select Dealer_Code__c From User Where Id = :UserInfo.getUserId()][0].Dealer_Code__c;
        
        System.debug('loginDealerCode = '+loginDealerCode);
        
        if(sObjName == 'Account'){
            accountId = recordId;
        }else if(sObjName == 'Lead'){
            List<Lead> accList = [SELECT Account__c FROM Lead WHERE Id = :recordId  LIMIT 1 ];
            for(Lead accObj :accList ){
                accountId = accObj.Account__c;
            }
        }else{
            accountId = '-1';
        }
        
        return [SELECT Id
                        ,Name
                        ,SerialNumber
                        ,Product2.Name
                        ,Product2.Family
                        ,PurchaseDate
                        ,Shop_Name_Account__r.Name
                FROM Asset 
                WHERE AccountId = :accountId 
                AND Dealer_Code__c = :loginDealerCode];

    }
 

}