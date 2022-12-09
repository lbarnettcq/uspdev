/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class AnnualTargetUtils {

    //private static String m_Period;
    public static String Period;
    public static Boolean OverridePeriod = false;

    private static AnnualTargetUtils m_instance;
    public static AnnualTargetUtils Utils {
        get {
            if(m_instance != null) {return m_instance; }
            //System.debug('[][] New Instance of UTILS created');
            m_instance = new AnnualTargetUtils();
            return m_instance;
        }
    }
    private static LogHandling Logger = LogHandling.Instance;
    //private static List<Opportunity> RunningOpps = new List<Opportunity>();
    public static Map<Id, Boolean> RunningOppOwnerAccessMapping = new Map<Id, Boolean>();
    private static Map<Id, Funnel_Addition_Target__c> AllTargets = new Map<Id, Funnel_Addition_Target__c>(FunnelAdditionTargetSelector.Instance.GetAll());

    public class OppPeriod{
        public String CurrentPeriod;
        public String StartPeriod;
        public Date CloseDate;
        public Opportunity Opp;
        public Funnel_Addition__c Addition;
        public Integer indexVar;

        public OppPeriod(Opportunity o, String currentPeriod, String startPeriod, Date clDate) {
            this.Opp = o;
            this.CurrentPeriod = currentPeriod;
            this.StartPeriod = startPeriod;
            this.CloseDate = clDate;
            this.Addition = new Funnel_Addition__c();
            //this.indexVar = new Integer();
        }

        public OppPeriod(Opportunity o, Date clDate) {
            this.Opp = o;
            this.CloseDate = clDate;
            this.CurrentPeriod = '';
            this.StartPeriod = '';
            this.Addition = new Funnel_Addition__c();
            //this.indexVar = new Integer();
        }

        public OppPeriod() { }

        public void CreateIndex(Integer val) {
            this.indexVar = val;
        }

    }

    private interface i_TargetUtil {
        void Init(List<Opportunity> opps, Boolean customPeriodOverride);
    }



    private class TargetUtil implements i_TargetUtil {
        private List<OppPeriod> m_ops = new List<OppPeriod>();
        private Boolean ovrride = false;


        public List<OppPeriod> OppPeriodData;
        public void Init(List<Opportunity> opps, Boolean customPeriodOverride) {
            this.ovrride = customPeriodOverride;
            Initialize(opps);
            DoInit();
        }

        private List<Period> m_period;
        public List<Period> c_Period {
            get {
                if(ovrride){
                    System.debug('USING CUSTOM PERIOD');
                    return null;
                }else if(m_period != null) {
                    return m_period;
                }else {
                    m_period = DefaultPeriodSelector.Instance.GetByFiscalYear(String.valueOf(Date.today().year()));
                    return m_period;
                }

            }
        }

        private List<OppPeriod> Initialize(List<Opportunity> opps) {
            Integer i = 0;
            for(Opportunity o : opps) {
                OppPeriod op = new OppPeriod();
                op.Opp = o;
                op.CloseDate = o.CloseDate;
                m_ops.add(op);
                Map<Id, Period> pMap = new Map<Id,Period>(c_Period);
                for(Id key : pMap.keySet()){
                    Period p = pMap.get(key);
                    if(p.StartDate <= o.CloseDate && p.EndDate >= o.CloseDate) {
                        op.CurrentPeriod = 'P' + p.Number;
                    }
                }
                op.CreateIndex(i);
                i++;

            }
            return m_ops;
        }

        private void DoInit(){
            OppPeriodData = m_ops;
        }

        public void SetStartOfPeriodValue(Funnel_Addition__c addition) {
            for(OppPeriod op : OppPeriodData) {
                if(op.Opp.id == addition.Opportunity__c) {
                    Map<Id, Period> pMap = new Map<Id,Period>(c_Period);
                    for(Id key : pMap.keySet()){
                        Period p = pMap.get(key);
                        if(p.StartDate <= addition.Close_Date_at_Start__c && p.EndDate >= addition.Close_Date_at_Start__c) {
                            System.debug(p);
                            op.StartPeriod = 'P' + p.Number;
                        }
                    }
                }
            }
        }

    }

    public static TargetUtil DataUtil = new TargetUtil();

    public static Map<Period, List<Period>> PeriodMapByFY = new Map<Period, List<Period>>();

    public static void UseCustomPeriod(){
        OverridePeriod = true;
    }

    public static void InitForOpps(List<Opportunity> opps) {
        //RunningOpps = opps;
        CheckForExistingAdditions(opps);
        ParseAccessForCurrentOppOwners(opps);
        DataUtil.Init(opps, false);
        ConfigPeriodMapping();
    }

    public static void CommitUtilLogs(){
        Logger.CommitLogs();
    }

    private static List<Funnel_Addition__c> ExistingAdditions = new List<Funnel_Addition__c>();

    /**
    private static Annual_Quota_Config__c m_quotaConfig;
    public static Annual_Quota_Config__c QuotaConfig {
        get {
            if(m_quotaConfig != null) { return m_quotaConfig; }
            m_quotaConfig = new Annual_Quota_Config__c();
            return m_quotaConfig;
        }
    }
    */
    public static Annual_Quota_Config__c QuotaConfig = new Annual_Quota_Config__c();

    public Funnel_Addition__c CreateNewFunnelAddition(Opportunity opportunity, Boolean createNewOppData) {
        List<Period> periodData = new List<Period>();
        for(Period p : PeriodMapByFY.keySet()) {
            if(opportunity.CloseDate.year() == p.StartDate.year()) {
                periodData = PeriodMapByFY.get(p);
            }
        }
        Integer var = DataUtil.OppPeriodData.size() - 1;
        //FunnelAdditionTargetSelector sFunneladditiontargetselector = new FunnelAdditionTargetSelector();
        Funnel_Addition__c iAddition = new Funnel_Addition__c();
        iAddition.Amount_at_Start__c = opportunity.Amount;
        iAddition.Close_Date_at_Start__c = opportunity.CloseDate;
        iAddition.Probability_At_Start__c = opportunity.Probability;
        iAddition.Opportunity__c = opportunity.Id;

        //iAddition.Funnel_Addition_Target__c = QuotaConfig != null ? sFunneladditiontargetselector.GetByQuotaConfig
        //(QuotaConfig.Id)[0].Id : null;

        for(Id key : AllTargets.keySet()) {
            Funnel_Addition_Target__c trg = AllTargets.get(key);
            if(QuotaConfig != null) {
                if(trg.Quote_Config__c == QuotaConfig.Id) {
                    iAddition.Funnel_Addition_Target__c = trg.Id;
                }
            }
        }

        if(iAddition.Funnel_Addition_Target__c == null) {
            Logger.Error('No Quota Configuration Found. Please Create Annual Quota Configuration for this Fiscal Year' +
                    ' and associate it with ' + UserInfo.getUserName());
        }

        if(!createNewOppData) {
            Map<Id, Period> pMap = new Map<Id,Period>(periodData);
            for(Id key : pMap.keySet()){
                Period p = pMap.get(key);
                if(p.StartDate <= iAddition.Close_Date_at_Start__c && p.EndDate >= iAddition.Close_Date_at_Start__c) {
                    System.debug(p);
                    iAddition.Period__c = 'P' + p.Number;
                }
            }
        }else {
            OppPeriod op = new OppPeriod();
            op.Opp = opportunity;
            op.Addition = iAddition;
            op.CreateIndex(var);
            DataUtil.OppPeriodData.add(op);
            SetStartOfPeriodForAddition(iAddition);
            Map<Id, Period> pMap = new Map<Id,Period>(periodData);
            for(Id key : pMap.keySet()){
                Period p = pMap.get(key);
                if(p.StartDate <= iAddition.Close_Date_at_Start__c && p.EndDate >= iAddition.Close_Date_at_Start__c) {
                    System.debug(p);
                    iAddition.Period__c = 'P' + p.Number;
                }
            }

        }

        System.debug('[][]Creating new Funnel Addition [][][]');
        System.debug(iAddition);

        return iAddition;
    }

    public Funnel_Addition__c GetFunnelAddition(Opportunity opportunity) {
        //FunnelAdditionSelector selector = new FunnelAdditionSelector();
        return FunnelAdditionSelector.Instance.GetByOpportunity(opportunity.Id)[0];
    }

    public void SetStartOfPeriodForAddition(Funnel_Addition__c adt) {
        DataUtil.SetStartOfPeriodValue(adt);
    }

    public List<Funnel_Addition__c> GetAllAdditionsForOpps(List<Opportunity> opportunities) {
        Set<Id> keyset = new Set<Id>();
        for(Opportunity o : opportunities){
            keyset.add(o.Id);
        }
        return FunnelAdditionSelector.Instance.GetById(keyset);
    }

    public Boolean IsThereExistingFunnelAddition(Opportunity opportunity) {
        //FunnelAdditionSelector selector = new FunnelAdditionSelector()
        Boolean val = false;
        Integer i = 0;
        while (val = false && i <= ExistingAdditions.size()) {
            Funnel_Addition__c a = ExistingAdditions.get(i);
            if(a != null) {
                if(a.Opportunity__c == opportunity.Id) {
                    val = true ;
                }
            }

            i++;
        }


        return val;
    }

    public Boolean HasAccessToNewFeature(Id key){
        Boolean val = false;
        if(!RunningOppOwnerAccessMapping.isEmpty()) {
            if(RunningOppOwnerAccessMapping.containsKey(key)) {
                val = RunningOppOwnerAccessMapping.get(key);
            }
        }
        return val;
    }


    private static void CheckForExistingAdditions(List<Opportunity> opps) {
        Map<String, Object> result = FunnelAdditionService.Action.FunnelAdditionByOpportunity(opps);
        ExistingAdditions = (List<Funnel_Addition__c>) result.get('current');
    }


    public Boolean IsMovedOutOfCurrentPeriod(Funnel_Addition__c addition, Opportunity opportunity, Boolean
            CustomPeriodOverride) {
        Boolean value = false;
        if(CustomPeriodOverride == false) {
            DataUtil.SetStartOfPeriodValue(addition);
            for(OppPeriod op : DataUtil.OppPeriodData) {
                if(op.Opp.Id == opportunity.Id) {
                    if(op.StartPeriod != op.CurrentPeriod){ value = true; }
                }
            }
        }
        return value;
    }
    private static void ParseAccessForCurrentOppOwners(List<Opportunity> opps) {
        Map<Id, Boolean> data = new Map<Id, Boolean>();

        Set<Id> keyset = new Set<Id>();
        for(Opportunity o : opps) {
            keyset.add(o.OwnerId);
        }

        Map<Id, User> uList = new Map<Id, User>([SELECT Id, Username FROM User WHERE Id =: keyset ]);
        Set <Id> permissionSetIds = new Set <Id>();
        List<SetupEntityAccess> entityAccesses = [ SELECT ParentId
        FROM SetupEntityAccess
        WHERE SetupEntityId IN
            (SELECT Id
            FROM CustomPermission
            WHERE DeveloperName = 'Use_New_FAT_Functionality')
        ];
        Logger.Log(LoggingLevel.DEBUG,'[]Entity Access ===> ' + entityAccesses );
        for(SetupEntityAccess a : entityAccesses) {
            permissionSetIds.add(a.ParentId);
        }
        Map<Id, User> userMap = new Map<Id, User>([ SELECT Username FROM User WHERE Id IN (
                SELECT AssigneeId FROM PermissionSetAssignment
                WHERE PermissionSetId IN :permissionSetIds AND AssigneeId =: uList.keySet() ) ]);
        for(Id key : uList.keySet()) {
            User u = uList.get(key);
            if(userMap.containsKey(u.Id)) {
                data.put(u.Id, true);
            }else {
                data.put(u.Id, false);
            }
        }


        RunningOppOwnerAccessMapping =  data;
        Logger.Log(LoggingLevel.DEBUG, '[]Running Own Owner Mapping[] ' + RunningOppOwnerAccessMapping);
    }

    public void UpdateAmountForCurrentFunnelAddition(Funnel_Addition__c addition, Opportunity opportunity) {
        addition.Current_Amount__c = opportunity.Amount;
    }

    private void CreateNewFunnelAdditionTarget(Funnel_Addition__c addition) {
        Funnel_Addition_Target__c newTarget = new Funnel_Addition_Target__c();

    }

    private Boolean IsThereExistingFAT(Funnel_Addition__c addition) {
        Boolean val = false;

        return val;
    }

    public String GetPeriodForOpp(Opportunity opportunity, Boolean CustomPeriodOverride) {
        String value = '';
        if(!CustomPeriodOverride) {
            DefaultPeriodSelector selector = new DefaultPeriodSelector();
            Period p = selector.GetWhereDateIn(opportunity.CloseDate)[0];
            value = 'P' + p.Number;
        }
        return value;
    }

    private static void ConfigPeriodMapping() {
        Map<Period, List<Period>> i_MappingPeriods = new Map<Period, List<Period>>();
        List<Period> allPeriods = DefaultPeriodSelector.Instance.queryAll();
        Map<String, Period> fyPeriods = new Map<String, Period>();
        for(Period p : allPeriods) {
            if(p.Type == 'Year') {
                fyPeriods.put(String.valueOf(p.StartDate.year()), p);
            }
        }

        for(String fiscalyear : fyPeriods.keySet()) {
            List<Period> values = new List<Period>();
            for(Period p : allPeriods) {
                Period keyval = fyPeriods.get(fiscalyear);
                if(p.StartDate.year() == keyval.StartDate.year()){
                    if(p.Type == 'Month') { values.add(p); }
                }
            }
            i_MappingPeriods.put(fyPeriods.get(fiscalyear), values);
        }
        PeriodMapByFY = i_MappingPeriods;


    }






}