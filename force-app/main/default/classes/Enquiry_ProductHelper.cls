public with sharing class Enquiry_ProductHelper{

    public static void RecalculateCounts(
        List<Enquiry_Product__c> Enquiry_Products) {
        Set<Id> EnquiryIds = new Set<Id>();

        for (Enquiry_Product__c Each_Product : Enquiry_Products) {
            if (Each_Product.Enquiry__c != null) {
                EnquiryIds.add(Each_Product.Enquiry__c);
            }
        }

        RecalculateCount(EnquiryIds);
    }

    public static void RecalculateUpdateCounts(Map<Id, Enquiry_Product__c> OldEnqMap,
        Map<Id, Enquiry_Product__c> NewEnqMap ) {
        Set<Id> EnquiryIds = new Set<Id>();

        for (Enquiry_Product__c Each_Product : NewEnqMap.values()) {
            Enquiry_Product__c Old_Product = OldEnqMap.get(Each_Product.Id);

            if (Old_Product.Enquiry__c != Each_Product.Enquiry__c) {
                if (Old_Product.Enquiry__c != null) {
                    EnquiryIds.add(Old_Product.Enquiry__c);
                }

                if (Each_Product.Enquiry__c != null) {
                    EnquiryIds.add(Each_Product.Enquiry__c);
                }
            }
        }
        RecalculateCount(EnquiryIds);
    }

    public static void RecalculateDeletedCounts(List<Enquiry_Product__c> OldProducts) {
        Set<Id> EnquiryIds = new Set<Id>();

        for (Enquiry_Product__c EachProduct : OldProducts) {
            if (EachProduct.Enquiry__c != null) {
                EnquiryIds.add(EachProduct.Enquiry__c);
            }
        }

        RecalculateCount(EnquiryIds);
    }

    public static void RecalculateUndeletedCounts( List<Enquiry_Product__c> Enquiry_Products) {
        Set<Id> EnquiryIds = new Set<Id>();

        for (Enquiry_Product__c EachProduct : Enquiry_Products) {
            if (EachProduct.Enquiry__c != null) {
                EnquiryIds.add(EachProduct.Enquiry__c);
            }
        }



        RecalculateCount(EnquiryIds);
    }

    public static void RecalculateCount(Set<Id> EnquiryIds) {
        if (EnquiryIds == null || EnquiryIds.isEmpty()) {
            return;
        }


        List<AggregateResult> result = [SELECT Enquiry__c, COUNT(Id) ProductCount
            FROM Enquiry_Product__c
            WHERE Enquiry__c IN :EnquiryIds
            GROUP BY Enquiry__c
        ];
        
        Map<Id,AggregateResult> ar = new Map<Id,AggregateResult>();

        for(AggregateResult Eachresult: result){
            ar.put((Id) Eachresult.get('Enquiry__c'),Eachresult);
            
        }

        List<Enquiry__c> EnquiryUpdate = new List<Enquiry__c>();



        for (Id EachId : EnquiryIds) {
            Enquiry__c newEnq = new Enquiry__c(Id = EachId);

            if (ar.containsKey(EachId)) {
                AggregateResult Eachres = ar.get(EachId);
                newEnq.Total_Products_Interested__c = (Integer) Eachres.get('ProductCount');
            } 
            else {
                newEnq.Total_Products_Interested__c = 0;
            }
            EnquiryUpdate.add(newEnq);
        }

        if(!EnquiryUpdate.isEmpty()){
            update EnquiryUpdate;
        }
        
    }
}