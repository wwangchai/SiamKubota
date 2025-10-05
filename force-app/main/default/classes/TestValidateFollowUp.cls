@isTest
private class TestValidateFollowUp {
    @isTest static void TestUpdateCase(){
        Case caseObj = new Case(Status='Resolve');
        insert caseObj;
        
        Test.startTest();
            caseObj.Status = 'Open';
            update caseObj;
        Test.stopTest(); 
    }

    @isTest static void TestUpdateCasecancel(){
        Case caseObj = new Case(Status='Resolve');
        insert caseObj;
        
        Test.startTest();
            caseObj.Status = 'Cancel';
            update caseObj;
        Test.stopTest(); 
    }
}