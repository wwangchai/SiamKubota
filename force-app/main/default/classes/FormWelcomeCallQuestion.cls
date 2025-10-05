public with sharing class FormWelcomeCallQuestion {
    
    // Wrapper class สำหรับส่งคำถาม + คำตอบกลับไปยัง LWC
    public class QuestionWithAnswerWrapper {
        @AuraEnabled public Id questionId;
        @AuraEnabled public String label;
        @AuraEnabled public String section;
        @AuraEnabled public String answerType;
        @AuraEnabled public String answerValues;
        @AuraEnabled public String answer;
        @AuraEnabled public Boolean isFullWidth;
        @AuraEnabled public Boolean IsDisable;
        @AuraEnabled public Boolean isResolve;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<QuestionWithAnswerWrapper> QuestionWelcome(Id welcomeCallId) {
        System.debug('📌 welcomeCallId: ' + welcomeCallId);
        
        WelcomeCall__c welcomeCall = [
        SELECT Id, RecordTypeId ,Daily_Sales_Kads_Order__r.LANDTX__c,Product_Type__c,Car_Type__c
        FROM WelcomeCall__c 
        WHERE Id = :welcomeCallId 
        LIMIT 1
    ];
        
        if (welcomeCall == null || welcomeCall.RecordTypeId == null) {
            System.debug('❌ ไม่พบ Welcome_Call หรือไม่มี RecordTypeId');
            return new List<QuestionWithAnswerWrapper>();
        }
        
        RecordType rt = [
        SELECT Id, DeveloperName 
        FROM RecordType 
        WHERE Id = :welcomeCall.RecordTypeId 
        LIMIT 1
    ];
        
        System.debug('✅ welcomeCall.Car_Type__c: ' + welcomeCall.Car_Type__c);
        System.debug('✅ welcomeCall.Product_Type__c: ' + welcomeCall.Product_Type__c);
        Boolean isResolve = rt.DeveloperName.toLowerCase().contains('resolve');
        String carType = String.isNotBlank(welcomeCall.Car_Type__c)
            ? welcomeCall.Car_Type__c
            : welcomeCall.Product_Type__c;
        
        string LandTx = welcomeCall.Daily_Sales_Kads_Order__r.LANDTX__c;
        if (isResolve) {
            carType = carType.replaceAll('(?i)_Resolve', '');
        }
        
        System.debug('✅ DeveloperName: ' + rt.DeveloperName);
        System.debug('✅ carType: ' + carType);
        System.debug('✅ LandTx: ' + LandTx);
        
        List<Welcome_Call_Questionnaire_Setup__c> questions = [
    SELECT Id, Welcome_Call_Questionnaire__c, Car_Type__c, Sequence__c, Questionnaire_Label__c, Section_Name__c,
           Full_Field__c,
           Welcome_Call_Questionnaire__r.Questionnaire_Label__c,
           Welcome_Call_Questionnaire__r.Answer_Type__c,
           Welcome_Call_Questionnaire__r.Answer_Value__c
            FROM Welcome_Call_Questionnaire_Setup__c 
            WHERE Car_Type__c = :carType 
            AND Is_Active__c = true 
            AND Welcome_Call_Questionnaire__r.Country__c = :landTx
            ORDER BY Sequence__c ASC
];
        
        System.debug('Size Question: '+ questions);
        // ดึงคำตอบทั้งหมด
        List<Welcome_Call_Questionnaire_Link__c> answerRecordList = [
        SELECT Id, Welcome_Call__c, Answer_Value__c, Key_for_Saving__c, Answer_Value_All__c,
            Welcome_Call_Questionnaire_Setup__c, Key_Long_Text_Area__c
        FROM Welcome_Call_Questionnaire_Link__c 
        WHERE Welcome_Call__c = :welcomeCallId
    ];
        
        List <Welcome_Call_Questionnaire_Link__c> answerRecord = [
                SELECT Answer_Value__c , Key_Long_Text_Area__c
                FROM Welcome_Call_Questionnaire_Link__c 
                WHERE Welcome_Call__c = :welcomeCallId
    ];
        
        
        Map<String, String> answerMap = new Map<String, String>();
        
        Boolean hasAnswerAll = false;
        System.debug('questions setup : ' + questions);
        for (Welcome_Call_Questionnaire_Link__c record : answerRecordList) {
            if (String.isNotBlank(record.Answer_Value_All__c)) {
                hasAnswerAll = true;
                break;
            }
        }
        if (!hasAnswerAll) {
            // ใช้ Key_Long_Text_Area__c + Answer_Value__c
            System.debug('📨 ใช้คำตอบจาก Link__c');
            for (Welcome_Call_Questionnaire_Link__c record : answerRecordList) {
                if (!String.isBlank(record.Key_Long_Text_Area__c) && !String.isBlank(record.Answer_Value__c)) {
                    List<String> keyIds = record.Key_Long_Text_Area__c.split(';');
                    List<String> values = record.Answer_Value__c.split(';');
                    Integer size = Math.min(keyIds.size(), values.size());
                    
                    for (Integer i = 0; i < size; i++) {
                        String key = keyIds[i];
                        String value = values[i];
                        if (!String.isBlank(key)) {
                            answerMap.put(key, value);
                        }
                    }
                }
            }
        } else {
            System.debug('📨 ใช้ Answer_Value_All__c');
            try {
                Welcome_Call_Questionnaire_Link__c answerRecordd = [
                SELECT Answer_Value_All__c 
                FROM Welcome_Call_Questionnaire_Link__c 
                WHERE Welcome_Call__c = :welcomeCallId 
                LIMIT 1
            ];
                
                if (answerRecordd != null && !String.isBlank(answerRecordd.Answer_Value_All__c)) {
                    for (String pair : answerRecordd.Answer_Value_All__c.split(';')) {
                        Integer sepIndex = pair.indexOf('::');
                        if (sepIndex > 0) {
                            String key = pair.substring(0, sepIndex);
                            String value = pair.substring(sepIndex + 2); // ข้าม "::"
                            answerMap.put(key, value);
                        }
                    }
                }
            } catch (Exception e) {
                System.debug('⚠️ ไม่พบคำตอบเดิม: ' + e.getMessage());
            }
        }
        
        // รวมคำถาม + คำตอบ
        List<QuestionWithAnswerWrapper> result = new List<QuestionWithAnswerWrapper>();
        for (Welcome_Call_Questionnaire_Setup__c q : questions) {
            QuestionWithAnswerWrapper wrap = new QuestionWithAnswerWrapper();
            wrap.questionId = q.Id;
            wrap.label = q.Questionnaire_Label__c;
            wrap.section = q.Section_Name__c;
            wrap.answerType = q.Welcome_Call_Questionnaire__r.Answer_Type__c;
            wrap.answerValues = q.Welcome_Call_Questionnaire__r.Answer_Value__c;
            wrap.answer = answerMap.containsKey(q.Id) ? answerMap.get(q.Id) : null;
            wrap.isFullWidth = q.Full_Field__c;
            wrap.IsDisable = isResolve;
            wrap.isResolve = isResolve;
            result.add(wrap);
        }
        
        return result;
    }
    
    
    @AuraEnabled
    public static void saveAnswers(Id welcomeCallId, Map<String, String> answers) {
        String allAnswers = answers.get('Answer_Value_All__c');
        System.debug('📨 Formatted Answers: ' + allAnswers);
        System.debug('Check String :' + answers);
        if (String.isBlank(allAnswers) || welcomeCallId == null) {
            throw new AuraHandledException('Missing welcomeCallId or answer data');
        }
        
        List<String> keyList = new List<String>();
        List<String> valueList = new List<String>();
        List<Welcome_Call_Questionnaire_Link__c> recordsToUpsert = new List<Welcome_Call_Questionnaire_Link__c>();
        
        List<String> pairs = allAnswers.split(';');
        System.debug('pairs :' + pairs);
        
        for (String pair : pairs) {
            if (String.isBlank(pair)) continue;
            
            List<String> parts = pair.split(':');
            
            String idQuestion = parts[0];
            String answerValue;
            
            if (parts.size() < 2 || String.isBlank(parts[1])) {
                answerValue = '';
            } else if (parts.size() > 2) {
                List<String> subParts = new List<String>();
                for (Integer i = 1; i < parts.size(); i++) {
                    subParts.add(parts[i]);
                }
                answerValue = String.join(subParts, ':');
            } else {
                answerValue = parts[1];
            }
            // เก็บใส่ list
            keyList.add(idQuestion);
            valueList.add(answerValue);
        }
        
        // join key กับ value แยกเป็น string
        String keysJoined = String.join(keyList, ';');
        String valuesJoined = String.join(valueList, ';');
        
        System.debug('🔑 Keys   :' + keysJoined);
        System.debug('📝 Values :' + valuesJoined);
        
        // query setup
        Map<Id, Welcome_Call_Questionnaire_Setup__c> setupMap = new Map<Id, Welcome_Call_Questionnaire_Setup__c>(
            [SELECT Id, Questionnaire_Label__c 
         FROM Welcome_Call_Questionnaire_Setup__c 
         WHERE Id IN :keyList]
            );
        
        // สร้าง list เก็บ label
        List<String> questionLabels = new List<String>();
        for (String keyId : keyList) {
            if (setupMap.containsKey(Id.valueOf(keyId))) {
                questionLabels.add(setupMap.get(Id.valueOf(keyId)).Questionnaire_Label__c);
            } else {
                questionLabels.add(''); // กันพลาด
            }
        }
        
        // join labels เป็น string
        String questionsJoined = String.join(questionLabels, ';');
        
        recordsToUpsert.add(new Welcome_Call_Questionnaire_Link__c(
            Key_for_Saving__c = welcomeCallId,
        Answer_Value__c = valuesJoined,
        Welcome_Call__c = welcomeCallId,
        Key_Long_Text_Area__c = keysJoined,
        Questionnaire_Label_Text_Area__c = questionsJoined // ✅ เก็บเป็น string
            ));
        
        try {
            upsert recordsToUpsert Key_for_Saving__c;
        } catch (Exception e) {
            System.debug('❌ Error during upsert: ' + e.getMessage());
            throw new AuraHandledException('Error saving answers: ' + e.getMessage());
        }
    }
    
 
}