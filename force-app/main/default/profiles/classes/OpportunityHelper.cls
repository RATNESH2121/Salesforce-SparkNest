public with sharing class OpportunityHelper {
    public static void OpportunityPostSaleTrigger(Map<Id,Opportunity> OldOppmap,Map<Id,Opportunity> NewOppmap){

        List<Task> Tasks = new List<Task>();
        for(Opportunity EachOpp: NewOppmap.values()){
            Opportunity OldOpp = OldOppmap.get(EachOpp.id);

            if(OldOpp.StageName != 'Closed Won' && EachOpp.StageName =='Closed Won'){
                Task newtask = new Task();
                newtask.Subject='Post-Sale Check-In';
                newtask.ActivityDate = Date.today().addDays(7);
                newtask.OwnerId = EachOpp.OwnerId;
                newtask.WhatId = EachOpp.Id;

                Tasks.add(newtask);
            }
        }

        if(!Tasks.isEmpty()){
            insert Tasks;
        }
    }

    public static void OpportunityOpenCount(List<Opportunity> NewOpp){
        Set<Id> AccId = new Set<Id>();
        for(Opportunity EachOpp: NewOpp){
            if(EachOpp.AccountId != null){
            AccId.add(EachOpp.AccountId);
            }
        }

        OpportunityOpenCount(AccId);


    }

    public static void OpportunityOpenCountUpdate(Map<Id,Opportunity> OldOppmap,Map<Id,Opportunity> Newoppmap){

        Set<Id> AccId = new Set<Id>();
        for(Opportunity EachOpp: Newoppmap.values()){
            Opportunity OldOpp = OldOppmap.get(EachOpp.id);
            if(EachOpp.AccountId != null){
                AccId.add(EachOpp.AccountId);
            }
            if(OldOpp.AccountId != null){
                AccId.add(OldOpp.AccountId);
            }
        }

        OpportunityOpenCount(AccId);

    }

    public static void OpportunityOpenCountDelete(List<Opportunity> oldOpp){
        Set<Id> AccId = new Set<Id>();

        for(Opportunity EachOpp: oldOpp){
            if(EachOpp.AccountId != null){
                AccId.add(EachOpp.AccountId);
            }
        }
        OpportunityOpenCount(AccId);    
       


    }


    public static void OpportunityOpenCount(Set<Id> AccId) {

    List<AggregateResult> result = [
        SELECT AccountId, COUNT(Id) counts
        FROM Opportunity
        WHERE AccountId IN :AccId
        AND IsClosed = false
        GROUP BY AccountId
    ];

    Map<Id, Integer> ar = new Map<Id, Integer>();

    for (AggregateResult res : result) {
        ar.put(
            (Id) res.get('AccountId'),
            (Integer) res.get('counts')
        );
    }

    List<Account> Accountupdate = new List<Account>();

    for (Id AccIds : AccId) {

        Integer count = 0;

        if (ar.containsKey(AccIds)) {
            count = ar.get(AccIds);
        }

        Account acc = new Account(Id = AccIds);
        acc.Total_Open_Opportunities__c = count;

        Accountupdate.add(acc);
    }

    if (!Accountupdate.isEmpty()) {
        update Accountupdate;
    }
}

    public static void TrackNegotiation(Map<Id,Opportunity> OldOppmap,Map<Id,Opportunity> NewOppmap){
       
        for(Opportunity EachOpp: NewOppmap.values()){

            Opportunity oldOpp = OldOppmap.get(EachOpp.id);
            if(oldOpp.StageName !='Negotiation/Review' && EachOpp.StageName=='Negotiation/Review'){
                EachOpp.Negotiation_Start_Date__c= Date.today();
            }

            if(OldOpp.StageName =='Negotiation/Review' && EachOpp.StageName!='Negotiation/Review' && EachOpp.Negotiation_Start_Date__c != null){
                EachOpp.Negotiation_Days__c = EachOpp.Negotiation_Start_Date__c.daysBetween(Date.today());
            }
        }

    }
}