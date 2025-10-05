trigger UpdateKISNumber on WelcomeCall__c (before insert) {

    // รวบรวม Product_Header__c ทั้งหมดจาก Trigger.New
    Set<Id> productIds = new Set<Id>();
    for (WelcomeCall__c obj : Trigger.New) {
        if (obj.Product_Header__c != null) {
            productIds.add(obj.Product_Header__c);
        }
    }

    // Query ข้อมูล Product2 ล่วงหน้า
    Map<Id, Product2> productMap = new Map<Id, Product2>(
        [SELECT Id, Name, Material_Number__c FROM Product2 WHERE Id IN :productIds]
    );

    // Loop ผ่าน WelcomeCall__c และอัปเดต KIS_number__c ตามเงื่อนไข
    for (WelcomeCall__c obj : Trigger.New) {
        Product2 prod = productMap.get(obj.Product_Header__c);
        if (prod != null && prod.Material_Number__c == 'KUBOTA-KIS') {
            obj.KIS_number__c = obj.Engine_No__c;
        }
    }
}