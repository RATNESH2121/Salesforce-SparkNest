trigger Enquiry_Product on Enquiry_Product__c (after insert,after update,after delete,after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Enquiry_ProductHandler.AfterInsert(Trigger.new);
        }

        if (Trigger.isUpdate) {
            Enquiry_ProductHandler.AfterUpdate(Trigger.oldMap, Trigger.newMap);
        }

        if (Trigger.isDelete) {
            Enquiry_ProductHandler.AfterDelete(Trigger.old);
        }

        if (Trigger.isUndelete) {
            Enquiry_ProductHandler.AfterUndelete(Trigger.new);
        }
    }
}