/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class AnnualTargetConfigTriggerHandler {

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
        List<Annual_Funnel_Addition_Target_Config__c> iConfigs = (List<Annual_Funnel_Addition_Target_Config__c>) Trigger.new;

        List<Annual_Funnel_Addition_Target_Config__c> toProcess = new List<Annual_Funnel_Addition_Target_Config__c>();
        //List<Annual_Funnel_Addition_Target_Config__c>

        for(Annual_Funnel_Addition_Target_Config__c config : iConfigs) {
            DuplicateHandler(config.Fiscal_Year__c, config);
        }
    }


    private static void DuplicateHandler(String fiscalYear, Annual_Funnel_Addition_Target_Config__c mConfigs) {
        //Boolean value = false;
        AnnualTargetSelector selector = new AnnualTargetSelector();
        List<Annual_Funnel_Addition_Target_Config__c> configs = selector.GetByFiscalYear(fiscalYear);
        Integer i = 0;
        for(Annual_Funnel_Addition_Target_Config__c config : configs) {
            if(config.Fiscal_Year__c == mConfigs.Fiscal_Year__c) {
                if(config.IsActive__c == true) {
                    if(config.Territory__c == mConfigs.Territory__c) {
                        cq.App.Logger.Error('[AnnualTargetConfig Error] ===> Duplicate Active Target Configuration Found');

                        throw new ConfigException('[AnnualTargetConfig Error] ===> Duplicate Active Target Configuration ' +  'Found');
                    }
                }
            }
        }

    }

    private virtual class AnnualConfigException extends Exception { }
    private class ConfigException extends AnnualConfigException {
        String message;
    }

}