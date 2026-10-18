public with sharing class EnquiryTriggerHandler {
    public static void run(){

        if(Trigger.isBefore){
            if(Trigger.isInsert){
                EnquiryService.setDefaultStatus((List<Enquiry__c>) Trigger.new);
                EnquiryService.validateCustomerBudget((List<Enquiry__c>) Trigger.new);
            }
            if(Trigger.isUpdate){
                EnquiryService.setClosedDate((Map<Id, Enquiry__c>) Trigger.oldMap, (Map<Id, Enquiry__c>) Trigger.newMap);
            }
        }

        if(Trigger.isAfter){
            if(Trigger.isInsert){
                EnquiryService.createFollowUpTasks((List<Enquiry__c>) Trigger.new);
            }
        }


    }
}