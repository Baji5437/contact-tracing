public with sharing class CTPeopleHealthStatusUpdateBatch implements Database.Batchable<SObject>{

    public Database.QueryLocator start(Database.BatchableContext bc){
        Set<String> healthStatuses = new Set<String>{'Red','Orange','Yellow'};
        return Database.getQueryLocator([SELECT Id,Health_Status__c,Status_Update_Date__c 
                                        FROM Person__c 
                                        WHERE Status_Update_Date__c < N_DAYS_AGO:14
                                        AND Health_Status__c IN :healthStatuses
                                        AND Health_Status__c != Null]);

    }

    public void execute(Database.BatchableContext bc, List<Person__c> scope){
        for(Person__c person : scope){
            person.Health_Status__c = 'Green';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc){
        System.debug('=====Batch Job Completed======');
    }   
}