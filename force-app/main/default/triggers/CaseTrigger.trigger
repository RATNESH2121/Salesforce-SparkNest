trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            CaseHandler.beforeupdate(Trigger.oldMap,Trigger.newMap);
        }
    }
}