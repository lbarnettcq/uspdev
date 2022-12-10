/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class BulkDeleteUtil {

    private static Integer m_Limit;
    private static SObjectType m_TARGETSOBJECT;
    private static SObjectField m_FILTERINGFIELD;

    private static BulkDeleteUtil m_Instance;
    public static BulkDeleteUtil Instance {
        get {
            if(m_Instance != null) { return m_Instance;}
            m_Instance = new BulkDeleteUtil();
            return m_Instance;
        }
    }

    public String GenerateQueryFor(SObjectType targetSobject, SObjectField filteringField) {
        String query = '';
        String targetObject = targetSobject.getDescribe().getName();
        if(targetSobject.getDescribe().fields.getMap().containsKey(String.valueOf(filteringField.getDescribe().name)
                .toLowerCase()))
        {
            query = '[SELECT Id,' + filteringField.getDescribe().name + ' FROM ' + targetObject + ']';
            m_TARGETSOBJECT = targetSobject;
            m_FILTERINGFIELD = filteringField;
        }
        return query;
    }

    public void Execute(List<Sobject> scope) {
        if(!scope.isEmpty()){
            Sobject ref = scope[0];
            if(ref.getSObjectType() == m_TARGETSOBJECT) {
                Map<Id, SObject> dataMap = new Map<Id, SObject>(scope);
                Map<String, Sobject> filterMap = new Map<String, SObject>();
                for(Id key : dataMap.keySet()) {
                    SObject obj = dataMap.get(key);
                    if(!filterMap.keySet().contains(String.valueOf(obj.get(m_FILTERINGFIELD)))){
                        filterMap.put(String.valueOf(obj.get(m_FILTERINGFIELD)), obj);
                        dataMap.remove(obj.Id);
                    }
                }

                delete dataMap.values();
            }
        }
    }

}