@IsTest
private class StringUtilTest {
    @IsTest
    static void callMethods() {
        Test.startTest();
        String resultA = StringUtil.FormatDateForUI(Date.today());
        String resultB = StringUtil.FormatDollarAmount(43234.00);
        String resultC = StringUtil.FormatDollarAmount(0.00);

        System.assertNotEquals(null, resultA);
        System.assertNotEquals(null, resultB);
        System.assertNotEquals(null, resultC);
        Test.stopTest();
    }
}