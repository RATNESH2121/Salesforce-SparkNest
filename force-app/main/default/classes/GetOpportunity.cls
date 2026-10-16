public class GetOpportunity {

    public class Request {
        @InvocableVariable(
            required=true
            description='The name of the Opportunity to find'
        )
        public String opportunityName;
    }

    public class Response {
        @InvocableVariable(
            description='Opportunity name'
        )
        public String opportunityName;

        @InvocableVariable(
            description='Opportunity stage'
        )
        public String stage;

        @InvocableVariable(
            description='Opportunity amount'
        )
        public Decimal amount;

        @InvocableVariable(
            description='Opportunity close date'
        )
        public Date closeDate;
    }

    @InvocableMethod(
        label='Get Opportunity Information'
        description='Finds an Opportunity by name and returns its key information'
    )
    public static List<Response> getOpportunity(List<Request> requests) {

        List<Response> results = new List<Response>();

        for (Request request : requests) {

            Response result = new Response();

            List<Opportunity> opportunities = [
                SELECT Id, Name, StageName, Amount, CloseDate
                FROM Opportunity
                WHERE Name = :request.opportunityName
                LIMIT 1
            ];

            if (!opportunities.isEmpty()) {

                Opportunity opp = opportunities[0];

                result.opportunityName = opp.Name;
                result.stage = opp.StageName;
                result.amount = opp.Amount;
                result.closeDate = opp.CloseDate;

            } else {

                result.opportunityName = 'Opportunity not found';

            }

            results.add(result);
        }

        return results;
    }
}