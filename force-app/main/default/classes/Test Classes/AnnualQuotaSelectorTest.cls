/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

@IsTest
private class AnnualQuotaSelectorTest {

    @TestSetup
    static void Setup() {
        TestDataFactory.insertUsers(true);
        TestDataFactory.loadFATConfiguration();
        TestDataFactory.loadTestQuotaConfig();
        TestDataFactory.loadTestFunnelAdditionTarget();

    }
    @IsTest
    static void testBehavior() {
        String id = SchemaHelper.GenerateIdFor(Annual_Quota_Config__c.SObjectType);
        List<Annual_Quota_Config__c> all = AnnualQuotaSelector.Instance.GetAll();

        List<Annual_Quota_Config__c> data = new List<Annual_Quota_Config__c>();
        User u = UserSelector.Instance.GetOneByUsername(UserInfo.getUserName())[0];
        Date iDate = Date.today().addYears(1);
        Annual_Quota_Config__c config1 = new Annual_Quota_Config__c(
                Name__c = 'Test Config 1',
                IsSeller__c = true,
                Rep__c = u.Id,
                Territory__c = 'North East',
                UseCustomPeriod__c = false,
                Fiscal_Year__c = String.valueOf(iDate.year()),
                AnnualTarget__c = 3500000,
                Period_Target__c = 291666.67,
                Annual_Funnel_Addition_Target_Config__c = AnnualTargetSelector.Instance.GetByLabel('Test Config')[0].Id
        );
        Date mDate = iDate.addYears(1);
        Annual_Quota_Config__c config2 = new Annual_Quota_Config__c(
                Name__c = 'Test Config 2',
                IsSeller__c = true,
                Rep__c = u.Id,
                Territory__c = 'North East',
                UseCustomPeriod__c = false,
                Fiscal_Year__c = String.valueOf(mDate.year()),
                AnnualTarget__c = 3500000,
                Period_Target__c = 291666.67,
                Annual_Funnel_Addition_Target_Config__c = AnnualTargetSelector.Instance.GetByLabel('Test Config')[0].Id
        );

        Date vDate =mDate.addYears(1);
        Annual_Quota_Config__c config3 = new Annual_Quota_Config__c(
                Name__c = 'Test Config 3',
                IsSeller__c = true,
                Rep__c = u.Id,
                Territory__c = 'North East',
                UseCustomPeriod__c = false,
                Fiscal_Year__c = String.valueOf(vDate.year()),
                AnnualTarget__c = 3500000,
                Period_Target__c = 291666.67,
                Annual_Funnel_Addition_Target_Config__c = AnnualTargetSelector.Instance.GetByLabel('Test Config')[0].Id
        );

        data.add(config1);
        data.add(config2);
        data.add(config3);
        insert data;

        List<Annual_Quota_Config__c>ConfigForCurrentFY = AnnualQuotaSelector.Instance.GetByFiscalYear(String.valueOf(Date.today().year()));

        List<Annual_Quota_Config__c> ConfigQuery1 = AnnualQuotaSelector.Instance.GetById(new Set<ID> {config1.Id});
        List<Annual_Quota_Config__c> ConfigQueryTest2 = AnnualQuotaSelector.Instance.GetOneBySeller(u.Id);
        List<Annual_Quota_Config__c> ConfigQueryTest3 = AnnualQuotaSelector.Instance.GetByLabel(config2.Name__c);
        List<Annual_Quota_Config__c> ConfigQueryTest4 = AnnualQuotaSelector.Instance.GetAll();
        List<Annual_Quota_Config__c> ConfigQueryTest5 = AnnualQuotaSelector.Instance.GetByName(config3.Name);
        List<Annual_Quota_Config__c> ConfigQueryTest6 = AnnualQuotaSelector.Instance.GetBySeller(new Set<Id> {u.Id});
        List<Annual_Quota_Config__c> ConfigQueryTest7 = AnnualQuotaSelector.Instance.GetSellerConfig();


    }
}