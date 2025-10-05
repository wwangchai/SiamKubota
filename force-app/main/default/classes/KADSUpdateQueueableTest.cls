/**
 * @description       : 
 * @author            : Chanathip
 * @group             : 
 * @last modified on  : 02-03-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class KADSUpdateQueueableTest {
    @testSetup
    static void setup() {
        // Create test account
        String dateString = '1985-01-31';
        Date myDate = Date.valueOf(dateString);
       AddressMaster__c  add = new AddressMaster__c();
        add.Country__c = 'TH';
        add.Country_Key__c  = 'TH';
        add.Province__c ='11';
        add.Province_Key__c ='11';
        add.District__c = '11';
        add.District_Key__c ='11';
        add.Sub_District__c ='11';
        add.Subdistrict_Key__c ='11';
        add.Postcode__c ='11';
        add.Postcode_Key__c = '11';
        add.Village__c ='11';
        add.Village_Key__c ='11';
        add.Address_Key__c = 'TH1111111111';
        insert add;
        
        Account testAccount = new Account(
            Salutation = 'นาย',
            FirstName = 'John',
            LastName = 'Doe',
            Kubota_Id__c = '912345678',
            Citizen_Id__c = '123456789',
            BranchCode__c = '00100',
            Address_ID__c = '11', 
            Village_ID__c = '11', 
            Province_ID__c = '11', 
            Building_ID__c = '11', 
            District_ID__c = '11', 
            Sub_District_ID__c = '11',
            Postcode_ID__c = '11',
            Data_Source__c = 'KADS',
            LANDTX__c = 'TH',
            Mobile_phone_no_1__c = '0667417221',
            Mobile_ID__c = '0667417221',
            User_Level__c = 'Customer',
            BusinessType__c = '1',
            BranchCodeDescription__c = '1223',
            PersonBirthdate = myDate,
            Address_Lookup_ID__c  = add.Id,
            Address_Lookup_HR__c = add.Id,
            Address_Lookup_CR__c = add.Id,
            Address_Lookup_SP__c = add.Id
        );
        insert testAccount;

        Account testAccount2 = new Account(
            Salutation = 'นาย',
            FirstName = 'Jane',
            LastName = 'Smith',
            Kubota_Id__c = '923456789',
            Citizen_Id__c = '987654321',
            BranchCode__c = '00100',
            Address_ID__c = '11', 
            Village_ID__c = '11', 
            Province_ID__c = '11', 
            Building_ID__c = '11', 
            District_ID__c = '11', 
            Sub_District_ID__c = '11',
            Postcode_ID__c = '11',
            Data_Source__c = 'KADS',
            LANDTX__c = 'TH',
            Mobile_phone_no_1__c = '0667417222',
            Mobile_ID__c = '0667417222',
            User_Level__c = 'Customer',
            BusinessType__c = '1',
            BranchCodeDescription__c = '1223',
            PersonBirthdate = myDate
        );
        insert testAccount2;
    }

    @isTest
    static void testExecuteSuccess() {
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        System.enqueueJob(new KADSUpdateQueueable(testAcc.Id));
        Test.stopTest();
        
        // Validate log creation
        Service_Log__c log = [SELECT Id, API_Name__c FROM Service_Log__c WHERE Related_Account__c = :testAcc.Id LIMIT 1];
       // System.assertEquals('Customer API 4:  KADS Account Update API', log.API_Name__c);
    }

    @isTest
    static void testExecuteWithException() {
        Test.startTest();
        System.enqueueJob(new KADSUpdateQueueable(null));
        Test.stopTest();
        
        // Validate error log creation
        Service_Log__c errorLog = [SELECT Id, API_Name__c, Response__c FROM Service_Log__c WHERE API_Name__c = 'API 4 KADS Account Update API' LIMIT 1];
        System.assert(errorLog.Response__c.contains('Error'));
    }
}