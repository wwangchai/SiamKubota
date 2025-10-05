@isTest
public class FormWelcomeCallQuestionTest {

  

    @isTest
    static void testQuestionWelcome() {
        // สร้าง WelcomeCall__c
        RecordType accRec = [SELECT Id, Name FROM RecordType WHERE Name = 'person account oversea'];
        RecordType wcRec = [SELECT Id, Name FROM RecordType WHERE Name = 'TRACTOR (รถแทรกเตอร์)'];
        
        Account acc = new Account();
        acc.RecordTypeId = accRec.Id;
        acc.LastName = 'Last Name';
        acc.Kubota_VIP__c = '1234';
        acc.Citizen_Id__c = '1234';
        acc.Live_Status__c = 'Alive';
        insert acc;
        
        Product2 prod = new Product2();
        prod.Name = 'Product Name';
        prod.Material_Number__c = 'KUBOTA-KIS';
        prod.Family = 'TRACTOR';
        insert prod;
        
        // First Daily_Sales_Kads__c record with LANDTX__c = 'TH'
        order dsTH = new order();
        dsTH.AccountId = acc.Id;
        dsTH.Engine_Code__c = '1234';
        dsTH.Kubota_Id__c = acc.Id;
        dsTH.Product__c = prod.Id;
        dsTH.Product_Type__c = 'TRACTOR';
        dsTH.IS_Duplicate__c = 'No';
        dsTH.Status = 'Draft';
        dsTH.EffectiveDate = Date.newInstance(2025, 8, 16);
        dsTH.LANDTX__c = 'TH';
        insert dsTH;
        
        // Second Daily_Sales_Kads__c record with LANDTX__c = 'KM'
        order dsKM = new order();
        dsKM.AccountId = acc.Id;
        dsKM.Engine_Code__c = '5678';
        dsKM.Kubota_Id__c = acc.Id;
        dsKM.Product__c = prod.Id;
        dsKM.Product_Type__c = 'TRACTOR';
        dsKM.IS_Duplicate__c = 'No';
        dsKM.LANDTX__c = 'KH';
        dsKM.Status = 'Draft';
        dsKM.EffectiveDate = Date.newInstance(2025, 8, 16);
        insert dsKM;
        
        WelcomeCall__c wc = new WelcomeCall__c();
        wc.RecordTypeId = wcRec.Id;
        wc.Daily_Sales_Kads_Order__c = dsKM.Id;
        wc.Car_Type__c = 'TRACTOR';        
        wc.Customer__c = acc.Id;
        wc.Product_Detail__c = prod.Id;
        insert wc;
        
        // สร้างคำถาม
        Welcome_Call_Questionnaire__c question = new Welcome_Call_Questionnaire__c(
        Questionnaire_Label__c = 'What is your name?',
        Answer_Type__c = 'Text',
        Answer_Value__c = '',
        Country__c = 'KH'
            );
        insert question;
        
        Welcome_Call_Questionnaire_Setup__c setup = new Welcome_Call_Questionnaire_Setup__c(
        Car_Type__c = 'TRACTOR',
        Welcome_Call_Questionnaire__c = question.Id,
        Section_Name__c = 'Personal Info',
        Sequence__c = 1,
        Is_Active__c = true
            );
        insert setup;
        
        // สร้างคำตอบเดิม
        
        Welcome_Call_Questionnaire_Link__c answer = new Welcome_Call_Questionnaire_Link__c(
            Welcome_Call__c = wc.Id,
        Key_for_Saving__c = wc.Id,
        Answer_Value_All__c = setup.Id + '::John Doe'
            );
        insert answer;
        
        Welcome_Call_Questionnaire_Link__c answerDate = new Welcome_Call_Questionnaire_Link__c(
            Welcome_Call__c = wc.Id,
        Key_for_Saving__c = wc.Id,
        Answer_Value_All__c = setup.Id + '::John Doe::John Doe::John Doe'
            );
        insert answerDate;
        WelcomeCall__c welcomeCall = [SELECT Id FROM WelcomeCall__c LIMIT 1];
        
        Test.startTest();
        List<FormWelcomeCallQuestion.QuestionWithAnswerWrapper> result =
            FormWelcomeCallQuestion.QuestionWelcome(welcomeCall.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testSaveAnswers() {
        RecordType accRec = [SELECT Id FROM RecordType WHERE Name = 'person account oversea' LIMIT 1];
        RecordType wcRec = [SELECT Id FROM RecordType WHERE Name = 'TRACTOR (รถแทรกเตอร์)' LIMIT 1];

        Account acc = new Account(
            RecordTypeId = accRec.Id,
            LastName = 'Last Name',
            Kubota_VIP__c = '1234',
            Citizen_Id__c = '1234',
            Live_Status__c = 'Alive'
        );
        insert acc;

        Product2 prod = new Product2(
            Name = 'Product Name',
            Material_Number__c = 'KUBOTA-KIS',
            Family = 'TRACTOR'
        );
        insert prod;

        order dsKM = new order(
            AccountId = acc.Id,
            Engine_Code__c = '5678',
            Kubota_Id__c = acc.Id,
            Product__c = prod.Id,
            Product_Type__c = 'TRACTOR',
            IS_Duplicate__c = 'No',
            LANDTX__c = 'KH',
            Status = 'Draft',
            EffectiveDate = Date.newInstance(2025, 8, 16)
        );
        insert dsKM;

        WelcomeCall__c wc = new WelcomeCall__c(
            RecordTypeId = wcRec.Id,
            Daily_Sales_Kads_Order__c = dsKM.Id,
            Car_Type__c = 'TRACTOR',
            Customer__c = acc.Id,
            Product_Detail__c = prod.Id
        );
        insert wc;

        Welcome_Call_Questionnaire__c question = new Welcome_Call_Questionnaire__c(
            Questionnaire_Label__c = 'What is your name?',
            Answer_Type__c = 'Text',
            Answer_Value__c = '',
            Country__c = 'KH'
        );
        insert question;

        Welcome_Call_Questionnaire_Setup__c setup = new Welcome_Call_Questionnaire_Setup__c(
            Car_Type__c = 'TRACTOR',
            Welcome_Call_Questionnaire__c = question.Id,
            Section_Name__c = 'Personal Info',
            Sequence__c = 1,
            Is_Active__c = true
        );
        insert setup;
        WelcomeCall__c welcomeCall = [SELECT Id FROM WelcomeCall__c LIMIT 1];

        // Mock answer data
        String mockAnswers =
            'a1lBK000000p965YAA:Chanathip;' +
            'a1lBK000000p966YAA:0988288714;' +
            'a1lBK000000p96HYAQ:คูโบต้าเก่านอก;' +
            'a1lBK000000p96JYAQ:1 ปี;';

        Map<String, String> answers = new Map<String, String>{
            'Answer_Value_All__c' => mockAnswers
        };

        Test.startTest();
        FormWelcomeCallQuestion.saveAnswers(welcomeCall.Id, answers);
        Test.stopTest();

        List<Welcome_Call_Questionnaire_Link__c> savedAnswers = [
            SELECT Id, Answer_Value__c, Welcome_Call__c
            FROM Welcome_Call_Questionnaire_Link__c
            WHERE Welcome_Call__c = :welcomeCall.Id
        ];

    }
}