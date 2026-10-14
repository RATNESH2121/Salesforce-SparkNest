public with sharing class EmailMessageshelper {
    public static void completefirstresponse(List<EmailMessage> emails){

        Set<Id> caseIds = new Set<Id>();

         for (EmailMessage email : emails) {
        if (email.Incoming == false && email.ParentId != null &&
            email.ParentId.getSObjectType() == Case.SObjectType) {

            caseIds.add(email.ParentId);
        }
    }
     List<CaseMilestone> milestones = [SELECT Id, CompletionDate FROM CaseMilestone WHERE CaseId IN :caseIds
                                        AND MilestoneType.Name = 'First Response' AND CompletionDate = null];

    for (CaseMilestone milestone : milestones) {
        milestone.CompletionDate = System.now();
    }

    if (!milestones.isEmpty()) {
        update milestones;
    }
    }
}