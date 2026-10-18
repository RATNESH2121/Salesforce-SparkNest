@IsTest
private class SparkNestSecurityTest {

    @IsTest
    static void testArjunSalesSecurity() {
        User arjun = [
            SELECT Id, Username 
            FROM User 
            WHERE Username = 'arjun123@myridius.com' 
            LIMIT 1
        ];

        System.runAs(arjun) {
            Enquiry__c enq = new Enquiry__c(
                Subject__c = 'Arjun Laptop Enquiry',
                Customer_Budget__c = 50000,
                Enquiry_Type__c = 'Product Enquiry'
            );
            insert enq;

            System.assertNotEquals(null, enq.Id, 'Arjun should be able to create an Enquiry');

            delete enq;

            List<Enquiry__c> deletedList = [SELECT Id FROM Enquiry__c WHERE Id = :enq.Id];
            System.assertEquals(0, deletedList.size(), 'Arjun should be able to delete an Enquiry');
        }
    }

    @IsTest(SeeAllData=true)
    static void testSnehaSupportSecurityAndSharing() {
        User sneha = [
            SELECT Id 
            FROM User 
            WHERE Username = 'sneha1234@myridius.com' 
            LIMIT 1
        ];

        System.runAs(sneha) {
            List<Enquiry__c> carePlanEnqs = [
                SELECT Id, Subject__c, Enquiry_Type__c 
                FROM Enquiry__c 
                WHERE Enquiry_Type__c = 'Care Plan Enquiry'
            ];
            System.assert(
                !carePlanEnqs.isEmpty(), 
                'Sneha should see Care Plan Enquiries shared via criteria sharing rule'
            );

            List<Enquiry__c> productEnqs = [
                SELECT Id 
                FROM Enquiry__c 
                WHERE Enquiry_Type__c = 'Product Enquiry'
            ];
            System.assertEquals(
                0, 
                productEnqs.size(), 
                'Sneha should NOT see Product Enquiries owned by other users'
            );

            Boolean deleteFailed = false;
            try {
                delete carePlanEnqs;
            } catch (Exception e) {
                deleteFailed = true;
            }
            System.assert(
                deleteFailed, 
                'Sneha should not have Delete permissions on Enquiry__c'
            );
        }
    }
}
