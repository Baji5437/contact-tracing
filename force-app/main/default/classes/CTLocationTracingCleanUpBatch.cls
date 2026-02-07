public with sharing class CTLocationTracingCleanUpBatch implements Database.Batchable<SObject>{

    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('=== Batch Started ===');
        System.debug('Job ID: ' + bc.getJobId());
        return Database.getQueryLocator([SELECT Id from Location_Tracing__c 
                                         where Visit_Date__c < N_DAYS_AGO:30]);
    }

    public void execute(Database.BatchableContext bc,List<Location_Tracing__c> scope){
        System.debug('Processing batch. Records in scope: ' + scope.size());
        delete scope;
    }

    public void finish(Database.BatchableContext bc){
        Id jobId = bc.getJobId();

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                            JobItemsProcessed, TotalJobItems, 
                            CreatedBy.Email, CompletedDate
                            FROM AsyncApexJob 
                            WHERE Id = :jobId];
        
        System.debug('=== Batch Completed ===');
        System.debug('Job ID: ' + jobId);
        System.debug('Status: ' + job.Status);
        System.debug('Total Batches Processed: ' + job.JobItemsProcessed);
        System.debug('Total Batches: ' + job.TotalJobItems);
        System.debug('Errors: ' + job.NumberOfErrors);
        System.debug('Completed At: ' + job.CompletedDate);
        
        // Optional: Send email with results
        if(job.NumberOfErrors == 0){
            System.debug('SUCCESS: All records deleted successfully');
        } else {
            System.debug('WARNING: Some batches failed');
        }
    }
}