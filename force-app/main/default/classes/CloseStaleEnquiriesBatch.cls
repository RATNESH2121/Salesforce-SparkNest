public with sharing class CloseStaleEnquiriesBatch
    implements Database.Batchable<sObject> {

    private Datetime thirtyDaysAgo;

    public CloseStaleEnquiriesBatch() {
        this.thirtyDaysAgo = Datetime.now().addDays(-30);
    }

    public CloseStaleEnquiriesBatch(Datetime cutoffDate) {
        this.thirtyDaysAgo = cutoffDate;
    }

    public Database.QueryLocator start(
        Database.BatchableContext bc
    ) {
        // Local declaration removed; uses the class-level thirtyDaysAgo variable
        return Database.getQueryLocator([
            SELECT Id, Status__c
            FROM Enquiry__c
            WHERE Status__c = 'In Progress'
            AND LastModifiedDate < :thirtyDaysAgo
        ]);
    }

    public void execute(
        Database.BatchableContext bc,
        List<sObject> scope
    ) {
        List<Enquiry__c> enquiries = (List<Enquiry__c>) scope;
        // Local declaration removed; uses the class-level thirtyDaysAgo variable
        Set<Id> enquiryIds = new Set<Id>();

        for (Enquiry__c EachEnq : enquiries) {
            enquiryIds.add(EachEnq.Id);
        }

        Set<Id> enquiriesWithRecentActivity = new Set<Id>();

        List<Task> Tasks = [
            SELECT WhatId
            FROM Task
            WHERE WhatId IN :enquiryIds
            AND ActivityDate >= :Date.today().addDays(-30)
        ];

        for (Task EachTask : Tasks) {
            enquiriesWithRecentActivity.add(EachTask.WhatId);
        }

        List<Event> Events = [
            SELECT WhatId
            FROM Event
            WHERE WhatId IN :enquiryIds
            AND StartDateTime >= :thirtyDaysAgo
        ];

        for (Event EachEvent : Events) {
            enquiriesWithRecentActivity.add(EachEvent.WhatId);
        }

        for (Enquiry__c EachEnq : enquiries) {
            if (!enquiriesWithRecentActivity.contains(EachEnq.Id)) {
                EachEnq.Status__c = 'Closed';
            }
        }

        update enquiries;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Stale Enquiry batch completed.');
    }
}
