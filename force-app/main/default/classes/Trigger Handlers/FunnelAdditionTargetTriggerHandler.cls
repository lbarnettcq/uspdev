/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class FunnelAdditionTargetTriggerHandler {
    public static void Execute() {
        if(Trigger.isExecuting) {
            if (Trigger.isBefore) {
                if (Trigger.isInsert) {
                    beforeInsertActions();
                }

            }
        }
    }

    public static void beforeInsertActions(){
        List<Funnel_Addition_Target__c> targets = FunnelAdditionTargetSelector.Instance.GetAll();
        for(Funnel_Addition_Target__c target : (List<Funnel_Addition_Target__c>) Trigger.new) {
            DuplicateHandler(target, targets);
        }
    }

    private static void DuplicateHandler(Funnel_Addition_Target__c mTarget,
            List<Funnel_Addition_Target__c> targets) {
        Boolean value = false;
        //AnnualTargetSelector selector = new AnnualTargetSelector();

        for(Funnel_Addition_Target__c trg : targets) {
            if(trg.Fiscal_Year__c == mTarget.Fiscal_Year__c) {
                if(trg.Period__c == mTarget.Period__c) {
                    if(trg.Territory__c == mTarget.Territory__c) {
                        if(trg.Rep__c == mTarget.Rep__c) {
                            cq.App.Logger.Warning('[FunnelAdditionTarget Error] ===> Duplicate FunnelAdditionTarget ' +
                                    'Found');
                            throw new TargetException('[FunnelAdditionTarget Error] ===> Duplicate FunnelAdditionTarget Found');
                        }
                    }
                }
            }
        }

    }

    private virtual class FunnelAdditionTargetException extends Exception { }
    private class TargetException extends FunnelAdditionTargetException {
        String message;
    }
}