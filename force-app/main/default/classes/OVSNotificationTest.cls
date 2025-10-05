/**
 * @description       :
 * @author            : Chanathip
 * @group             :
 * @last modified on  : 02-13-2025
 * @last modified by  : Chanathip
 **/
@isTest
public class OVSNotificationTest {
    @testSetup
    static void setupTestData() {
        // Create a test Notification_API__mdt record
        OVSNotification.RecordWrapper wrapper = new OVSNotification.RecordWrapper();
        List<OVSNotification.RecordWrapper> wrapperList = new List<OVSNotification.RecordWrapper>();
        
        
        // Create AddressMaster record
        AddressMaster__c add = new AddressMaster__c();
        add.Country__c = 'TH';
        add.Country_Key__c = 'TH';
        add.Province__c = '11';
        add.Province_Key__c = '11';
        add.District__c = '11';
        add.District_Key__c = '11';
        add.Sub_District__c = '11';
        add.Subdistrict_Key__c = '11';
        add.Postcode__c = '11';
        add.Postcode_Key__c = '11';
        add.Village__c = '11';
        add.Village_Key__c = '11';
        add.Address_Key__c = 'TH1111111111';
        insert add;
        
        Account testAccount = new Account(
            FirstName = 'John',
        LastName = 'Doe',
        Citizen_Id__c = '1234567890123',
        BranchCode__c = '001',
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
        Is_KADS_Update__c = true
            );
        insert testAccount;
        
        Product2 p1 = new Product2(name='Product A',Material_Number__c = 'KUBOTA-KISS');
        insert p1;
        
        Product2 p2 = new Product2(name='Product B',Material_Number__c = 'DRONE');
        insert p2;
        
        Product2 p3 = new Product2(name='Product C',Material_Number__c = 'TRACTOR');
        insert p3;
        
        order kads = new order(
            kubota_Id__c = testAccount.Id,
        AccountId = testAccount.Id,
        Product__c = p1.Id,
        KubotaId__c = '9000633451',
        Status = 'Draft',
        EffectiveDate = Date.newInstance(2025, 8, 16),
        Engine_Code__c = 'KUBOTA-KIS',
        LANDTX__c = 'TH'
            );
        insert kads;
        
        order kadsLA = new order(
            kubota_Id__c = testAccount.Id,
        AccountId = testAccount.Id,
        Product__c = p2.Id,
        KubotaId__c = '9000633410',
        Status = 'Draft',
        Engine_Code__c = 'DRONE',
        EffectiveDate = Date.newInstance(2025, 8, 16),
        LANDTX__c = 'KH'
            );
        insert kadsLA;
        WelcomeCall__c wcl = new WelcomeCall__c(
            Product_Header__c = p1.Id,
        Daily_Sales_Kads_Order__c = kadsLA.Id,
        Main_occupation__c = 'เกษตรกร',
        Planted_crops_1__c = 'Rice',
        Plantation_area_1_Rai__c = '20',
        Planted_crops_2__c = 'Corn',
        Plantation_area_2_Rai__c = '15'
            );
        insert wcl;
        
        WelcomeCall__c wcRai0 = new WelcomeCall__c(
            Product_Header__c = p1.Id,
        Daily_Sales_Kads_Order__c = kadsLA.Id,
        Main_occupation__c = 'เกษตรกร',
        Planted_crops_1__c = 'Rice',
        Plantation_area_1_Rai__c = '0',
        Planted_crops_2__c = 'Corn',
        Plantation_area_2_Rai__c = '15'
            );
        insert wcRai0;
        
        
        WelcomeCall__c wcRai2_0 = new WelcomeCall__c(
            Product_Header__c = p1.Id,
        Daily_Sales_Kads_Order__c = kadsLA.Id,
        Main_occupation__c = 'เกษตรกร',
        Planted_crops_1__c = 'Rice',
        Plantation_area_1_Rai__c = '20',
        Planted_crops_2__c = 'Corn',
        Plantation_area_2_Rai__c = ''
            );
        insert wcRai2_0;
        
        WelcomeCall__c wcplantnull = new WelcomeCall__c(
            Product_Header__c = p1.Id,
        Daily_Sales_Kads_Order__c = kadsLA.Id,
        Main_occupation__c = 'เกษตรกร',
        Planted_crops_1__c = '',
        Plantation_area_1_Rai__c = '20',
        Planted_crops_2__c = 'Corn',
        Plantation_area_2_Rai__c = '15'
            );
        insert wcplantnull;
        
        Welcome_Call_Questionnaire__c question = new Welcome_Call_Questionnaire__c(
            Questionnaire_Label__c = 'อาชีพหลัก',
        Answer_Type__c = 'Text',
        Answer_Value__c = ''
            );
        insert question;
        
        Welcome_Call_Questionnaire_Setup__c setup = new Welcome_Call_Questionnaire_Setup__c(
            Car_Type__c = 'TRACTOR',
        Welcome_Call_Questionnaire__c = question.Id,
        Section_Name__c = 'Personal Info',
        Sequence__c = 1
            );
        insert setup;
        
        // สร้างคำตอบเดิม
        
        Welcome_Call_Questionnaire_Link__c answer = new Welcome_Call_Questionnaire_Link__c(
            Welcome_Call_Questionnaire_Setup__c = setup.Id,
        Welcome_Call__c = wcplantnull.Id,
        Key_for_Saving__c = wcplantnull.Id,
        Answer_Value__c = setup.Id
            );
        insert answer;
        
        Test.setCreatedDate(wcl.Id, DateTime.newInstance(2024,02,1));
        // Initialize wrapper with relevant data for testing
        wrapper.KubotaID = '213214243';
        wrapper.SalesforceID = '213531323';
        wrapper.title = 'How was your experience';
        wrapper.body = 'Please rate the service used.';
        wrapper.type = 'QUESTIONNAIRE';
        wrapper.action = 'WEBVIEW';
        wrapper.link = 'www.google.com';
        wrapperList.add(wrapper);
        Test.startTest();
        OVSNotification.executeLogic(wrapperList);
        Test.stopTest();
    }
    @isTest
    static void testMakeHttpPostRequest() {
        String jsonString = '{'
            + '"KubotaID": "9000001414",'
            + '"SalesforceID": "a1TBA0000001WVh2AM",'
            + '"title": "Survey: KBC Welcome Call Questionnaire",'
            + '"body": "Tell us what you think about our services.",'
            + '"type": "QUESTIONNAIRE",'
            + '"action": "WEBVIEW",'
        + '"link": "https://siamkubota--training.sandbox.my.site.com/liveagent/survey/runtimeApp.app?invitationId=0KiAz00000000eL&surveyName=kbc_welcome_call_questionnaire&UUID=d5444dd5-733b-4449-a621-e09c5f65f29b"'
            + '}';
        
        OVSNotification.makeHttpPostRequest(jsonString);
    }

}