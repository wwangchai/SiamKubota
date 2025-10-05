/**
 * @description       : 
 * @author            : piyaphat.n@kubota.com
 * @group             : 
 * @last modified on  : 11-02-2025
 * @last modified by  : piyaphat.n@kubota.com
**/
public class KADSUpdateQueueable implements Queueable, Database.AllowsCallouts {
    private Id accountId;

    public KADSUpdateQueueable(Id accId) {
        this.accountId = accId;
    }

    public void execute(QueueableContext context) {
        try {
                  // Query needed fields dynamically
        Account acc = [
            SELECT Id, Data_Source__c, Kubota_Id__c, Citizen_Id__c, Mobile_phone_no_1__c,
                   User_Level__c, Salutation, FirstName, LastName,
                   BranchCode__c, BranchCodeDescription__c, PassportNo__c,
                   PassportIssueCountry__c, CompanyName1__c, CompanyName2__c,
                   CompanyName3__c, CompanyName4__c, CustomerConditionGroup__c,
                   Consent1__c, Consent2__c, PDPASignature__c, LANDTX__c,
                   BusinessType__c, PersonBirthdate, PassportValidFromDate__c, PassportValidToDate__c,Is_KADS_Update__c, 
                   
                   // Default Address Fields (ID)
                   Address_ID__c, Room_No_ID__c, Floor_ID__c, Building_ID__c,
                   Moo_ID__c, Soi_ID__c, Village_ID__c, Street_ID__c,
                   Telephone_ID__c, TelephoneExt_ID__c, Mobile_ID__c,
                   Fax_ID__c, FaxExtension_ID__c, Email_ID__c, Remark_ID__c,
                   Address_Lookup_ID__r.Province_Key__c,
                   Address_Lookup_ID__r.District_Key__c,
                   Address_Lookup_ID__r.Subdistrict_Key__c,
                   Address_Lookup_ID__r.Postcode_Key__c,
                   Address_Lookup_ID__r.Village_Key__c, // Add this line
                   
                   // House Registration (HR)
                   Address_HR__c, Room_No_HR__c, Floor_HR__c, Building_HR__c,
                   Moo_HR__c, Soi_HR__c, Village_HR__c, Street_HR__c,
                   Telephone_HR__c, TelephoneExt_HR__c, Mobile_HR__c,
                   Fax_HR__c, FaxExtension_HR__c, Email_HR__c, Remark_HR__c,
                   Address_Lookup_HR__r.Province_Key__c,
                   Address_Lookup_HR__r.District_Key__c,
                   Address_Lookup_HR__r.Subdistrict_Key__c,
                   Address_Lookup_HR__r.Postcode_Key__c,
                   Address_Lookup_HR__r.Village_Key__c, // Add this line
                   
                   // Current Address (CR)
                   Address_CR__c, Room_No_CR__c, Floor_CR__c, Building_CR__c,
                   Moo_CR__c, Soi_CR__c, Village_CR__c, Street_CR__c,
                   Telephone_CR__c, TelephoneExt_CR__c, Mobile_CR__c,
                   Fax_CR__c, FaxExtension_CR__c, Email_CR__c, Remark_CR__c,
                   Address_Lookup_CR__r.Province_Key__c,
                   Address_Lookup_CR__r.District_Key__c,
                   Address_Lookup_CR__r.Subdistrict_Key__c,
                   Address_Lookup_CR__r.Postcode_Key__c,
                   Address_Lookup_CR__r.Village_Key__c // Add this line
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
            // Check if the update came from KADS
            if (acc.Is_KADS_Update__c != true) {
                // Proceed with sending data to KADS if it's not from KADS
                String requestBody = buildRequestBody(acc);
                HTTPResponse updateResponse = performCallout(requestBody);

                // Log after the callout
                createServiceLog(requestBody, updateResponse.getBody(), acc.Id);
            } else {
                // Log that the update was skipped because it is from KADS
                createErrorLog(accountId, 'Update skipped because it is from KADS');
            }

        } catch (Exception e) {
            createErrorLog(accountId, e.getMessage());
        }
    }

    private String buildRequestBody(Account acc) {
        Map<String, Object> fullBody = new Map<String, Object>();
        // Map fields to match the KADS structure exactly:
        fullBody.put('Data_Source__c', 'KADS');
        fullBody.put('Kubota_Id__c', (acc.Kubota_Id__c != null) ? acc.Kubota_Id__c : '');
        fullBody.put('Citizen_Id__c', (acc.Citizen_Id__c != null) ? acc.Citizen_Id__c : '');
        fullBody.put('Mobile_phone_no_1__c', (acc.Mobile_phone_no_1__c != null) ? acc.Mobile_phone_no_1__c : '');
        
        String userLevelCode = '';
        if(acc.User_Level__c != null) {
            switch on acc.User_Level__c.toLowerCase() {
                when 'customer' {
                    userLevelCode = 'Z002';
                }
                when 'dealer' {
                    userLevelCode = 'Z003';
                }
                when else {
                    userLevelCode = acc.User_Level__c;  // Keep original value if not matching
                }  // Added this missing closing brace
            }
        }
        fullBody.put('User_Level_c', userLevelCode);
       
        fullBody.put('Salutation', (acc.Salutation != null) ? acc.Salutation : '');
        fullBody.put('FirstName', (acc.FirstName != null) ? acc.FirstName : '');
        fullBody.put('LastName', (acc.LastName != null) ? acc.LastName : '');
        fullBody.put('BranchCode__c', (acc.BranchCode__c != null) ? acc.BranchCode__c : '');
        fullBody.put('BranchCodeDescription__c', (acc.BranchCodeDescription__c != null) ? acc.BranchCodeDescription__c : '');
        fullBody.put('PassportNo__c', (acc.PassportNo__c != null) ? acc.PassportNo__c : '');
        fullBody.put('PassportIssueCountry__c', (acc.PassportIssueCountry__c != null) ? acc.PassportIssueCountry__c : '');
        fullBody.put('CompanyName1__c', (acc.CompanyName1__c != null) ? acc.CompanyName1__c : '');
        fullBody.put('CompanyName2__c', (acc.CompanyName2__c != null) ? acc.CompanyName2__c : '');
        fullBody.put('CompanyName3__c', (acc.CompanyName3__c != null) ? acc.CompanyName3__c : '');
        fullBody.put('CompanyName4__c', (acc.CompanyName4__c != null) ? acc.CompanyName4__c : '');
        fullBody.put('CustomerConditionGroup__c', (acc.CustomerConditionGroup__c != null) ? acc.CustomerConditionGroup__c : '');
        fullBody.put('Consent1__c', (acc.Consent1__c != null) ? acc.Consent1__c : '');
        fullBody.put('Consent2__c', (acc.Consent2__c != null) ? acc.Consent2__c : '');
        fullBody.put('PDPASignature__c', (acc.PDPASignature__c != null) ? acc.PDPASignature__c : '');
        fullBody.put('LANDTX__c', (acc.LANDTX__c != null) ? acc.LANDTX__c : '');
        fullBody.put('BusinessType__c', (acc.BusinessType__c != null) ? acc.BusinessType__c : '');
        
        // Dates as yyyyMMdd
        fullBody.put('PersonBirthdate', formatDateForSAP(acc.PersonBirthdate));
        fullBody.put('PassportValidFromDate__c', formatDateForSAP(acc.PassportValidFromDate__c));
        fullBody.put('PassportValidToDate__c', formatDateForSAP(acc.PassportValidToDate__c));

        // AddressProp - dynamically add addresses if they exist
        // XXDEFAULT - using 'ID' suffix
        List<Map<String, Object>> addressProp = new List<Map<String, Object>>();
        addAddressIfAvailable(addressProp, 'XXDEFAULT', acc, 'ID');
        // Z4 - House Registration
        addAddressIfAvailable(addressProp, 'Z4', acc, 'HR');
        // Z5 - Current Address
        addAddressIfAvailable(addressProp, 'Z5', acc, 'CR');

        fullBody.put('AddressProp', addressProp);

        // MessageProp empty array with one empty object
        List<Map<String, Object>> messageProp = new List<Map<String, Object>>();
        messageProp.add(new Map<String,Object>());
        fullBody.put('MessageProp', messageProp);

        return JSON.serialize(fullBody);
    }

private void addAddressIfAvailable(List<Map<String,Object>> addresses, String addressType, Account acc, String suffix) {
    // Check if the main address field is not null
    // For example, if suffix = 'ID', we look at acc.Address_ID__c
    String addressField = (String)acc.get('Address_' + suffix + '__c');
    
    // Also confirm if lookup is available to get province/district/etc.
    SObject lookupObj = acc.getSObject('Address_Lookup_' + suffix + '__r');
    
    if (addressField != null && lookupObj != null) {
        Map<String, Object> addr = new Map<String, Object>();
        addr.put('AddressType', addressType);
        addr.put('Address__c', safeStr(acc.get('Address_' + suffix + '__c')));
        addr.put('Room_No__c', safeStr(acc.get('Room_No_' + suffix + '__c')));
        addr.put('Floor__c', safeStr(acc.get('Floor_' + suffix + '__c')));
        addr.put('Building__c', safeStr(acc.get('Building_' + suffix + '__c')));
        addr.put('Moo__c', safeStr(acc.get('Moo_' + suffix + '__c')));
        addr.put('Soi__c', safeStr(acc.get('Soi_' + suffix + '__c')));
        
        // Use Village_Key__c from the lookup instead of Village__c
        addr.put('Village__c', safeStr(lookupObj.get('Village_Key__c')));
        
        addr.put('Street__c', safeStr(acc.get('Street_' + suffix + '__c')));

        // Province, District, Subdistrict, Postcode from lookup
        addr.put('Province__c', safeStr(lookupObj.get('Province_Key__c')));
        addr.put('District__c', safeStr(lookupObj.get('District_Key__c')));
        addr.put('Subdistrict__c', safeStr(lookupObj.get('Subdistrict_Key__c')));
        addr.put('Postcode__c', safeStr(lookupObj.get('Postcode_Key__c')));

        addr.put('Telephone__c', safeStr(acc.get('Telephone_' + suffix + '__c')));
        addr.put('TelephoneExt__c', safeStr(acc.get('TelephoneExt_' + suffix + '__c')));
        addr.put('Mobile__c', safeStr(acc.get('Mobile_' + suffix + '__c')));
        addr.put('Fax__c', safeStr(acc.get('Fax_' + suffix + '__c')));
        addr.put('FaxExtension__c', safeStr(acc.get('FaxExtension_' + suffix + '__c')));
        addr.put('Email__c', safeStr(acc.get('Email_' + suffix + '__c')));
        addr.put('Remark__c', safeStr(acc.get('Remark_' + suffix + '__c')));

        addresses.add(addr);
    }
}

    private String safeStr(Object val) {
        return val == null ? '' : String.valueOf(val);
    }

    private HTTPResponse performCallout(String requestBody) {
        Http http = new Http();

        // Fetch CSRF token and cookies
        HttpRequest tokenRequest = new HttpRequest();
        tokenRequest.setEndpoint('callout:KadsDevCust/sap/opu/odata/SAP/ZDP_GWSRV023_SRV');
        tokenRequest.setMethod('GET');
        tokenRequest.setHeader('X-CSRF-Token', 'Fetch');

        HTTPResponse tokenResponse = http.send(tokenRequest);
        String csrfToken = tokenResponse.getHeader('x-csrf-token');

        List<String> cookies = new List<String>();
        for (String headerName : tokenResponse.getHeaderKeys()) {
            if (headerName != null && headerName.toLowerCase().contains('set-cookie')) {
                String cookieVal = tokenResponse.getHeader(headerName);
                cookies.add(cookieVal.split(';',2)[0]);
            }
        }
        String cookieHeader = String.join(cookies, '; ');

        // POST request with token and cookies
        HttpRequest updateRequest = new HttpRequest();
        updateRequest.setEndpoint('callout:KadsDevCust/sap/opu/odata/SAP/ZDP_GWSRV023_SRV/SFEditKIDSet');
        updateRequest.setMethod('POST');
        updateRequest.setHeader('Content-Type', 'application/json');
        updateRequest.setHeader('X-CSRF-Token', csrfToken);
        updateRequest.setHeader('Cookie', cookieHeader);
        updateRequest.setBody(requestBody);

        return http.send(updateRequest);
    }
/////////////////////////ปรับข้อมูลจับจาก Local Lang
           private String formatDateForSAP(Date d) {
    if (d == null) return '';

    // แปลงปีพุทธศักราชเป็นปีคริสต์ศักราชถ้าจำเป็น
    Integer year = d.year();
    if (UserInfo.getLocale() == 'th_TH') { 
        year -= 543;  // ปรับปีสำหรับผู้ใช้ที่ใช้ภาษาไทย
    }

    // ตรวจสอบให้แน่ใจว่าเดือนและวันเป็นสองหลักเสมอ (เช่น "02" สำหรับเดือนกุมภาพันธ์)
    String month = (d.month() < 10) ? '0' + d.month() : String.valueOf(d.month());
    String day = (d.day() < 10) ? '0' + d.day() : String.valueOf(d.day());

    // ส่งคืนวันที่ในรูปแบบ yyyyMMdd
    return year + month + day;
}
/////////////////////////////////////////////////////////////////////
       
    private void createServiceLog(String request, String response, Id accountId) {
        Service_Log__c log = new Service_Log__c();
        log.Request__c = request;
        log.Response__c = response;
        log.API_Name__c = 'Customer API 4:  KADS Account Update API';
        log.Related_Account__c = accountId;
        insert log;
    }

    private void createErrorLog(Id accountId, String errorMessage) {
        Service_Log__c log = new Service_Log__c();
        log.API_Name__c = 'API 4 KADS Account Update API';
        log.Related_Account__c = accountId;
        log.Response__c = 'Error: ' + errorMessage;
        insert log;
    }
}