trigger ValidateFollowUp on Case ( before update ){
  
  if (Trigger.isUpdate) {
    if (Trigger.isBefore) {
      
      //1. Validate pending TS follow up
      
      AggregateResult[] pendingFollowUp = [SELECT COUNT(Id) FROM Task where Case__r.Id IN :Trigger.New and Progress__c not in ('ยกเลิกการบริการ','ปิดงาน')];
      Integer countPending = 0;
      for(AggregateResult a:pendingFollowUp ) {
        countPending = (INTEGER)a.get('expr0');
        // String sInteger = String.valueOf(count );
      }
      
      AggregateResult[] allFollowUp = [SELECT COUNT(Id) FROM Task where Case__r.Id IN :Trigger.New ];
      Integer countAll = 0;
      for(AggregateResult b:pendingFollowUp ) {
        countAll = (INTEGER)b.get('expr0');
        // String sInteger = String.valueOf(count );
      }
      
      for(Case obj : Trigger.New) {
        String caseStatus = obj.Status;
        
        if(caseStatus == 'Resolve' || caseStatus == 'Cancel'){
          if(countPending > 0 && countAll > 0){
            obj.addError('พบงาน TS follow up ที่ยังเปิดอยู่จำนวน '+ String.valueOf(countPending )+ ' รายการ กรุณาทำรายการดังกล่าวให้เสร็จสิ้นก่อนปิดเคส');
          }
        }
      }
      
      
      //2. Validate close case
      Id profileId=userinfo.getProfileId();
      String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
      for(Case obj : Trigger.New) {
        String newCaseStatus = obj.Status;
        
        if(newCaseStatus != 'Resolve' && newCaseStatus != 'Cancel'){
          for(Case obj2 : Trigger.Old) {
            String oldCaseStatus = obj2.Status;
            if(oldCaseStatus == 'Resolve' || oldCaseStatus == 'Cancel' ){
              
              if(profileName != 'TS Supervisor and Manager'
                && profileName != 'CRM Supervisor and Manager'
                && profileName != 'CRM Supervisor and Manager Oversea'
                && profileName != 'System Administrator'
              ){
                obj.addError('คุณไม่มีสิทธิปรับสถานะเคสที่ปิดไปแล้ว กรุณาติดต่อหัวหน้างาน หรือ ผู้ดูแลระบบเพื่อปลดล็อครายการ');
                
              }
              
            }
            
          }
          
        }
        
        
        if(newCaseStatus == 'Cancel'){
          for(Case obj2 : Trigger.Old) {
            String oldCaseStatus = obj2.Status;
            if(oldCaseStatus == 'Resolve'){
              
              if(profileName != 'TS Supervisor and Manager'
                && profileName != 'CRM Supervisor and Manager'
                && profileName != 'CRM Supervisor and Manager Oversea'
                && profileName != 'System Administrator'
              ){
                obj.addError('คุณไม่มีสิทธิปรับสถานะเคสที่ปิดไปแล้ว กรุณาติดต่อหัวหน้างาน หรือ ผู้ดูแลระบบเพื่อปลดล็อครายการ');
                
              }
              
            }
            
          }
        }
      }
      
      
    }
  }
}