public with sharing class CTPeopleTracingTriggerHandler {
    
    public static void beforeInsert(List<People_Tracing__c> newRecords){

        List<People_Tracing__c> duplicatPeopleTraces = CTPeopleTracingController.checkDuplicates(newRecords);

        for(People_Tracing__c peopleTrace : duplicatPeopleTraces){
            peopleTrace.addError('Duplicate People Trace Record Found. Person1 Record' + peopleTrace.Person_1__c + 'Person2 Record' +peopleTrace.Person_2__c);
        }
        
    }
}