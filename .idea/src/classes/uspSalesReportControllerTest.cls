@IsTest
private class uspSalesReportControllerTest {
    @IsTest
    static void noSettingsTests() {
        TestDataFactory.insertUsers();
        TestDataFactory.insertQuotaAmount();

        User u = [SELECT  Id, Name, Alias FROM User WHERE LastName LIKE 'lastName%'];

        System.runAs(u) {
            System.assertNotEquals(null, uspSalesReportController.CurrentUser);
            System.debug(uspSalesReportController.CurrentUser);
            System.assertNotEquals(null, uspSalesReportController.CurrentUserName);
            System.debug(uspSalesReportController.CurrentUserName);
            System.assertNotEquals(null, uspSalesReportController.MaxValue);
            System.debug('######### Max Value => ' + uspSalesReportController.MaxValue);
            System.assertNotEquals(null, uspSalesReportController.Quota);
            System.debug('######### Quota => ' + uspSalesReportController.Quota);
            System.assertNotEquals(null, uspSalesReportController.GaugeColors);
            System.debug('######### GaugeColors => ' + uspSalesReportController.GaugeColors);
        }
    }

    @IsTest
    static void settingsTests() {
        TestDataFactory.init();

        User u = TestDataFactory.PrepareUsersAndRoles();

        System.debug(u.Name);
        System.runAs(u) {
            insert (SObject) new quotaGageSettings__c(
                    Quota_Amount__c = 143000
                    , Gauge_Max_Value__c = 125
                    , Red_Upper_Limit__c = 80
                    , Orange_Upper_Limit__c = 60
                    , Yellow_Upper_Limit__c = 30
            );
            System.assertEquals(125, uspSalesReportController.MaxValue);
            System.assertEquals(143000, uspSalesReportController.Quota);

            List<SelectOption> ViewablePeople = uspSalesReportController.ViewablePeople;
            List<forecastItemDTO> ForecastItems = uspSalesReportController.ForecastItems;
            String GaugeColors = uspSalesReportController.GaugeColors;
            String CurrentMTDBookings = uspSalesReportController.CurrentMTDBookings;
            String PercentTowardPlan = uspSalesReportController.PercentTowardPlan;
            System.debug('PercentTowardPLan =  ' + PercentTowardPlan);
            String PlanCurrentPeriod = uspSalesReportController.PlanCurrentPeriod;
            String PlanVsBookingPlusThree = uspSalesReportController.PlanVsBookingPlusThree;
            String ProjectedBookings = uspSalesReportController.ProjectedBookings;
            System.debug('Projected Bookings = ' + ProjectedBookings);
            String ProjectedBookingsPlusStageThree = uspSalesReportController.ProjectedBookingsPlusStageThree;
            String RangeStart = uspSalesReportController.RangeStart;
            String RangeEnd = uspSalesReportController.RangeEnd;
            String RangeRemaining = uspSalesReportController.RangeRemaining;
            String StageThreeOpps = uspSalesReportController.StageThreeOpps;
            String StageFourOpps = uspSalesReportController.StageFourOpps;
            String PlanVsBooking = uspSalesReportController.PlanVsBooking;
            uspSalesReportController.Period = '30';
            List<Date> periodDates1 = uspSalesReportController.PeriodDates;
            uspSalesReportController.Period = '60';
            List<Date> periodDates2 = uspSalesReportController.PeriodDates;
            uspSalesReportController.Period = '90';
            List<Date> periodDates3 = uspSalesReportController.PeriodDates;
            uspSalesReportController.Period = '90 - 450';
            List<Date> periodDates4 = uspSalesReportController.PeriodDates;
        }
    }
}