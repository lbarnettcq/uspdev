/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

@IsTest
private class OpportunityServiceTest {

    //private static User testUser;

    @TestSetup
    static void Setup() {
        TestDataFactory.insertUsers(true);
        TestDataFactory.loadFATConfiguration();
        TestDataFactory.loadTestQuotaConfig();
        TestDataFactory.loadTestFunnelAdditionTarget();
        //TestDataFactory.insertOpportunity();
    }

    @IsTest
    static void RegressionTest() {


        //OpportunitySelector oppSelector = new OpportunitySelector();
        //FunnelAdditionSelector funnelAdditionSelector = new FunnelAdditionSelector();
        TestDataFactory.insertOpportunity();
        Opportunity opp = OpportunitySelector.Instance.GetOne()[0];
        opp.CloseDate = opp.CloseDate.addDays(35);
        update opp;
        List<Funnel_Addition__c> additions = FunnelAdditionSelector.Instance.GetAll();
        System.assertNotEquals(additions, null);
        //System.debug('### Created Funnel Additions ===> ' + additions.size());
        for(Funnel_Addition__c addition : additions) {
            System.debug(String.valueOf('Created Index ' + additions.indexOf(addition)) + ' ==> ' +  addition);
        }

        //Test.startTest();

    }

    @IsTest
    static void MultipleOpportunityUpdateTest() {
        TestDataFactory.insertOpportunity();
        List<Opportunity> opportunities = OpportunitySelector.Instance.GetAll();
        for(Opportunity opportunity : opportunities) {
            if(opportunities.indexOf(opportunity) < 5) {
                opportunity.CloseDate = opportunity.CloseDate.addDays(30);
            }else if (opportunities.indexOf(opportunity) >= 5 && opportunities.indexOf(opportunity) < 10) {
                opportunity.CloseDate = opportunity.CloseDate.addDays(60);
            }else {
                opportunity.CloseDate = opportunity.CloseDate.addDays(180);
            }
        }
        update opportunities;
    }
}