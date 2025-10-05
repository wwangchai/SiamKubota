/**
 * @description       : 
 * @author            : Chanathip
 * @group             : 
 * @last modified on  : 05-17-2024
 * @last modified by  : Chanathip
**/
@isTest
public class WelcomeCallTest {

    @TestSetup
    static void makeData() {
        
        RecordType accRec = [SELECT Id, Name FROM RecordType WHERE Name = 'person account oversea'];
        RecordType wcRec = [SELECT Id, Name FROM RecordType WHERE Name = 'TRACTOR (รถแทรกเตอร์)'];
        Account acc = new Account();
        Account testAccount = new Account(
            Name = 'Test Account',
            Customer_Tier__c = 'Non-Premier',
            Mobile_phone_no_1__c = null
        );
        insert testAccount; 
        
        Product2 prod = new Product2();
        prod.Name = 'Product Name';
        prod.Material_Number__c = 'KUBOTA-KIS';
        prod.Family = 'TRACTOR';
        insert prod;
        
        // First Order record with LANDTX__c = 'TH'
        Order dsTH = new Order();
        dsTH.Engine_Code__c = '1234';
        dsTH.AccountId = testAccount.Id;
        dsTH.Product__c = prod.Id;
        dsTH.Product_Type__c = 'TRACTOR';
        dsTH.IS_Duplicate__c = 'No';
        dsTH.LANDTX__c = 'TH';
        dsTH.Status = 'Draft';
        dsTH.EffectiveDate = Date.newInstance(2025, 8, 16);
        insert dsTH;
        
        // Second Order record with LANDTX__c = 'KM'
        Order dsKM = new Order();
        dsKM.Engine_Code__c = '5678';
        dsKM.AccountId = testAccount.Id;
        dsKM.Product__c = prod.Id;
        dsKM.Product_Type__c = 'TRACTOR';
        dsKM.IS_Duplicate__c = 'No';
        dsKM.LANDTX__c = 'KM';
        dsKM.Status = 'Draft';
        dsKM.EffectiveDate = Date.newInstance(2025, 8, 16);
        insert dsKM;

        WelcomeCall__c wc = new WelcomeCall__c();
        wc.RecordTypeId = wcRec.Id;
        wc.Customer__c = testAccount.Id;
        wc.Product_Detail__c = prod.Id;
        insert wc;
    }
    
    @isTest
    public static void testCreateWelcomeCall() {
        Id idTH = getDailySales('TH');
        Id idKM = getDailySales('KM');
        Test.startTest();
            WelcomeCallService.createWelcomeCall(idTH);
            WelcomeCallService.createWelcomeCall(idKM);
        Test.stopTest();
    }
    
    public static Id getDailySales(String landTx) {
        return [SELECT Id FROM Order WHERE LANDTX__c = :landTx LIMIT 1].Id;
    }
}