public with sharing class OVSNotification {
    
    /**
     * Wrapper class to represent the structured data for JSON serialization.
     */
    public class RecordWrapper {
        public String link { get; set; }
        public String KubotaID { get; set; }
        public String SalesforceID { get; set; }
        public String title { get; set; }
        public String body { get; set; }
        public String type { get; set; }
        public String action { get; set; }
        public Map<String, String> data { get; set; }
    }
    
    public static void executeLogic(List<RecordWrapper> wrapperList) {
        
        // Step 1: Load Notification API metadata
        Map<String, Notification_API__mdt> apiLinks = new Map<String, Notification_API__mdt>();
        List<Notification_API__mdt> linkSurveySent = [
            SELECT Id, APIResourcePaht__c, QualifiedApiName 
            FROM Notification_API__mdt 
            WHERE QualifiedApiName IN (
                'DSMFirst', 'DSMNotTH', 'DSOtherJobs_Delivery', 
                'DSOtherJobs_Warranty_Claim', 'DSOtherJobs_Repairing', 
                'DSZI01', 'DSMOnlyKH'
            )
            WITH SECURITY_ENFORCED
        ];
        for (Notification_API__mdt api : linkSurveySent) {
            apiLinks.put(api.QualifiedApiName, api);
        }
        
        // Step 2: Get RecordType ID for 'Daily_Sales'
        RecordType dstype = [SELECT Id FROM RecordType WHERE DeveloperName = 'Daily_Sales' LIMIT 1];
        
        // Step 3: Query Orders
        List<Order> DsmOnlyKH = [
            SELECT Id, Kubota_Id__r.Kubota_Id__c, LANDTX__c, CreatedDate, Product_Type__c, 
                    Name, Payment_Method__c, Sale_Date__c, Branch_Plant_Code__r.Name, Kubota_Id__r.Age__c
            FROM Order 
            
            WHERE 
            Product_Type__c!= 'IMPLEMENT' AND LANDTX__c = 'KH' AND KubotaId__c != null AND CreatedDate >=  LAST_N_DAYS:1 AND RecordTypeId = :dstype.Id
            WITH SECURITY_ENFORCED
        ];
        
        // Step 4: Query WelcomeCall records
        // Step 4: Query WelcomeCall records
        Map<Id, WelcomeCall__c> orderToWelcomeCallMap = new Map<Id, WelcomeCall__c>();
        for (WelcomeCall__c wc : [
            SELECT Id, Daily_Sales_Kads_Order__c, Number_of_vehicles_owned_cars__c 
            FROM WelcomeCall__c 
            WHERE Daily_Sales_Kads_Order__c IN :DsmOnlyKH
        ]) {
            orderToWelcomeCallMap.put(wc.Daily_Sales_Kads_Order__c, wc); // key = Order.Id
        }
        
        System.debug('orderToWelcomeCallMap: ' + orderToWelcomeCallMap);
        
        Set<Id> welcomeCallIds = new Set<Id>();
        for (WelcomeCall__c wc : orderToWelcomeCallMap.values()) {
            welcomeCallIds.add(wc.Id);
        }
        
        System.debug('welcomeCallIds All: ' + welcomeCallIds);
        
        List<Welcome_Call_Questionnaire_Link__c> questionnaireLinks = [
        SELECT Id, Answer_Value__c, Welcome_Call__c, Key_Long_Text_Area__c , Questionnaire_Label_Text_Area__c 
        FROM Welcome_Call_Questionnaire_Link__c
        WHERE Welcome_Call__c IN :welcomeCallIds
    ];
        
        // STEP 1: สร้าง Map จาก questionnaireLinks
        Map<Id, Map<String, String>> questionnaireMap = new Map<Id, Map<String, String>>();
        
        for (Welcome_Call_Questionnaire_Link__c ql : questionnaireLinks) {
            List<String> questions = (ql.Questionnaire_Label_Text_Area__c != null)
                ? ql.Questionnaire_Label_Text_Area__c.split(';')
                : new List<String>();
            
            List<String> answers = (ql.Answer_Value__c != null)
                ? ql.Answer_Value__c.split(';')
                : new List<String>();
            
            
            // ถ้ายังไม่มี Map ของ WC นี้ ให้สร้างใหม่
            if (!questionnaireMap.containsKey(ql.Welcome_Call__c)) {
                questionnaireMap.put(ql.Welcome_Call__c, new Map<String, String>());
            }
            Map<String, String> qaMap = questionnaireMap.get(ql.Welcome_Call__c);
            
            // match question–answer ตาม index
            for (Integer i = 0; i < questions.size(); i++) {
                String q = questions[i].trim();
                String a = (i < answers.size()) ? answers[i].trim() : '';
                if (q != '') {
                    qaMap.put(q, a);
                }
            }
        }
        
        // STEP 2: ใช้ใน loop Order
        for (Order dsk : DsmOnlyKH) {
            RecordWrapper wrapper = new RecordWrapper();
            wrapper.KubotaID = dsk.Kubota_Id__r.Kubota_Id__c;
            wrapper.SalesforceID = dsk.Id;
            wrapper.title = 'តើអ្នកមានអារម្មណ៍បែបណាបន្ទាប់ពីបានទទួលសេវាកម្មពីគូបូតា?';
            wrapper.body = 'សូមផ្តល់ពិន្ទុការទទួលសេវាកម្មពីគូបូតា';
            wrapper.type = 'QUESTIONNAIRE';
            wrapper.action = 'WEBVIEW';
            wrapper.link = apiLinks.containsKey('DSMOnlyKH') ? apiLinks.get('DSMOnlyKH').APIResourcePaht__c : '';
            
            String saleDateStr = (dsk.Sale_Date__c != null) ? dsk.Sale_Date__c.format() : '';
            Map<String, String> dataMap = new Map<String, String>();
            dataMap.put('purchasedProduct', dsk.Product_Type__c != null ? dsk.Product_Type__c : '');
            dataMap.put('purchasedDate', saleDateStr);
            dataMap.put('purchasedFormDealer', (dsk.Branch_Plant_Code__r != null && dsk.Branch_Plant_Code__r.Name != null) ? dsk.Branch_Plant_Code__r.Name : '');
            dataMap.put('paymentType', dsk.Payment_Method__c != null ? dsk.Payment_Method__c : '');
            dataMap.put('CustomerAge', (dsk.Kubota_Id__r != null && dsk.Kubota_Id__r.Age__c != null) ? dsk.Kubota_Id__r.Age__c : '');
            
            // 🔑 เอา WelcomeCall จาก Order
            WelcomeCall__c wel = orderToWelcomeCallMap.get(dsk.Id);
            Map<String, String> qMap = (wel != null) ? questionnaireMap.get(wel.Id) : null;
            
            String occupation = '';
            String mainCrop = '';
            if (qMap != null) {
                // check คำถามได้หลายภาษา/label
                if (qMap.containsKey('อาชีพหลัก')) occupation = qMap.get('อาชีพหลัก');
                else if (qMap.containsKey('Main Occupation')) occupation = qMap.get('Main Occupation');
                
                if (qMap.containsKey('พืชที่ปลูก1')) mainCrop = qMap.get('พืชที่ปลูก1');
                else if (qMap.containsKey('Main Crop')) mainCrop = qMap.get('Main Crop');
            }
            
            String numberOfVehicles = (wel != null && wel.Number_of_vehicles_owned_cars__c != null) ? wel.Number_of_vehicles_owned_cars__c : '';
            Integer vehicleCount = (numberOfVehicles != '') ? Integer.valueOf(numberOfVehicles) : 0;
            String typeOfCustomerValue = (vehicleCount > 1) ? 'Repurchase' : 'New';
            
            // ใส่ใน dataMap
            dataMap.put('Occupation', occupation);
            dataMap.put('mainCrop', mainCrop);
            dataMap.put('typeOfCustomer', typeOfCustomerValue);
            
            wrapper.data = dataMap;
            wrapperList.add(wrapper);
        }
        // Step 8: Serialize and send
        String jsonString = JSON.serializePretty(wrapperList);
        system.debug('jsonString:' + jsonString);
        makeHttpPostRequest(jsonString);
        
        
    }
    
    // Dummy method for HTTP POST (implement as needed)
    @future(callout = true)
    public static void makeHttpPostRequest(String jsonString) {
        try {
            List<Notification_API__mdt> configMetaDataList = [
            SELECT Id, APIResourcePaht__c  
            FROM Notification_API__mdt 
            WHERE QualifiedApiName = 'LinkAPINoti' 
            WITH SECURITY_ENFORCED 
            LIMIT 1
        ];
            
            System.debug('Request Body: ' + jsonString);
            if (!configMetaDataList.isEmpty()) {
                Notification_API__mdt config = configMetaDataList[0];
                String endpointUrl = config.APIResourcePaht__c;
                
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:LinkAPINotification' + endpointUrl);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setBody(jsonString);
                
                Http http = new Http();
                HttpResponse response = http.send(request);
                
                System.debug('HTTP Response Body: ' + response.getBody());
                System.debug('HTTP Response Status: ' + response.getStatus());
                
                // ✅ Insert Service Log
                Service_Log__c log = new Service_Log__c();
                log.Request__c = jsonString; // request body
                log.Response__c = response.getBody(); // response body
                log.API_Name__c = 'OVS Welcome Call Survey';
                log.Status__c = 'S';
                insert log;
            } else {
                System.debug('No configuration found in Notification_API__mdt');
            }
        } catch (Exception e) {
            System.debug('Error making HTTP POST request: ' + e.getMessage());
            
            // ✅ เก็บ Log error ด้วย
            Service_Log__c log = new Service_Log__c();
            log.Request__c = jsonString;
            log.Response__c = 'Error: ' + e.getMessage();
            log.API_Name__c = 'OVS Welcome Call Survey';
            log.Status__c = 'F';
            insert log;
        }
    }
}