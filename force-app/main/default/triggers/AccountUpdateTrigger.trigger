/**
 * @description       : 
 * @author            : wara.wangchai
 * @group             : 
 * @last modified on  : 08-21-2025
 * @last modified by  : wara.wangchai
**/
trigger AccountUpdateTrigger on Account (after update) {
    if (!AccountTriggerHandler.hasExecuted) {
        AccountTriggerHandler.hasExecuted = true;
        
        List<Account> accountsToUpdate = new List<Account>();
        
        // AutoCloud [21/08/2025]
        // Dealer Record Type
        RecordType recordTypeDealer = [SELECT Id From RecordType Where SobjectType = 'Account' AND DeveloperName = 'Dealer_Master' LIMIT 1];

        for (Account newAcc : Trigger.new) {
            if (recordTypeDealer.Id == newAcc.RecordTypeId) continue; // AutoCloud [21/08/2025]

                // Check if there are any changes to the fields)

            Account oldAcc = Trigger.oldMap.get(newAcc.Id);

            // Initialize a flag to check if there's any change
            Boolean isDataChanged = false;

            // Loop through each field dynamically to compare the new and old values
            for (String fieldName : newAcc.getSObjectType().getDescribe().fields.getMap().keySet()) {
                // Skip the Is_KADS_Update__c field to avoid it triggering API unnecessarily
                if (fieldName == 'Is_KADS_Update__c') {
                    continue;
                }

                // Compare the new and old values for each field
                if (newAcc.get(fieldName) != oldAcc.get(fieldName)) {
                    isDataChanged = true;
                    break; // Exit the loop as soon as a change is detected
                }
            }

            // Only trigger API 4 if there's a real data change and the flag is false
            if (isDataChanged) {
                if (newAcc.Is_KADS_Update__c) {
                    Account accToUpdate = new Account(
                        Id = newAcc.Id,
                        Is_KADS_Update__c = false
                    );
                    accountsToUpdate.add(accToUpdate);
                }

                if (!newAcc.Is_KADS_Update__c) {
                    System.enqueueJob(new KADSUpdateQueueable(newAcc.Id));
                }
            }
        }
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}