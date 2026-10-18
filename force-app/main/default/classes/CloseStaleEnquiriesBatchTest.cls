
@IsTest
private class CloseStaleEnquiriesBatchTest {

    @IsTest
    static void testBatchClosesStaleEnquiries() {

        Enquiry__c staleEnquiry = new Enquiry__c(
            Subject__c = 'Stale Enquiry',
            Customer_Budget__c = 5000,
            Status__c = 'In Progress'
        );

        insert staleEnquiry;

        // The trigger creates a follow-up Task.
        // Remove it so this Enquiry has no recent activity.
        List<Task> generatedTasks = [
            SELECT Id
            FROM Task
            WHERE WhatId = :staleEnquiry.Id
        ];

        if (!generatedTasks.isEmpty()) {
            delete generatedTasks;
        }

        // Create an Enquiry with recent activity.
        Enquiry__c activeEnquiry = new Enquiry__c(
            Subject__c = 'Active Enquiry',
            Customer_Budget__c = 5000,
            Status__c = 'In Progress'
        );

        insert activeEnquiry;

        // Ensure a recent Task exists for this Enquiry.
        insert new Task(
            Subject = 'Recent Follow Up',
            OwnerId = UserInfo.getUserId(),
            WhatId = activeEnquiry.Id,
            ActivityDate = Date.today()
        );

        Test.startTest();

        Database.executeBatch(
            new CloseStaleEnquiriesBatch(
                Datetime.now().addDays(1)
            ),
            200
        );

        Test.stopTest();

        Map<Id, Enquiry__c> results =
            new Map<Id, Enquiry__c>([
                SELECT Id, Status__c, Closed_Date__c
                FROM Enquiry__c
                WHERE Id IN :new Set<Id>{
                    staleEnquiry.Id,
                    activeEnquiry.Id
                }
            ]);

        System.assertEquals(
            'Closed',
            results.get(staleEnquiry.Id).Status__c,
            'An enquiry without recent activity should close.'
        );

        System.assertEquals(
            Date.today(),
            results.get(staleEnquiry.Id).Closed_Date__c,
            'Closing the enquiry should stamp the closed date.'
        );

        System.assertEquals(
            'In Progress',
            results.get(activeEnquiry.Id).Status__c,
            'An enquiry with recent activity should remain open.'
        );
    }

    @IsTest
    static void testScheduler() {
        Test.startTest();
        String cronExp = '0 0 0 * * ?';
        String jobId = System.schedule('Test Close Stale Enquiries', cronExp, new CloseStaleEnquiriesScheduler());
        Test.stopTest();
        System.assertNotEquals(null, jobId, 'Job should be scheduled successfully');
    }
}
