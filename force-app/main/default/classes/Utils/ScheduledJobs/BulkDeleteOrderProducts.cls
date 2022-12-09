/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class BulkDeleteOrderProducts implements Database.Batchable<Sobject>, Schedulable{

    private String query;

    public BulkDeleteOrderProducts() {
        this.query = BulkDeleteUtil.Instance.GenerateQueryFor(Order_Product__c.SObjectType, Order_Product__c.UniqueOrderProductID__c);
    }

    public void execute(SchedulableContext param1) {
        Database.executeBatch(this);
    }

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext param1, List<Sobject> param2) {
        BulkDeleteUtil.Instance.Execute(param2);
    }

    public void finish(Database.BatchableContext param1) {
    }


}