
@IsTest
public class TestDataFactory {

    public static Enquiry__c createEnquiry( String subject,
        Decimal budget,
        String status
    ) {
        Enquiry__c enq = new Enquiry__c();

        enq.Subject__c = subject;
        enq.Customer_Budget__c = budget;

        if (status != null) {
            enq.Status__c = status;
        }

        return enq;
    }

    public static List<Enquiry__c> createEnquiries(
        Integer recordCount
    ) {
        List<Enquiry__c> enquiries =
            new List<Enquiry__c>();

        for (Integer i = 0; i < recordCount; i++) {
            enquiries.add(
                createEnquiry(
                    'Test Enquiry ' + i,
                    5000,
                    null
                )
            );
        }

        return enquiries;
    }
}
