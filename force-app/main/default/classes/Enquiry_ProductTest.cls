@IsTest
private class Enquiry_ProductTest {

    @IsTest
    static void testRecalculateCountLifecycle() {
        Product2 prod1 = new Product2(
            Name = 'Test SparkNest Device',
            IsActive = true
        );
        Product2 prod2 = new Product2(
            Name = 'Test Smart Bulb',
            IsActive = true
        );
        insert new List<Product2>{ prod1, prod2 };

        Enquiry__c enq1 = new Enquiry__c(
            Subject__c = 'Enquiry 1',
            Customer_Budget__c = 5000
        );
        Enquiry__c enq2 = new Enquiry__c(
            Subject__c = 'Enquiry 2',
            Customer_Budget__c = 6000
        );
        insert new List<Enquiry__c>{ enq1, enq2 };

        Enquiry_Product__c ep1 = new Enquiry_Product__c(
            Enquiry__c = enq1.Id,
            Product__c = prod1.Id,
            Quantity_Interested__c = 2
        );
        Enquiry_Product__c ep2 = new Enquiry_Product__c(
            Enquiry__c = enq1.Id,
            Product__c = prod2.Id,
            Quantity_Interested__c = 1
        );
        insert new List<Enquiry_Product__c>{ ep1, ep2 };

        Enquiry__c reloadedEnq1 = [
            SELECT Total_Products_Interested__c
            FROM Enquiry__c
            WHERE Id = :enq1.Id
        ];
        System.assertEquals(
            2,
            reloadedEnq1.Total_Products_Interested__c,
            'Total_Products_Interested__c should be 2 after inserting 2 product interest records'
        );

        ep2.Enquiry__c = enq2.Id;
        update ep2;

        reloadedEnq1 = [
            SELECT Total_Products_Interested__c
            FROM Enquiry__c
            WHERE Id = :enq1.Id
        ];
        Enquiry__c reloadedEnq2 = [
            SELECT Total_Products_Interested__c
            FROM Enquiry__c
            WHERE Id = :enq2.Id
        ];
        System.assertEquals(
            1,
            reloadedEnq1.Total_Products_Interested__c,
            'Total_Products_Interested__c on old Enquiry should decrease to 1 after reparenting'
        );
        System.assertEquals(
            1,
            reloadedEnq2.Total_Products_Interested__c,
            'Total_Products_Interested__c on new Enquiry should increase to 1 after reparenting'
        );

        delete ep1;

        reloadedEnq1 = [
            SELECT Total_Products_Interested__c
            FROM Enquiry__c
            WHERE Id = :enq1.Id
        ];
        System.assertEquals(
            0,
            reloadedEnq1.Total_Products_Interested__c,
            'Total_Products_Interested__c should be 0 after deleting all product interest records'
        );

        undelete ep1;

        reloadedEnq1 = [
            SELECT Total_Products_Interested__c
            FROM Enquiry__c
            WHERE Id = :enq1.Id
        ];
        System.assertEquals(
            1,
            reloadedEnq1.Total_Products_Interested__c,
            'Total_Products_Interested__c should restore to 1 after undeleting'
        );
    }
}
