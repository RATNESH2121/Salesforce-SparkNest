public with sharing class LeadHandler {
    public static void beforeinsert(List<Lead> newlead){
        LeadHelper.LeadDuplicatePrevent(newlead);
    }   


    public static void beforeupdate(Map<Id,Lead> oldleadmap,Map<Id,Lead> newleadmap){
       
       List<Lead> ll = new List<Lead>();
        for(Lead eachlead : newleadmap.values()){
            Lead oldlead = oldleadmap.get(eachlead.id);

            if(!oldlead.IsConverted && eachlead.IsConverted){
                if(String.isBlank(eachlead.Phone)){
                    eachlead.addError('Lead cannot be converted. Phone is empty'); 
                }
            }
        }
    }
}