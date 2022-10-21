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
        TestDataFactory.insertOpportunity();
    }

    @IsTest
    static void testBehavior() {



        OpportunitySelector oppSelector = new OpportunitySelector();
        FunnelAdditionSelector funnelAdditionSelector = new FunnelAdditionSelector();
        User u = [SELECT Id FROM User WHERE LastName Like 'lastName%' LIMIT 1];
        Test.startTest();
        System.runAs(u) {
            Opportunity opp = oppSelector.GetOne()[0];
            List<Funnel_Addition__c> additions = funnelAdditionSelector.GetAll();
            System.assertNotEquals(additions, null);
            System.debug(additions);
        }

    }
}