/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class FunnelAdditionService {

    private static FunnelAdditionService m_actions;
    public static FunnelAdditionService Action {
        get {
            if(m_actions != null) { return m_actions;}
            m_actions = new FunnelAdditionService();
            return m_actions;
        }
    }

    public Map<String, Object> FunnelAdditionByOpportunity(List<Opportunity> opps) {
        Map<String, Object> data = new Map<String, Object>();
        //Map<Id, Opportunity> oMap = new Map<Id, Opportunity>(opps);
        Set<Id> keyset = new Set<Id>();
        for(Opportunity op : opps) {
            keyset.add(op.Id);
        }

        List<Funnel_Addition__c> additions = [SELECT Id, Opportunity__c, Amount_at_Start__c, Current_Amount__c,
                Current_Period__c, Close_Date_at_Start__c, Close_Date_at_End__c, Period__c, Funnel_Addition_Target__c
        FROM Funnel_Addition__c
        WHERE Opportunity__c IN: keyset];
        data.put('current', additions);

        return data;
    }

    public List<Funnel_Addition__c> CreateNewAdditionsForNewOpps(List<Opportunity> opportunities) {
        List<Funnel_Addition__c> newAddition = new List<Funnel_Addition__c>();
        Set<Id> repId = new Set<Id>();
        for(Opportunity op : opportunities) { repId.add(op.OwnerId);}
        Map<Id, Funnel_Addition_Target__c> targetMap = new Map<Id, Funnel_Addition_Target__c>();
        targetMap.putAll( (List<Funnel_Addition_Target__c>) FunnelAdditionTargetSelector.Instance.GetQueryFactory().WithCriteria(Criteria.ValueIn(Funnel_Addition_Target__c.Rep__c, repId)).Execute());

        Map<Id, Period> periodMap = new Map<Id, Period>(DefaultPeriodSelector.Instance.GetByFiscalYear(String.valueOf(Date.today().year())));
        for(Opportunity o : opportunities) {
            for(Id key : targetMap.keySet()) {
                Funnel_Addition_Target__c trgt = targetMap.get(key);
                if(trgt.Rep__c == o.OwnerId) {
                    String prd = '';
                    for(Id k : periodMap.keySet()) {
                        Period p = periodMap.get(k);
                        if(p.StartDate <= o.CloseDate && p.EndDate >= o.CloseDate) {
                            prd = 'P' + p.Number;
                        }
                    }
                    newAddition.add(new Funnel_Addition__c(
                            Amount_at_Start__c  = o.Amount,
                            Close_Date_at_Start__c = o.CloseDate,
                            Probability_At_Start__c = o.Probability,
                            Opportunity__c = o.Id,
                            Funnel_Addition_Target__c =trgt.Id,
                            Period__c = prd
                    ));
                }
            }
        }

        return newAddition;
    }

}