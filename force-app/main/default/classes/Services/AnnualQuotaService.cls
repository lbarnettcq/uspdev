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
                Quote_Config__c IN: records.keySet()]);

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

    public List<Annual_Quota_Config__c> CreateNewAnnualQuotaConfiguraitionForNewOpps(List<Opportunity> opps, UnitOfWork uow) {
        Map<Id, Annual_Funnel_Addition_Target_Config__c> annualConfigsMapping = new Map<Id, Annual_Funnel_Addition_Target_Config__c>(AnnualTargetSelector.Instance.GetAll());
        Map<Id, Annual_Funnel_Addition_Target_Config__c> m_mappings = new Map<Id, Annual_Funnel_Addition_Target_Config__c>();
        Map<Id, List<OpportunityTeamMember>> oppTeamMembersMap = new Map<Id, List<OpportunityTeamMember>>();
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opportunity : opps) { oppIds.add(opportunity.Id); }
        for(OpportunityTeamMember member : [SELECT Id, OpportunityId, UserId FROM OpportunityTeamMember WHERE
                OpportunityId IN: oppIds]) {
            if(oppTeamMembersMap.containsKey(member.OpportunityId)) {
                oppTeamMembersMap.get(member.OpportunityId).add(member);
            }

            if(!oppTeamMembersMap.containsKey(member.OpportunityId)) {
                oppTeamMembersMap.put(member.OpportunityId, new List<OpportunityTeamMember>{member});
            }
        }

        List<Annual_Quota_Config__c> iConfigs = new List<Annual_Quota_Config__c>();

        for(Id key : annualConfigsMapping.keySet()) {
            Annual_Funnel_Addition_Target_Config__c config = annualConfigsMapping.get(key);
            for(Opportunity opportunity : opps) {
                if(config.Territory_Manager__c == opportunity.OwnerId) {
                    iConfigs.add(new Annual_Quota_Config__c(
                            Territory__c = config.Territory__c,
                            Rep__c = config.Territory_Manager__c,
                            IsSeller__c = true,
                            AnnualTarget__c = config.Target__c,
                            Fiscal_Year__c = config.Fiscal_Year__c,
                            Name__c = 'FY ' + config.Fiscal_Year__c + ' Configuration'
                    ));
                }else if(oppTeamMembersMap.containsKey(opportunity.Id)) {
                    List<OpportunityTeamMember> teamMembers = oppTeamMembersMap.get(opportunity.Id);
                    for(OpportunityTeamMember member : teamMembers) {
                        if(config.Territory_Manager__c == member.UserId) {
                            iConfigs.add(new Annual_Quota_Config__c(
                                    Territory__c = config.Territory__c,
                                    Rep__c = config.Territory_Manager__c,
                                    IsSeller__c = true,
                                    AnnualTarget__c = config.Target__c,
                                    Fiscal_Year__c = config.Fiscal_Year__c,
                                    Name__c = 'FY ' + config.Fiscal_Year__c + ' Configuration'
                            ));
                        }

                        if(config.Territory_Manager__c != member.UserId) {
                            iConfigs.add(new Annual_Quota_Config__c(
                                    Territory__c = config.Territory__c,
                                    Rep__c = member.UserId,
                                    IsSeller__c = false,
                                    AnnualTarget__c = config.Target__c,
                                    Fiscal_Year__c = config.Fiscal_Year__c,
                                    Name__c = 'FY ' + config.Fiscal_Year__c + ' Configuration for' +
                                            ' ' + member.UserId
                            ));
                        }
                    }
                }
            }
        }

        if(iConfigs.size() > 0) {
            for(Annual_Quota_Config__c config : iConfigs) {
                uow.RegisterNew(iConfigs);
            }
        }
        return iConfigs;

    }

}