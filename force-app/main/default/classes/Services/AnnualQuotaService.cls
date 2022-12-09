/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class AnnualQuotaService {
    private static AnnualQuotaService m_actions;
    public static AnnualQuotaService Action {
        get {
            if(m_actions != null) { return m_actions;}
            m_actions = new AnnualQuotaService();
            return m_actions;
        }
    }


    public void afterInsertHandler(Map<Id, Annual_Quota_Config__c> records) {
        Map<Id, Funnel_Addition_Target__c> targetList = new Map<Id, Funnel_Addition_Target__c>([SELECT Id, Quote_Config__c FROM Funnel_Addition_Target__c WHERE
                Quote_Config__c =: records.keySet()]);

        if(targetList.isEmpty()) {
            List<Funnel_Addition_Target__c> targetsToInsert = new List<Funnel_Addition_Target__c>();
            for(Id key : records.keySet()) {
                Annual_Quota_Config__c c = records.get(key);
                if(c.IsSeller__c) {
                    if(AnnualTargetUtils.Utils.HasAccessToNewFeature(UserInfo.getUserId())) {
                        targetsToInsert.addAll(FunnelAdditionTargetService.Action.GenerateNewTargetForQuotaConfiguration(c));
                    }
                }
            }
            insert targetsToInsert;
        }else if(targetList.size() > 1) {

        }else {
            System.debug('Doing Nothing');
        }
    }

}