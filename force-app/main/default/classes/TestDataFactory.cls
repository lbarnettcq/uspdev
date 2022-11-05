public with sharing class TestDataFactory {
    public static final String idNotExist = '001D0000NotExist';
    public static final String firstName = 'fName';
    public static final String lastName = 'lName';
    public static final String testEmailAddress = 'domain@domain.com';

    public static final String dateFormat = 'yyyy-MM-dd';

    public static final String startDateWithoutData = String.valueOf(Date.today().addMonths(-2));
    public static final String endDateWithoutData = String.valueOf(Date.today());

    public static final String startDate = String.valueOf(Date.today().addMonths(-4));
    public static final String endDate = String.valueOf(Date.today().addMonths(-1));


    public static final Integer userCount = 1;
    public static final String userNamePattern = 'user%';
    public static final Map<String, Object> userPattern = new Map<String, Object>{
            'alias' => '',
            'email' => '',
            'emailEncodingKey' => 'UTF-8',
            'localSidKey' => 'en_US' ,
            'languageLocaleKey' => 'en_Us' ,
            'name' => 'user' ,
            'lastName' => 'lastName' ,
            'communityNickname' => '' ,
            'profileId' => '00e3h000001HHh1AAG' ,
            'timeZoneSidKey' => 'America/Los_Angeles' ,
            'userName' =>  '' ,
            'domain' => 'domain.com'
    };
    public static List<Map<String,Object>> newUsers = new List<Map<String, Object>>();

    public static final Map<String, Object> newTestAccount = new Map<String, Object>{
            'Name' => 'Test Account '
    };

    public static final String opportunityNamePattern ='opportunity%';
    public static final Integer opportunityCount = 20;
    public static final Decimal opportunityAmount = 50000.00;
    public static final Map<String, Object> opportunityPattern = new Map<String, Object> {
            'accountId' => null ,
            'Name' => 'opportunity ' ,
            'Target' => '0 - Target' ,
            'CurrencyIsoCode' => 'USD' ,
            'Close Date' => endDateWithoutData ,
            'Amount' => opportunityAmount
    };

    private static final Integer gaugeMaxValue = 150;
    private static final Integer orangeUpperLimit = 50;
    private static final Integer yellowUpperLimit = 75;
    private static final Integer redUpperLimit = 25;
    private static final Integer quotaAmount = 1000000;


    //create test data methods
    public static void init(){
        insertAccount();
        insertUsers(false);
        insertOpportunity();
        insertQuotaAmount();
    }

    public static void insertAccount() {
        List<Account> accounts = new List<Account>();

        for (Integer i = 0; i != 10; i++) {
            Account a = new Account ();
            a.Name = (String) newTestAccount.get('Name');

            accounts.add(a);
        }
        insert accounts;
    }

    public static Profile getProfile(String name) {
        return [SELECT Id FROM Profile WHERE Name =:name LIMIT 1];
    }

    public static void insertUsers(Boolean NewFunnelTargetAdminUser) {
        List<User> users = new List<User>();

        Profile p = getProfile('Standard User');

        for (Integer i = 0; i < userCount; i++) {
            String name = String.valueOf((userPattern.get('name') + '-' + i));
            String lastName = String.valueOf(userPattern.get('lastName') + '_' + i);
            String uid = String.valueOf(userPattern.get('name')+'_'+ i );

            User u = new User(
                    Alias = uid ,
                    Email = uid + '@' + String.valueOf(userPattern.get('domain')) ,
                    EmailEncodingKey = String.valueOf(userPattern.get('emailEncodingKey')) ,
                    LastName = lastName ,
                    LanguageLocaleKey = String.valueOf(userPattern.get('languageLocaleKey')) ,
                    LocaleSidKey = String.valueOf(userPattern.get('localSidKey')) ,
                    ProfileId = p.Id ,
                    TimeZoneSidKey = String.valueOf(userPattern.get('timeZoneSidKey')) ,
                    Username = (uid + '@' + String.valueOf(userPattern.get('domain'))) ,
                    ForecastEnabled = true
            );

            users.add(u);
        }

        insert users;
        if(NewFunnelTargetAdminUser) {
            assignNewFATFunctionality(users);
        }
    }


    public static void insertOpportunity() {
        List<Opportunity> opportunities = new List<Opportunity>();

        insertAccount();

        Account account = [SELECT Id FROM Account WHERE Name Like 'Test%' LIMIT 1];

        for (Integer i = 0; i < opportunityCount; i++) {
            String name = String.valueOf(opportunityPattern.get('name') + '_' + i);

            User user = [SELECT Id FROM User WHERE LastName Like 'lastName%' LIMIT 1];

            Opportunity opp = new Opportunity(
                    Name = name ,
                    StageName = String.valueOf(opportunityPattern.get('Target')) ,
                    Amount = Decimal.valueOf((Double) opportunityPattern.get('Amount')) ,
                    CurrencyIsoCode = String.valueOf(opportunityPattern.get('CurrencyIsoCode')) ,
                    CloseDate = Date.today() ,
                    AccountId = account.Id ,
                    OwnerId = UserInfo.getUserId(),
                    Probability = 70 ,
                    Chemical_Global__c = 'Hydrogen Peroxide'

            );

            opportunities.add(opp);
        }

        insert opportunities;
        System.debug('###Opps List =>' + opportunities);
    }


    public static void insertQuotaAmount() {
        ForecastingType type = [SELECT Id FROM ForecastingType WHERE DeveloperName = 'Opportunity_00N3h00000GnTe0_Revenue'];

        User u = [SELECT Id FROM User WHERE LastName Like 'lastName%' LIMIT 1];

        Date d = Date.today();


        ForecastingQuota quota = new ForecastingQuota(
                ForecastingTypeId = type.id ,
                QuotaOwnerId = u.id ,
                QuotaAmount = 250000.00 ,
                StartDate = date.today()
               // PeriodId = period.Id
        );

        insert quota;
    }

    public static void assignNewFATFunctionality(List<User> user) {
        //User u = [SELECT Id FROM User WHERE LastName Like 'lastName%' LIMIT 1];
        List<PermissionSetAssignment> newAssignments = new List<PermissionSetAssignment>();

        for(User u : user) {
            PermissionSetGroup grouping = [SELECT Id, DeveloperName FROM PermissionSetGroup WHERE
                    DeveloperName='Funnel_Config_Admin' LIMIT 1];
            PermissionSetAssignment assignment = new PermissionSetAssignment();
            assignment.PermissionSetGroupId = grouping.Id;
            assignment.AssigneeId = u.Id;
        }

        insert newAssignments;
    }



    public static List<Period> loadPeriods() {
        List<Period> periods = new List<Period>();
        periods.add((Period) InjectFieldValues(new Period(), new Map<String, Object>{
                'Id' => GenerateIdFor(Period.getSObjectType()),
                'Type' => 'Month',
                'StartDate' => Date.today().addMonths(-3).toStartOfMonth(),
                'Number' => Date.today().addMonths(-3).toStartOfMonth().month(),
                'EndDate' => Date.today().addMonths(-2).toStartOfMonth().addDays(-1),
                'FullyQualifiedLabel' => 'Test Period 3 back'
        }));
        periods.add((Period) InjectFieldValues(new Period(), new Map<String, Object>{
                'Id' => GenerateIdFor(Period.getSObjectType()),
                'Type' => 'Month',
                'StartDate' => Date.today().addMonths(-2).toStartOfMonth(),
                'Number' => Date.today().addMonths(-2).toStartOfMonth().month(),
                'EndDate' => Date.today().addMonths(-1).toStartOfMonth().addDays(-1),
                'FullyQualifiedLabel' => 'Test Period 2 back'
        }));
        periods.add((Period) InjectFieldValues(new Period(), new Map<String, Object>{
                'Id' => GenerateIdFor(Period.getSObjectType()),
                'Type' => 'Month',
                'StartDate' => Date.today().addMonths(-1).toStartOfMonth(),
                'Number' => Date.today().addMonths(-1).toStartOfMonth().month(),
                'EndDate' => Date.today().toStartOfMonth().addDays(-1),
                'FullyQualifiedLabel' => 'Test Period 1 back'
        }));
        periods.add((Period) InjectFieldValues(new Period(), new Map<String, Object>{
                'Id' => GenerateIdFor(Period.getSObjectType()),
                'Type' => 'Month',
                'StartDate' => Date.today().toStartOfMonth(),
                'Number' => Date.today().toStartOfMonth().month(),
                'EndDate' => Date.today().addMonths(1).toStartOfMonth().addDays(-1),
                'FullyQualifiedLabel' => 'Test Period Now'
        }));
        periods.add((Period) InjectFieldValues(new Period(), new Map<String, Object>{
                'Id' => GenerateIdFor(Period.getSObjectType()),
                'Type' => 'Month',
                'StartDate' => Date.today().addMonths(1).toStartOfMonth(),
                'Number' => Date.today().addMonths(1).toStartOfMonth().month(),
                'EndDate' => Date.today().addMonths(2).toStartOfMonth().addDays(-1),
                'FullyQualifiedLabel' => 'Test Period 1 ahead'
        }));
        periods.add((Period) InjectFieldValues(new Period(), new Map<String, Object>{
                'Id' => GenerateIdFor(Period.getSObjectType()),
                'Type' => 'Month',
                'StartDate' => Date.today().addMonths(2).toStartOfMonth(),
                'Number' => Date.today().addMonths(2).toStartOfMonth().month(),
                'EndDate' => Date.today().addMonths(3).toStartOfMonth().addDays(-1),
                'FullyQualifiedLabel' => 'Test Period 2 ahead'
        }));
        //insert periods;
        return periods;
    }

    public static Map<Id, ForecastingFact> loadMockForecasts(Id currentUser, Set<Id> periods) {
        Map<Id, ForecastingFact> forecasts = new Map<Id, ForecastingFact>();
        for(Id period : periods) {
            ForecastingFact fact = (ForecastingFact) InjectFieldValues(new ForecastingFact(), new Map<String, Object> {
                    'Id' => GenerateIdFor(ForecastingFact.SObjectType),
                    'OwnerId' => currentUser,
                    'PeriodId' => period,
                    'ForecastCategoryName' => 'Pipeline',
                    'ForecastingItem' => (ForecastingItem) InjectFieldValues(new ForecastingItem(), new Map<String, Object> {
                            'Id' => GenerateIdFor(ForecastingItem.SObjectType),
                            'ForecastAmount' => 6990.03
                    }),
                    'OpportunityId' => GenerateIdFor(Opportunity.SObjectType)
            });
            forecasts.put(fact.Id, fact);
        }
        return forecasts;
    }

    public static Map<Id, Opportunity> loadMockForecastOpportunities(Map<Id, ForecastingFact> forecasts) {
        Map<Id, Opportunity> forecastOpportunities = new Map<Id, Opportunity>();
        for (ForecastingFact fact : forecasts.values()) {
            Opportunity opp = (Opportunity) InjectFieldValues(new Opportunity(), new Map<String, Object>{
                    'Id' => fact.OpportunityId,
                    'StageName' => '4 - Proposal',
                    'Probability' => 70,
                    'IsClosed' => false,
                    'IsWon' => false,
                    'CreatedDate' => DateTime.now().addDays(-35),
                    'CloseDate' => null,
                    'LastModifiedDate' => DateTime.now().addDays(-2),
                    'Amount' => 5000000.00
            });
            forecastOpportunities.put(fact.Id, opp);
        }
        return forecastOpportunities;
    }

    private static Map<Schema.SObjectType, Integer> idsGenerated = new Map<Schema.SObjectType, Integer>();
    private static Id GenerateIdFor(Schema.SObjectType target) {
        Integer sequence = idsGenerated.get(target);
        if (sequence == null) { sequence = 0; }
        sequence++;
        idsGenerated.put(target, sequence);
        String result = String.valueOf(sequence);
        String key = target.getDescribe().getKeyPrefix() + '0'.repeat(12-result.length()) + result;
        return (Id) key;
    }

    private static SObject InjectFieldValues(SObject record, Map<String, Object> values) {
        // deserialize record prop to keep track of type assignment
        Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped( JSON.serialize( record ) );

        // assign values from the suspended record prop/map
        for(String field : values.keySet()) {
            fieldMap.put(field, values.get(field));
        }

        // re-serialize the record prop from the field value map
        return (SObject) JSON.deserialize( JSON.serialize( fieldMap ), SObject.class );
    }

    public static User PrepareUsersAndRoles() {
        User userA = null;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            // insert roles
            UserRole roleA = new UserRole(DeveloperName = 'Role_A_Test_Role', Name = 'Role A', ParentRoleId = null); insert roleA;
            UserRole roleB = new UserRole(DeveloperName = 'Role_B_Test_Role', Name = 'Role B', ParentRoleId = roleA.Id); insert roleB;
            UserRole roleC = new UserRole(DeveloperName = 'Role_C_Test_Role', Name = 'Role C', ParentRoleId = roleB.Id); insert roleC;
            UserRole roleD = new UserRole(DeveloperName = 'Role_D_Test_Role', Name = 'Role D', ParentRoleId = roleB.Id); insert roleD;

            // get profile
            Profile pf = [Select Id from profile WHERE Name = 'System Administrator'];

            // insert users for the roles
            userA = createUser('Tom', 'Cat', roleA, pf); insert userA;
            User userB = createUser('Jerry', 'Mouse', roleB, pf); insert userB;
            User userC = createUser('Spongebob', 'Squarepants', roleC, pf); insert userC;
            User userD = createUser('Squidward', 'Tentacles', roleD, pf); insert userD;
        }
        return userA;
    }

    public void CreateTestAnnualConfigurations() {
        User u = [SELECT Id FROM User WHERE LastName Like 'lastName%' LIMIT 1];

        Annual_Funnel_Addition_Target_Config__c annualConfig = new Annual_Funnel_Addition_Target_Config__c();
        annualConfig.Label__c = 'Test Annual Config';
        annualConfig.Territory__c = 'North East';
        annualConfig.Target__c = 5100000;
        annualConfig.IsActive__c = true;

        insert annualConfig;
        Annual_Quota_Config__c quotaConfig = new Annual_Quota_Config__c();
        quotaConfig.Name__c = 'Test Quota Config';
        quotaConfig.Rep__c = u.id;
        quotaConfig.IsSeller__c = true;
        quotaConfig.Territory__c = annualConfig.Territory__c;

        insert quotaConfig;

        Funnel_Addition_Target__c target = new Funnel_Addition_Target__c();
        target.Territory__c = annualConfig.Territory__c;
        target.Period__c = 'P1';
        target.Fiscal_Year__c = String.valueOf(Date.today().year());
        target.Quote_Config__c = quotaConfig.Id;
         insert target;

    }

    private static User createUser(String firstName, String lastName, UserRole role, Profile pf) {
        String emailAddress = firstName+'.'+lastName+'.'+role.Name.replace(' ', '') + '@usp.com.unittest';
        return new User(
                ProfileId = pf.Id,
                LastName = lastName,
                FirstName = firstName,
                Email = emailAddress,
                Username = emailAddress + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                UserRoleId = role.Id
        );
    }
}