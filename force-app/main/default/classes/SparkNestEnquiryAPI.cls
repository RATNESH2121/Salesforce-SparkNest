@RestResource(urlMapping='/sparknest/enquiry/*')
global with sharing class SparkNestEnquiryAPI {

    // Data received from Postman
    global class EnquiryRequest {
        public String customerName;
        public String customerEmail;
        public String customerPhone;
        public String productName;
        public String enquiryType;
    }

    // Helper method to send a JSON response
    private static void sendResponse(
        Integer statusCode,
        Map<String, Object> data
    ) {
        RestContext.response.statusCode = statusCode;
        RestContext.response.addHeader(
            'Content-Type',
            'application/json'
        );
        RestContext.response.responseBody =
            Blob.valueOf(JSON.serialize(data));
    }

    // POST: Create a customer enquiry
    @HttpPost
    global static void createEnquiry() {

        try {
            // Read JSON sent by Postman
            String body = RestContext.request.requestBody.toString();

            EnquiryRequest input =
                (EnquiryRequest) JSON.deserialize(
                    body,
                    EnquiryRequest.class
                );

            // Validate required fields
            if (input == null ||
                String.isBlank(input.customerName) ||
                String.isBlank(input.customerEmail) ||
                String.isBlank(input.productName) ||
                String.isBlank(input.enquiryType)) {

                sendResponse(400, new Map<String, Object>{
                    'success' => false,
                    'message' =>
                        'Name, email, product name and enquiry type are required.'
                });
                return;
            }

            if (!input.customerEmail.contains('@')) {
                sendResponse(400, new Map<String, Object>{
                    'success' => false,
                    'message' => 'Please provide a valid email.'
                });
                return;
            }

            // Find Contact using email
            List<Contact> contacts = [
                SELECT Id, FirstName, LastName, Email, Phone
                FROM Contact
                WHERE Email = :input.customerEmail
                LIMIT 1
            ];

            Contact customer;
            Boolean isNewCustomer = false;

            if (!contacts.isEmpty()) {

                // Reuse existing Contact
                customer = contacts[0];

            } else {

                // Split full name into first and last name
                String[] nameParts =
                    input.customerName.trim().split('\\s+');

                String firstName = '';
                String lastName =
                    nameParts[nameParts.size() - 1];

                for (Integer i = 0;
                     i < nameParts.size() - 1;
                     i++) {

                    if (i > 0) {
                        firstName += ' ';
                    }

                    firstName += nameParts[i];
                }

                customer = new Contact(
                    FirstName = firstName,
                    LastName = lastName,
                    Email = input.customerEmail,
                    Phone = input.customerPhone
                );

                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true;
                Database.insert(customer, dml);
                isNewCustomer = true;
            }

            // Create the Enquiry linked to Contact
            Enquiry__c enquiry = new Enquiry__c(
                Subject__c = input.productName,
                Contact__c = customer.Id,
                Enquiry_Type__c = input.enquiryType,
                Source__c = 'Web'
            );

            insert enquiry;

            // Return success response
            sendResponse(201, new Map<String, Object>{
                'success' => true,
                'message' => 'Enquiry created successfully.',
                'contactId' => customer.Id,
                'enquiryId' => enquiry.Id,
                'isNewCustomer' => isNewCustomer
            });

        } catch (System.JSONException e) {

            sendResponse(400, new Map<String, Object>{
                'success' => false,
                'message' => 'Invalid JSON request.'
            });

        } catch (DmlException e) {

            sendResponse(400, new Map<String, Object>{
                'success' => false,
                'message' =>
                    'Could not save records. Check required fields and picklist values.'
            });

        } catch (Exception e) {

            sendResponse(500, new Map<String, Object>{
                'success' => false,
                'message' => 'An unexpected error occurred.'
            });
        }
    }

    // GET: Retrieve an enquiry using its ID
    @HttpGet
    global static void getEnquiry() {

        String enquiryId =
            RestContext.request.params.get('enquiryId');

        if (String.isBlank(enquiryId)) {
            sendResponse(400, new Map<String, Object>{
                'success' => false,
                'message' => 'Please provide enquiryId.'
            });
            return;
        }

        try {
            Id recordId = (Id) enquiryId;

            List<Enquiry__c> enquiries = [
                SELECT Id, Subject__c, Contact__c,
                       Enquiry_Type__c, Source__c,
                       Contact__r.Name,
                       Contact__r.Email,
                       Contact__r.Phone
                FROM Enquiry__c
                WHERE Id = :recordId
                LIMIT 1
            ];

            if (enquiries.isEmpty()) {
                sendResponse(404, new Map<String, Object>{
                    'success' => false,
                    'message' => 'Enquiry not found.'
                });
                return;
            }

            Enquiry__c enquiry = enquiries[0];

            sendResponse(200, new Map<String, Object>{
                'success' => true,
                'enquiryId' => enquiry.Id,
                'subject' => enquiry.Subject__c,
                'enquiryType' => enquiry.Enquiry_Type__c,
                'source' => enquiry.Source__c,
                'contactId' => enquiry.Contact__c,
                'customerName' => enquiry.Contact__r.Name,
                'customerEmail' => enquiry.Contact__r.Email,
                'customerPhone' => enquiry.Contact__r.Phone
            });

        } catch (Exception e) {

            sendResponse(400, new Map<String, Object>{
                'success' => false,
                'message' => 'Invalid enquiry ID.'
            });
        }
    }
}