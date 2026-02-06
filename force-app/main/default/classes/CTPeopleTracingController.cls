public with sharing class CTPeopleTracingController {

    /*
    **get all the traceslist that this person met in lastfewdays
    */
    public Static List<People_Tracing__c> getTraces(String personId){

        return [SELECT Id,Contact_Date__c, Person_1__c,Person_1__r.Health_Status__c,Person_1__r.Token__c,Person_2__c,Person_2__r.Health_Status__c,Person_2__r.Token__c
                FROM People_Tracing__c
                WHERE (Person_1__c =:personId OR Person_2__c =:personId) AND Contact_Date__c = LAST_N_DAYS:30
                ORDER By Contact_Date__c DESC];

    } 

    public Static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> newPeopleTraces){
        //set of unique personIds

        Set<Id> uniquePersonIds = new Set<Id>();
        for(People_Tracing__c traces : newPeopleTraces){
            uniquePersonIds.add(traces.Person_1__c);
            uniquePersonIds.add(traces.Person_2__c);
        }

        //Map to Store whether Person1 & Person2 Combination Exists (should check for viceversa)
        Map<Id, Set<Id>> mapofExistingpPeopleTraces = new Map<Id,Set<Id>>();

        //List to store duplicatepeopletraces records
        List<People_Tracing__c> duplicatePeopleTraces = new List<People_Tracing__c>();

         //query existing People tracing records
         List<People_Tracing__c> existingPeopleTracingRecords = [SELECT Person_1__c,Person_2__c 
                                                                FROM People_Tracing__c
                                                                WHERE Person_1__c IN :uniquePersonIds
                                                                OR Person_2__c IN :uniquePersonIds];

        if(existingPeopleTracingRecords!=null && existingPeopleTracingRecords.size()>0){
            for(People_Tracing__c trace :existingPeopleTracingRecords){

                if(!mapofExistingpPeopleTraces.containsKey(trace.Person_1__c)){
                    mapofExistingpPeopleTraces.put(trace.Person_1__c,new Set<Id>());
                }
                mapofExistingpPeopleTraces.get(trace.Person_1__c).add(trace.Person_2__c);

                // build map for person 2
                if(!mapofExistingpPeopleTraces.containsKey(trace.Person_2__c)){
                    mapofExistingpPeopleTraces.put(trace.Person_2__c,new Set<Id>());
                }
                mapofExistingpPeopleTraces.get(trace.Person_2__c).add(trace.Person_1__c);
            }

            //loop over newPeopleTraces to check if there are any duplicates

            for(People_Tracing__c trace:newPeopleTraces){
                if(mapofExistingpPeopleTraces.containsKey(trace.Person_1__c) 
                    && mapofExistingpPeopleTraces.get(trace.Person_1__c).contains(trace.Person_2__c)){
                        duplicatePeopleTraces.add(trace);
                }
                 if(mapofExistingpPeopleTraces.containsKey(trace.Person_2__c) 
                    && mapofExistingpPeopleTraces.get(trace.Person_2__c).contains(trace.Person_1__c)){
                        duplicatePeopleTraces.add(trace);
                    }
            }
        
        }
        return duplicatePeopleTraces;

    }
    
}