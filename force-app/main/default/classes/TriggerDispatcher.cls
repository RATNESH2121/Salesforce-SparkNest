public with sharing class TriggerDispatcher {
    public static void dispatch(String HandlerName){
        if(HandlerName == 'EnquiryTriggerHandler'){
            EnquiryTriggerHandler.run();
        }
    }
}