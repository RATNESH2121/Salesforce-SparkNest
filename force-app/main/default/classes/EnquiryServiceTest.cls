
@IsTest
private class EnquiryServiceTest {

    @IsTest
    static void testDefaultStatus() {
        Enquiry__c enq =
            TestDataFactory.createEnquiry(
                'Default Status Test',
                5000,
                null
            );

        insert enq;

        Enquiry__c savedEnq = [
            SELECT Status__c
            FROM Enquiry__c
            WHERE Id = :enq.Id
        ];

        System.assertEquals(
            'New',
            savedEnq.Status__c,
            'Blank status should default to New'
        );
    }

    @IsTest
    static void testInvalidBudget() {
        Enquiry__c enq =
            TestDataFactory.createEnquiry(
                'Invalid Budget Test',
                500,
                null
            );

        Database.SaveResult result =
            Database.insert(enq, false);

        System.assertEquals(
            false,
            result.isSuccess(),
            'Budget below 1000 should fail'
        );

        System.assert(
            result.getErrors()[0].getMessage().contains(
                'Customer budget must be at least'
            ),
            'Expected budget validation error'
        );
    }

    @IsTest
    static void testFollowUpTask() {
        Enquiry__c enq =
            TestDataFactory.createEnquiry(
                'Task Test',
                5000,
                null
            );

        insert enq;

        List<Task> tasks = [
            SELECT Subject, OwnerId, ActivityDate, WhatId
            FROM Task
            WHERE WhatId = :enq.Id
        ];

        System.assertEquals(
            1,
            tasks.size(),
            'One follow-up task should be created'
        );

        System.assertEquals(
            'Follow up: Task Test',
            tasks[0].Subject
        );

        enq = [SELECT OwnerId FROM Enquiry__c WHERE Id = :enq.Id];

        System.assertEquals(
            enq.OwnerId,
            tasks[0].OwnerId
        );

        System.assertEquals(
            Date.today().addDays(3),
            tasks[0].ActivityDate
        );
    }

    @IsTest
    static void testClosedDate() {
        Enquiry__c enq =
            TestDataFactory.createEnquiry(
                'Closed Date Test',
                5000,
                'New'
            );

        insert enq;

        enq.Status__c = 'Closed';
        update enq;

        Enquiry__c savedEnq = [
            SELECT Status__c, Closed_Date__c
            FROM Enquiry__c
            WHERE Id = :enq.Id
        ];

        System.assertEquals(
            'Closed',
            savedEnq.Status__c
        );

        System.assertEquals(
            Date.today(),
            savedEnq.Closed_Date__c,
            'Closing an enquiry should stamp today date'
        );
    }

    @IsTest
    static void testBulkInsert200() {
        List<Enquiry__c> enquiries =
            TestDataFactory.createEnquiries(200);

        Test.startTest();
        insert enquiries;
        Test.stopTest();

        System.assertEquals(
            200,
            [SELECT COUNT() FROM Enquiry__c
             WHERE Subject__c LIKE 'Test Enquiry %'],
            'All 200 enquiries should be inserted'
        );

        Set<Id> enquiryIds = new Map<Id, Enquiry__c>(
            enquiries
        ).keySet();

        List<Task> tasks = [
            SELECT Id, WhatId
            FROM Task
            WHERE WhatId IN :enquiryIds
        ];

        System.assertEquals(
            200,
            tasks.size(),
            'Each enquiry should have one follow-up task'
        );
    }
}
