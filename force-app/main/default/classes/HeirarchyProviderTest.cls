@IsTest
private class HeirarchyProviderTest {
    @IsTest
    static void testHeirarchyLoads() {
        Test.startTest();

        User firstUser = TestDataFactory.PrepareUsersAndRoles();

        // runas top user
        List<SelectOption> heirarchy = new List<SelectOption>();
        System.runAs(firstUser) {
             heirarchy = HeirarchyProvider.PopulateSelectOptionsFromCurrentUser();
        }
        System.assert(heirarchy.size() > 0);
        Test.stopTest();
    }
}