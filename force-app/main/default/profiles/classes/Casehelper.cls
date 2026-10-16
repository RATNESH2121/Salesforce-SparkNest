public with sharing class Casehelper {
    public static void CaseMilestoneBreach(Map<Id,Case> OldCasemap, Map<Id,Case> Newcasemap){

        List<Case> breachedcase = new List<Case>();
        for(Case Eachcase: Newcasemap.values()){
            Case oldcase = (OldCasemap != null) ? OldCasemap.get(Eachcase.Id) : null;
            if(Eachcase.Milestone_Breached__c == true && oldcase.Milestone_Breached__c == false){
                breachedcase.add(Eachcase);
            }
        }

        
            List<User> users = [SELECT Id FROM User WHERE username = 'ratneshaugustus.a70f1cafd78d@agentforce.com' AND IsActive = true LIMIT 1];
            if(!users.isEmpty()){
                for(Case Eachcase: breachedcase){
                    Eachcase.OwnerId = users[0].Id;
                }
            
        }
    }


    public static void UpdateResolutionTime(Map<Id,Case> Oldcasemap,Map<Id,Case> Newcasemap){
        

        for(Case Eachcase: Newcasemap.values()){
            Case Oldcase = Oldcasemap.get(Eachcase.Id);

            if(Oldcase.Status != 'Closed' && Eachcase.Status =='Closed'){
                Eachcase.Resolution_Time_Hours__c = (System.now().getTime()
                - Eachcase.CreatedDate.getTime()) / 3600000.0;
            }
        }
    }
}