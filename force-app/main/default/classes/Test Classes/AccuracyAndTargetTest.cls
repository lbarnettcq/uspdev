@IsTest
private class AccuracyAndTargetTest {
    @IsTest
    static void regressionCoverage() {
        Test.startTest();
        TestDataFactory.init();
        User u = TestDataFactory.PrepareUsersAndRoles();

        Account a = new Account(Name = 'AnT Test Account'); insert a;

        List<Opportunity> opps = new List<Opportunity>();
        opps.add(new Opportunity(
                Name = 'AnT Test Opp 001', StageName = '4 - Proposal',
                Amount = 123400.00, CurrencyIsoCode = 'USD',
                CloseDate = Date.today(), AccountId = a.Id, OwnerId = u.Id, Probability = 70 , Chemical__c = 'Hydrogen Peroxide', Chemical_Global__c = 'OptiCal'
        ));
        opps.add(new Opportunity(
                Name = 'AnT Test Opp 002', StageName = '4 - Proposal',
                Amount = 123400.00, CurrencyIsoCode = 'USD',
                CloseDate = Date.today(), AccountId = a.Id, OwnerId = u.Id, Probability = 70 , Chemical__c = 'Hydrogen Peroxide', Chemical_Global__c = 'OptiCal'
        ));
        opps.add(new Opportunity(
                Name = 'AnT Test Opp 003', StageName = '4 - Proposal',
                Amount = 123400.00, CurrencyIsoCode = 'USD',
                CloseDate = Date.today(), AccountId = a.Id, OwnerId = u.Id, Probability = 70 , Chemical__c = 'Hydrogen Peroxide', Chemical_Global__c = 'OptiCal'
        ));
        opps.add(new Opportunity(
                Name = 'AnT Test Opp 004', StageName = '4 - Proposal',
                Amount = 2345600.00, CurrencyIsoCode = 'USD' ,
                CloseDate = Date.today(), AccountId = a.Id, OwnerId = u.Id, Probability = 70, Chemical__c = 'Hydrogen Peroxide', Chemical_Global__c = 'OptiCal'
        ));
        insert opps;

        System.runAs(u) {
            AccuracyAndTargetCalculator.Execute(
                    AccuracyAndTargetCalculator.Mode.StartOfPeriod,
                    AccuracyAndTargetCalculator.State.IgnoreCurrentDate
            );
            opps[2].StageName = '5 - Closed/Won';
            opps[2].Contract_PO_Start_Date__c = Date.today().addMonths(2);
            update opps[2];
            // shift to last day of month so that it runs EoM calculations
            AccuracyAndTargetCalculator.M_TODAY = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
            AccuracyAndTargetCalculator.Execute(
                    AccuracyAndTargetCalculator.Mode.EndOfPeriod,
                    AccuracyAndTargetCalculator.State.IgnoreCurrentDate
            );
        }
        Test.stopTest();
    }
}