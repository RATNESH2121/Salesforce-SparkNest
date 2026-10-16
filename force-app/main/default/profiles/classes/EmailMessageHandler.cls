public with sharing class EmailMessageHandler {
    public static void afterinsert(List<EmailMessage> emails){
           EmailMessageshelper.completefirstresponse(emails);
    }
}