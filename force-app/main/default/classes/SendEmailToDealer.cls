/**
 * @description       : 
 * @author            : wara.wangchai
 * @group             : 
 * @last modified on  : 08-19-2025
 * @last modified by  : wara.wangchai
**/
public class SendEmailToDealer {
    @auraEnabled
    public static Integer sendEmailToDealer(String recordId){
        Integer num = 0;
        for(Case cc : [SELECT Id,CaseNumber,Plant_Code_Under_SSC_Account__c FROM Case WHERE Id =: recordId]){
            
            contact con=[Select Id from contact Where LastName = 'System' limit 1];
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            mail.setTargetObjectId(con.Id);
            mail.setWhatId(cc.Id);
            mail.setTemplateId('00X2x000000cecHEAQ');             
            mail.setBccSender(true); 
            mail.setUseSignature(false);  
            mail.setSaveAsActivity(true); 
            mail.setWhatId(cc.Id);
            List<String> sendTo = new List<String>();
               
            for(Account orgDir : [Select Dealer_Email__c, Dealer_Email_2__c from Account WHERE Id = :cc.Plant_Code_Under_SSC_Account__c]){
                //sendTo.add(orgDir.Email__c);
                String emailList = orgDir.Dealer_Email_2__c == null? orgDir.Dealer_Email__c : orgDir.Dealer_Email_2__c;
                for (String email : emailList.split(';')){
                    sendTo.add(email);
                }
                
            } 
            num = sendTo.size();
            
            mail.setToAddresses(sendTo); 
            if(num > 0){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            System.debug('Number: ' + num);
        }
        
        return num;
    }  
}