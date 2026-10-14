trigger EmailMessageTrigger on EmailMessage (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            EmailMessageHandler.afterinsert(Trigger.new);
        }
    }
}