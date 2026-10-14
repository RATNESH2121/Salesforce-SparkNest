trigger LeadTrigger on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            LeadHandler.beforeinsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            LeadHandler.beforeupdate(Trigger.oldmap,Trigger.newMap);
        }
    }
}