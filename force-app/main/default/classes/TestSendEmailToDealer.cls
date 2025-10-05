/**
 * @description       : 
 * @author            : wara.wangchai
 * @group             : 
 * @last modified on  : 07-29-2025
 * @last modified by  : wara.wangchai
**/
@isTest
public class TestSendEmailToDealer {

    @isTest static void TestSendEmail(){
        
        DealerMaster__c dealerOjb = new DealerMaster__c(Dealer_Email__c='test@gmail.com',Main_SSC__c='ศูนย์ฯ สระแก้ว',Sub_SSC__c='ศูนย์ฯ สระแก้ว',Main_Branch__c=true,Plant_code__c='SKC_SAKAEO');
        insert dealerOjb;
        
        Contact con = new Contact(LastName='System',Email='system@dummy.com');    
        insert con;

        
        Case caseObj = new Case(Primary_Service_Center__c='ศูนย์ฯ สระแก้ว',Plant_Code_Under_SSC_Account__c=dealerOjb.Id);
        insert caseObj;
		         
        Test.startTest();
        SendEmailToDealer.sendEmailToDealer(caseObj.Id);
     
        Test.stopTest(); 
    }
}