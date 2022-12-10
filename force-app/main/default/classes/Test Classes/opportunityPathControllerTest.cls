@IsTest
private class opportunityPathControllerTest {

    @IsTest
    public static void stage0Test() {
        Opportunity a = new Opportunity();
        a.Name = 'Test Opp ';
        a.StageName = '0 - Target';
        a.Amount = 20000;
        a.CloseDate = Date.today().addDays(10);
        a.Chemical__c = 'Hydrogen Peroxide';

        insert a;

        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(a);
            opportunityPathController pathController = new opportunityPathController(sc);

            PageReference pageRef = Page.opportunityPath;
            pageRef.getParameters().put('id', String.valueOf(a.Id));
            Test.setCurrentPage(pageRef);
        Test.stopTest();
    }

    @IsTest
    public static void stage1est() {
        Opportunity a = new Opportunity();
        a.Name = 'Test Opp ';
        a.StageName = '1- Prospect';
        a.Amount = 20000;
        a.CloseDate = Date.today().addDays(10);
        a.Chemical__c = 'Hydrogen Peroxide';


        insert a;

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        opportunityPathController pathController = new opportunityPathController(sc);

        PageReference pageRef = Page.opportunityPath;
        pageRef.getParameters().put('id', String.valueOf(a.Id));
        Test.setCurrentPage(pageRef);
        Test.stopTest();
    }

    @IsTest
    public static void stage2Test() {
        Opportunity a = new Opportunity();
        a.Name = 'Test Opp ';
        a.StageName = '2- Qualified';
        a.Amount = 20000;
        a.CloseDate = Date.today().addDays(10);
        a.Chemical__c = 'Hydrogen Peroxide';


        insert a;

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        opportunityPathController pathController = new opportunityPathController(sc);

        PageReference pageRef = Page.opportunityPath;
        pageRef.getParameters().put('id', String.valueOf(a.Id));
        Test.setCurrentPage(pageRef);
        Test.stopTest();
    }

    @IsTest
    public static void stage3Test() {
        Opportunity a = new Opportunity();
        a.Name = 'Test Opp ';
        a.StageName = '3- Validated';
        a.Amount = 20000;
        a.CloseDate = Date.today().addDays(10);
        a.Chemical__c = 'Hydrogen Peroxide';


        insert a;

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        opportunityPathController pathController = new opportunityPathController(sc);

        PageReference pageRef = Page.opportunityPath;
        pageRef.getParameters().put('id', String.valueOf(a.Id));
        Test.setCurrentPage(pageRef);
        Test.stopTest();
    }

    @IsTest
    public static void stage4Test() {
        Opportunity a = new Opportunity();
        a.Name = 'Test Opp ';
        a.StageName = '4- Proposal';
        a.Amount = 20000;
        a.CloseDate = Date.today().addDays(10);
        a.Chemical__c = 'Hydrogen Peroxide';


        insert a;

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        opportunityPathController pathController = new opportunityPathController(sc);

        PageReference pageRef = Page.opportunityPath;
        pageRef.getParameters().put('id', String.valueOf(a.Id));
        Test.setCurrentPage(pageRef);
        Test.stopTest();
    }

    @IsTest
    public static void stage5Test() {
        Opportunity a = new Opportunity();
        a.Name = 'Test Opp ';
        a.StageName = '5 - Closed/Won ';
        a.Amount = 20000;
        a.CloseDate = Date.today().addDays(10);
        a.Contract_PO_Start_Date__c = Date.valueOf(TestDataFactory.endDateWithoutData);
        a.Chemical__c = 'Hydrogen Peroxide';


        insert a;

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        opportunityPathController pathController = new opportunityPathController(sc);

        PageReference pageRef = Page.opportunityPath;
        pageRef.getParameters().put('id', String.valueOf(a.Id));
        Test.setCurrentPage(pageRef);
        Test.stopTest();
    }
}