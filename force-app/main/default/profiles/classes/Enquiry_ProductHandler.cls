public with sharing class Enquiry_ProductHandler {
    public static void afterinsert(List<Enquiry_Product__c> Enquiry_Products){
        Enquiry_ProductHelper.RecalculateCounts(Enquiry_Products);
    }

    public static void Afterupdate(Map<Id,Enquiry_Product__c> OldEnqMap,Map<Id,Enquiry_Product__c> NewEnqMap){
        Enquiry_ProductHelper.RecalculateUpdateCounts(OldEnqMap,NewEnqMap);
    }

    public static void AfterDelete(List<Enquiry_Product__c> OldProducts){
        Enquiry_ProductHelper.RecalculateDeletedCounts(OldProducts);
    }

    public static void AfterUndelete(List<Enquiry_Product__c> Enquiry_Products){
        Enquiry_ProductHelper.RecalculateUndeletedCounts(Enquiry_Products);
    }
}