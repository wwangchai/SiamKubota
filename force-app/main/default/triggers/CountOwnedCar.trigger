trigger CountOwnedCar on WelcomeCall__c (before insert) {

 for(WelcomeCall__c obj : Trigger.New) {
    Id accountId = obj.Customer__c;
    AggregateResult[] AssetList = [SELECT COUNT(Id) FROM Asset where AccountId = :accountId and product2.Family <> 'IMPLEMENT' and product2.Family != 'DRONE IMPLEMENT'  ]; 

     Integer countAsset = 0;
     for(AggregateResult a:AssetList ) {     
           countAsset = (INTEGER)a.get('expr0');    
           String numberOwnedCar= String.valueOf(countAsset ); 
           obj.Number_of_owned_car_int__c = countAsset;
           obj.Number_of_vehicles_owned_cars__c = numberOwnedCar;
        
    }   
    

 }

 


}