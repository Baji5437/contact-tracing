public with sharing class CTLocationStatusUpdateBatch implements Database.Batchable<SObject>{

    public Database.QueryLocator start(Database.BatchableContext bc){
        Set<String> healthStatuses = new Set<String>{'Red','Orange','Yellow'};
        return Database.getQueryLocator([SELECT Id,Status__c,Status_Update_Date__c 
                                        FROM  Location__c
                                        WHERE Status_Update_Date__c < N_DAYS_AGO:14
                                        AND Status__c IN :healthStatuses
                                        AND Status__c != Null]);

    }

    public void execute(Database.BatchableContext bc, List<Location__c> scope){
        for(Location__c location : scope){
            location.Status__c = 'Green';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc){
        System.debug('=====Batch Job Completed======');
    }   
}