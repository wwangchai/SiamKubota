/**
 * @description       :
 * @author            : Chanathip
 * @group             :
 * @last modified on  : 11-30-2025
 * @last modified by  : wara.wangchai
 **/
public class WelcomeCallService {
    
    @AuraEnabled
    public static Id createWelcomeCall(Id id) {
        
        Id wcId = null;
        try {
            
            System.debug(id);
            order ds = [SELECT Id, Kubota_Id__c, Product__c, Branch_Plant_Code__c, 
                                  Branch_Plant_Code__r.Name, Branch_Plant_Code__r.Store_province__c,
                                  Chassis_Implement_Serial_Number__c, Engine_Code__c, Sale_Date__c,
                                  KIS_Number__c, Product_Type__c, LANDTX__c, Kubota_Id__r.Address_ID__c,
                                  Address_ID__c, Kubota_Id__r.Address_SRV__c, Kubota_Id__r.Building_ID__c,
                                  Building_ID__c, Kubota_Id__r.Building_SRV__c, Kubota_Id__r.Country_ID__c,Kubota_Id__r.Country_Native__c,
                                  Kubota_Id__r.Country_Srv__c, Kubota_Id__r.District_ID__c, District_ID__c,
                                  Kubota_Id__r.District_Srv__c,Kubota_Id__r.Sub_District_Srv__c, Kubota_Id__r.Floor_ID__c, Floor_ID__c,
                                  Kubota_Id__r.Mobile_ID__c, Kubota_Id__r.Mobile_Srv__c, Kubota_Id__r.Moo_ID__c,
                                  Moo_ID__c, Kubota_Id__r.Moo_Srv__c, Remark__c, Payment_Method__c, Tel_ID__c,
                                  Kubota_Id__r.Postcode_ID__c, Kubota_Id__r.Postcode_Srv__c, Kubota_Id__r.Province_ID__c,
                                  Province_ID__c, Province_Srv__c, Room_ID__c, Tel_Srv__c, Branch_Plant_Code__r.Dealer_Name__c,
                                  Branch_Plant_Code__r.Plant_name__c, Kubota_Id__r.Soi_ID__c, Soi_ID__c, Kubota_Id__r.Soi_Srv__c,
                                  Kubota_Id__r.Street_ID__c, Street_ID__c,Kubota_Id__r.Street_Srv__c,Subdistrict_ID__c,
                                  Kubota_Id__r.Sub_District_ID__c, Subdistrict_Srv__c, Kubota_Id__r.Kubota_VIP__c,
                                  Kubota_Id__r.Village_ID__c,Village_ID__c, Kubota_Id__r.Village_Native__c, IS_Duplicate__c,
                                  Product__r.SKC_Model__c, Postcode_ID__c, Kubota_Id__r.Consent__c,Kubota_Id__r.First_Name_Native__c,
                                  First_Name__c,Last_Name__c,Kubota_Id__r.Last_Name_Native__c,Product__r.Family,Kubota_Id__r.Country_SP__c,Kubota_Id__r.Village_Srv__c,
                                  Kubota_Id__r.Country_Native_SP__c,Kubota_Id__r.District_Native_SP__c,Kubota_Id__r.Sub_District_Native_SP__c,Kubota_Id__r.Village__c,
                                  Kubota_Id__r.District_Native__c,Kubota_Id__r.Province_Native__c,Kubota_Id__r.Province_Native_SP__c,Kubota_Id__r.Sub_District_Native__c
                                  FROM order WHERE Id =: id];
            String name = ds.Product_Type__c + ' (รถ%';
            List<RecordType> wcRecList = [
                    SELECT Id, Name 
                    FROM RecordType 
                    WHERE (Name LIKE :name OR Name = 'DRONE') 
                    AND sObjectType = 'WelcomeCall__c' 
                    LIMIT 1
                ];
            if (wcRecList.isEmpty()) {
                throw new AuraHandledException('ไม่พบ RecordType ที่ตรงเงื่อนไข');
            }
            RecordType wcRec = wcRecList[0];
            
            RecordType wctTypeOVS = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'WelcomeCall__c' and Name = 'WelcomeCall Oversea' LIMIT 1];
            
            // select Id, Name from Group where Type = 'Queue'  and Name = 'CRM Center Overseas'
            Group g = [select Id, Name from Group where Type = 'Queue' AND Name = 'ศูนย์บริการลูกค้าสัมพันธ์ภายในประเทศ'];
            Group gowc = [select Id, Name from Group where Type = 'Queue'  and Name = 'CRM Center Overseas'];
            
            WelcomeCall__c wc = new WelcomeCall__c();
            Welcomecall_Oversea__c owc = new Welcomecall_Oversea__c();
            
            wc.RecordTypeId = wcRec.Id;
            // owc.RecordTypeId = wctTypeOVS.Id;
            //  if(ds.IS_Duplicate__c == 'No' && ds.LANDTX__c == 'TH') {
                if((ds.IS_Duplicate__c == 'No')&&(ds.LANDTX__c == 'TH')) {
                    wc.Address_ID__c = ds.Kubota_Id__r.Address_ID__c;
                    wc.Address_SP__c = ds.Address_ID__c;
                    wc.Address_SRV__c = ds.Kubota_Id__r.Address_SRV__c;
                    wc.Building_ID__c = ds.Kubota_Id__r.Building_ID__c;
                    wc.Building_SP__c = ds.Building_ID__c;
                    wc.Building_SRV__c = ds.Kubota_Id__r.Building_SRV__c;
                    wc.Car_type__c = ds.Product_Type__c;
                    wc.Contact_status__c = 'รายการใหม่/Open';
                    wc.Country_ID__c = ds.Kubota_Id__r.Country_ID__c;
                    wc.Country_SRV__c = ds.Kubota_Id__r.Country_Srv__c;
                    wc.Customer__c = ds.Kubota_Id__c;
                    wc.Daily_Sales_Kads_order__c = ds.Id; //Daily_Sales_Kads_order__c
                    wc.Date_key__c = ds.Sale_Date__c;
                    wc.Date_of_purchase_AD__c = ds.Sale_Date__c;
                    wc.District_ID__c = ds.Kubota_Id__r.District_ID__c;
                    wc.District_SP__c = ds.District_ID__c;
                    wc.District_SRV__c = ds.Kubota_Id__r.District_Srv__c;
                    wc.Dealer_Name_Account__c = ds.Branch_Plant_Code__c;
                    wc.Duedate__c = System.today();
                    wc.Engine_No__c = ds.Engine_Code__c;
                    wc.Floor_ID__c = ds.Kubota_Id__r.Floor_ID__c;
                    wc.Floor_SP__c = ds.Floor_ID__c;
                    wc.LANDTX__c = ds.LANDTX__c;
                    wc.Mobile_number_1__c = ds.Kubota_Id__r.Mobile_ID__c;
                    wc.Mobile_number_2__c = ds.Kubota_Id__r.Mobile_Srv__c;
                    wc.Model__c = ds.Product__r.SKC_Model__c;
                    wc.Moo_ID__c = ds.Kubota_Id__r.Moo_ID__c;
                    wc.Moo_SP__c = ds.Moo_ID__c;
                    wc.Moo_SRV__c = ds.Kubota_Id__r.Moo_Srv__c;
                    wc.Name_of_document_recipient_parcel__c = 'ชื่อลูกค้า';
                    wc.Note_from_ADMS__c = ds.Remark__c;
                    wc.OwnerId = g.Id;
                    wc.Payment_Method__c = ds.Payment_Method__c;
                    wc.Phone_number_home__c = ds.Tel_ID__c;
                    wc.Postcode_ID__c = ds.Kubota_Id__r.Postcode_ID__c;
                    wc.Postcode_SP__c = ds.Postcode_ID__c;
                    wc.Postcode_SRV__c = ds.Kubota_Id__r.Postcode_Srv__c;
                    wc.Product_Header__c = ds.Product__c;
                    wc.Product_Detail__c = ds.Product__c;
                    wc.Province_ID__c = ds.Kubota_Id__r.Province_ID__c;
                    wc.Province_SP__c = ds.Province_ID__c;
                    wc.Province_SRV__c = ds.Province_Srv__c;
                    wc.Room_No_SP__c = ds.Room_ID__c;
                    wc.Serial_number__c = ds.Chassis_Implement_Serial_Number__c;
                    wc.Service_Check_Phone_Number__c = ds.Tel_Srv__c;
                    wc.Shop_Name__c = ds.Branch_Plant_Code__r.Dealer_Name__c + '  -  ' + ds.Branch_Plant_Code__r.Plant_name__c;
                    wc.Soi_ID__c = ds.Kubota_Id__r.Soi_ID__c;
                    wc.Soi_SP__c = ds.Soi_ID__c;
                    wc.Soi_Srv__c = ds.Kubota_Id__r.Soi_Srv__c;
                    wc.Store_province__c = ds.Branch_Plant_Code__r.Store_province__c;
                    wc.Street_ID__c = ds.Kubota_Id__r.Street_ID__c;
                    wc.Street_SP__c = ds.Street_ID__c;
                    wc.Street_SRV__c = ds.Kubota_Id__r.Street_Srv__c;
                    wc.Sub_District_ID__c = ds.Kubota_Id__r.Sub_District_ID__c;
                    wc.Sub_District_SP__c = ds.Subdistrict_ID__c;
                    wc.Sub_District_SRV__c = ds.Subdistrict_Srv__c;
                    wc.VIP_Number__c = ds.Kubota_Id__r.Kubota_VIP__c;
                    wc.VIP_Status__c = 'VIP';
                    wc.Village_ID__c = ds.Kubota_Id__r.Village_ID__c;
                    wc.Village_SP__c = ds.Village_ID__c;
                    wc.Village_SRV__c = ds.Kubota_Id__r.Village_Native__c;
                    wc.purchaser__c = ds.Kubota_Id__c;
                    wc.KIS_number__c = ds.KIS_Number__c;
                    wc.Consent__c = ds.Kubota_Id__r.Consent__c;
                    wc.Contact_notes__c = 'ติดตามงาน Welcome Call ครั้งที่ 1';
                    insert wc;
                    
                    wcId = wc.id;
                }
                else if((ds.IS_Duplicate__c == 'No')&&(ds.LANDTX__c != 'TH')){
                    owc.After_Sale_Service_Dealer__c = ds.Branch_Plant_Code__c;
                    owc.Chassis_No__c = ds.Chassis_Implement_Serial_Number__c;
                    owc.Customer__c = ds.Kubota_Id__r.Id;
                    owc.Daily_Sales_Kads_order__c = ds.Id;
                    owc.Date_of_Purchase__c = ds.Sale_Date__c;
                    owc.Dealer_Name_Account__c = ds.Branch_Plant_Code__c;
                    owc.Due_Date__c = System.today();
                    owc.Engine_No__c = ds.Engine_Code__c;
                    owc.First_Name_Eng__c = ds.First_Name__c;
                    owc.First_Name_Native__c = ds.Kubota_Id__r.First_Name_Native__c;
                    owc.Last_Name_Eng__c = ds.Last_Name__c;
                    owc.Last_Name_Native__c = ds.Kubota_Id__r.Last_Name_Native__c;
                    // owc.Mobile_number_1__c = ds.Kubota_Id__r.Mobile_ID__c;
                    // owc.Mobile_number_2__c = ds.Kubota_Id__r.Mobile_Srv__c;
                    owc.Mobile_phone_no_1__c = ds.Kubota_Id__r.Mobile_ID__c;
                    owc.Mobile_phone_no_2__c = ds.Kubota_Id__r.Mobile_Srv__c;                    
                    owc.Model__c = ds.Product__r.SKC_Model__c;
                    owc.OwnerId = gowc.Id;
                    owc.Payment_Method__c = ds.Payment_Method__c;
                    owc.Product_Type__c = ds.Product__r.Family;
                    owc.Product__c = ds.Product__c;
                    
                    owc.Province_ID__c = ds.Kubota_Id__r.Province_ID__c;
                    owc.Province_Native_ID__c = ds.Kubota_Id__r.Province_Native__c;
                    owc.Province_SP__c = ds.Province_ID__c;
                    // owc.Province_SRV__c = ds.Province_Srv__c;
                    owc.Province_Native_SP__c = ds.Kubota_Id__r.Province_Native_SP__c;
                    
                    owc.District_ID__c = ds.Kubota_Id__r.District_ID__c;
                    owc.District_Native_ID__c = ds.Kubota_Id__r.District_Native__c;
                    owc.District_SP__c = ds.District_ID__c;
                    // owc.District_SRV__c = ds.Kubota_Id__r.District_Srv__c;
                    owc.District_Native_SP__c= ds.Kubota_Id__r.District_Native_SP__c;
                    
                    owc.Sub_District_ID__c = ds.Kubota_Id__r.Sub_District_ID__c;
                    owc.Sub_District_Native_ID__c = ds.Kubota_Id__r.Sub_District_Native__c;
                    owc.Sub_District_SP__c = ds.Subdistrict_ID__c;
                    // owc.Sub_District_SRV__c = ds.Kubota_Id__r.Sub_District_Srv__c;
                    owc.Sub_District_Native_SP__c = ds.Kubota_Id__r.Sub_District_Native_SP__c;
                    
                    owc.Country_ID__c = ds.Kubota_Id__r.Country_ID__c;
                    owc.Country_Native_ID__c = ds.Kubota_Id__r.Country_Native__c;
                    owc.Country_SP__c = ds.Kubota_Id__r.Country_SP__c;
                    owc.Country_Native_SP__c = ds.Kubota_Id__r.Country_Native_SP__c;
                    // owc.Country_SRV__c = ds.Kubota_Id__r.Country_Srv__c;
                    
                    owc.Village_ID__c = ds.Kubota_Id__r.Village_ID__c;
                    owc.Village_Native_ID__c = ds.Kubota_Id__r.Village_Native__c;
                    owc.Postcode_SP__c = ds.Village_ID__c;
                    // owc.Postcode_SRV__c = ds.Kubota_Id__r.Village_Srv__c;
                    owc.Postcode_Native_SP__c = ds.Kubota_Id__r.Village__c;
                    
                    owc.Tel_ID__c = ds.Tel_ID__c;
                    owc.Welcome_Call_Type__c = 'Welcome Call Round 1';
                    insert owc;
                    system.debug(owc);
                    wcId = owc.id;
                }
                
            } catch (Exception e){
                System.debug(e.getMessage());
            }
            return wcId;
        }
    }