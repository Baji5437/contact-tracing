public with sharing class CTLocationTracingTriggerHandler {
    
    public static void beforeInsert(List<Location_Tracing__c> newRecords){

        List<Location_Tracing__c> duplicateLocationTraces = CTLocationTracingController.checkDuplicates(newRecords);

        for(Location_Tracing__c locationTrace : duplicateLocationTraces){
            locationTrace.addError('Duplicate Location Trace Record Found.Location' + locationTrace.Location__c +'Person Recors'+ locationTrace.Person__c);
        }
    }
}