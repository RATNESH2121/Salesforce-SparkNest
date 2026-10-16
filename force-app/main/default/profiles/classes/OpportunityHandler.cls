public with sharing class OpportunityHandler {
    
    public static void AfterUpdate(Map<Id,Opportunity> OldOppmap,Map<Id,Opportunity> NewOppmap){
        OpportunityHelper.OpportunityPostSaleTrigger(OldOppmap,NewOppmap);
        OpportunityHelper.OpportunityOpenCountUpdate(OldOppmap,NewOppmap);
    }

    public static  void AfterInsert(List<Opportunity> NewOpp){
        OpportunityHelper.OpportunityOpenCount(NewOpp);
    }
    public static void AfterDelete(List<Opportunity> OldOpp){
        OpportunityHelper.OpportunityOpenCountDelete(OldOpp);
    }

    public static void beforeupdate(Map<Id,Opportunity> oldOppmap,Map<Id,Opportunity> NewOppmap){
        OpportunityHelper.TrackNegotiation(oldOppmap,NewOppmap);
    }
}