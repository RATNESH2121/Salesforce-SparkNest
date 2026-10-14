trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            OpportunityHandler.AfterUpdate(Trigger.oldMap,Trigger.newMap);
            
        }

        if(Trigger.isInsert){
            OpportunityHandler.AfterInsert(Trigger.new);
        }

        if(Trigger.isDelete){
            OpportunityHandler.AfterDelete(Trigger.Old);
        }
    }


    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            OpportunityHandler.beforeupdate(Trigger.oldMap,Trigger.newMap);
        }
    }
}