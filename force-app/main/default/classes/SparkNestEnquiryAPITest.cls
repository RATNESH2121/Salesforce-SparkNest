@IsTest
private class SparkNestEnquiryAPITest {

    @IsTest
    static void testCreateEnquiry_NewCustomer() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sparknest/enquiry/';
        req.httpMethod = 'POST';

        Map<String, Object> bodyMap = new Map<String, Object>{
            'customerName' => 'Neha Gupta',
            'customerEmail' => 'neha.gupta@example.test',
            'customerPhone' => '9876543210',
            'productName' => 'Spark Personal Alarm',
            'enquiryType' => 'Product Enquiry'
        };
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        System.assertEquals(201, res.statusCode, 'Expected HTTP 201 for new customer');
        Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(true, respMap.get('success'), 'Expected success true');
        System.assertEquals(true, respMap.get('isNewCustomer'), 'Expected isNewCustomer true');
        System.assertNotEquals(null, respMap.get('contactId'), 'Expected contactId');
        System.assertNotEquals(null, respMap.get('enquiryId'), 'Expected enquiryId');

        Contact con = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email = 'neha.gupta@example.test'];
        System.assertEquals('Neha', con.FirstName);
        System.assertEquals('Gupta', con.LastName);

        Enquiry__c enq = [SELECT Id, Subject__c, Contact__c, Source__c FROM Enquiry__c WHERE Id = :(Id) respMap.get('enquiryId')];
        System.assertEquals('Spark Personal Alarm', enq.Subject__c);
        System.assertEquals(con.Id, enq.Contact__c);
        System.assertEquals('Web', enq.Source__c);
    }

    @IsTest
    static void testCreateEnquiry_ExistingCustomer() {
        Contact existingCon = new Contact(
            FirstName = 'Aarav',
            LastName = 'Sharma',
            Email = 'aarav.sharma@example.test',
            Phone = '9876543211'
        );
        insert existingCon;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sparknest/enquiry/';
        req.httpMethod = 'POST';

        Map<String, Object> bodyMap = new Map<String, Object>{
            'customerName' => 'Aarav Sharma',
            'customerEmail' => 'aarav.sharma@example.test',
            'customerPhone' => '9876543211',
            'productName' => 'Home Gateway Hub',
            'enquiryType' => 'Product Enquiry'
        };
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        System.assertEquals(201, res.statusCode, 'Expected HTTP 201 for existing customer');
        Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(true, respMap.get('success'));
        System.assertEquals(false, respMap.get('isNewCustomer'), 'Expected isNewCustomer false');
        System.assertEquals(existingCon.Id, (Id) respMap.get('contactId'), 'Expected existing Contact Id');
    }

    @IsTest
    static void testCreateEnquiry_MissingEmail() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sparknest/enquiry/';
        req.httpMethod = 'POST';

        Map<String, Object> bodyMap = new Map<String, Object>{
            'customerName' => 'Pooja Patel',
            'customerEmail' => '',
            'customerPhone' => '9876543212',
            'productName' => 'Smoke & Heat Sensor',
            'enquiryType' => 'Product Enquiry'
        };
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        System.assertEquals(400, res.statusCode, 'Expected HTTP 400 for missing email');
        Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(false, respMap.get('success'));
    }

    @IsTest
    static void testCreateEnquiry_InvalidEmail() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sparknest/enquiry/';
        req.httpMethod = 'POST';

        Map<String, Object> bodyMap = new Map<String, Object>{
            'customerName' => 'Pooja Patel',
            'customerEmail' => 'notanemail',
            'customerPhone' => '9876543212',
            'productName' => 'Smoke & Heat Sensor',
            'enquiryType' => 'Product Enquiry'
        };
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        System.assertEquals(400, res.statusCode, 'Expected HTTP 400 for invalid email');
        Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(false, respMap.get('success'));
    }

    @IsTest
    static void testCreateEnquiry_InvalidJson() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sparknest/enquiry/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{bad_json: true');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        System.assertEquals(400, res.statusCode, 'Expected HTTP 400 for bad JSON');
    }

    @IsTest
    static void testGetEnquiry_Success() {
        Contact con = new Contact(FirstName = 'Ravi', LastName = 'Kumar', Email = 'ravi.kumar@example.test');
        insert con;

        Enquiry__c enq = new Enquiry__c(
            Subject__c = 'Smart Thermostat',
            Contact__c = con.Id,
            Enquiry_Type__c = 'Product Enquiry',
            Source__c = 'Web',
            Customer_Budget__c = 3000
        );
        insert enq;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sparknest/enquiry/';
        req.httpMethod = 'GET';
        req.params.put('enquiryId', enq.Id);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SparkNestEnquiryAPI.getEnquiry();
        Test.stopTest();

        System.assertEquals(200, res.statusCode, 'Expected HTTP 200');
        Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(true, respMap.get('success'));
        System.assertEquals(enq.Id, (Id) respMap.get('enquiryId'));
        System.assertEquals('Smart Thermostat', respMap.get('subject'));
    }

    @IsTest
    static void testGetEnquiry_NotFound() {
        Enquiry__c dummy = new Enquiry__c(Subject__c = 'Temp', Customer_Budget__c = 2000);
        insert dummy;
        Id nonExistentId = dummy.Id;
        delete dummy;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sparknest/enquiry/';
        req.httpMethod = 'GET';
        req.params.put('enquiryId', nonExistentId);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SparkNestEnquiryAPI.getEnquiry();
        Test.stopTest();

        System.assertEquals(404, res.statusCode, 'Expected HTTP 404');
    }

    @IsTest
    static void testGetEnquiry_MissingParam() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sparknest/enquiry/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SparkNestEnquiryAPI.getEnquiry();
        Test.stopTest();

        System.assertEquals(400, res.statusCode, 'Expected HTTP 400 for missing param');
    }
}
