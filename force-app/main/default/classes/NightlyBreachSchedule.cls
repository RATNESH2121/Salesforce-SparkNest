public with sharing class NightlyBreachSchedule implements Schedulable{
    public void execute(SchedulableContext sc){
        List<CaseMilestone> milestones = [
            SELECT TargetDate, Case.CaseNumber,
                   Case.Account.Name
            FROM CaseMilestone
            WHERE MilestoneType.Name = 'Resolution'
            AND IsViolated = true
            AND CompletionDate = null
            AND Case.IsClosed = false
        ];

        String emailBody = 'Open Cases with Breached Resolution SLA:\n\n';

        for (CaseMilestone cm : milestones) {
            Decimal overdueHours =
                (System.now().getTime()
                - cm.TargetDate.getTime()) / 3600000.0;

            emailBody +=
                'Case Number: ' + cm.Case.CaseNumber + '\n' +
                'Customer: ' + cm.Case.Account.Name + '\n' +
                'Hours Overdue: ' +
                overdueHours.setScale(2) + '\n\n';
        }

        Messaging.SingleEmailMessage mail =
            new Messaging.SingleEmailMessage();

        mail.setToAddresses(
            new String[]{'ratnk27@gmail.com'}
        );

        mail.setSubject('Nightly Resolution SLA Breach Summary');
        mail.setPlainTextBody(emailBody);

        Messaging.sendEmail(
            new Messaging.SingleEmailMessage[]{mail}
        );
    }
}