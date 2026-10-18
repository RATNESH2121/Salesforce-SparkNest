public with sharing class EnquiryService {
    public static void setDefaultStatus(List<Enquiry__c> Enquiries){


        for(Enquiry__c EachEnq: Enquiries){
            if(String.isBlank(eachEnq.Status__c)){
                EachEnq.status__c = 'New';
            }
        }


    }

    public static void validateCustomerBudget(List<Enquiry__c> Enquiries){
        for(Enquiry__c EachEnq: Enquiries){
            if(EachEnq.Customer_Budget__c != null && EachEnq.Customer_Budget__c < 1000){
                EachEnq.Customer_Budget__c.addError('Customer budget must be at least ₹1,000');
            }
        }
    }

    public static void createFollowUpTasks(List<Enquiry__c> Enquiries){
        List<Task> TasksToCreate = new List<Task>();
        for(Enquiry__c EachEnq: Enquiries){

            
            Task NewTask = new Task();
            
            if(Eachenq.Subject__c !=null){
                NewTask.Subject = 'Follow up: ' + Eachenq.Subject__c;
            }
            else{
                newTask.Subject = 'Follow up';
            }
            NewTask.ownerId = EachEnq.Ownerid;
            NewTask.ActivityDate = Date.Today().addDays(3);
            NewTask.whatid=EachEnq.id;

            TasksToCreate.add(NewTask);

        }

        if(!TasksToCreate.isempty()){
            insert TasksToCreate;
        }
    }

    public static void setClosedDate(Map<Id,Enquiry__c> OldEnqMap,Map<Id,Enquiry__c> NewEnqMap){
        for(Enquiry__c EachEnq: NewEnqMap.values()){
            Enquiry__c OldEnq = OldEnqMap.get(EachEnq.id);

            if(EachEnq.status__C == 'Closed' && OldEnq != null && OldEnq.status__c != 'Closed'){
                EachEnq.Closed_Date__c =Date.today();
            }
        }
    }
}
