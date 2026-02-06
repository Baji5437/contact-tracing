/**
 * CTLocationControCTLocationTracingControllerller
 * Main Controller class for Location_Tracing__c  Object;
 * @author Baji;
 */

public with sharing class CTLocationTracingController {
    
    /*get last 30 days visitors
    ** @param locationId
    **@return List<Location_Tracing__c>
    */
    public Static List<Location_Tracing__c> getVisitors(String locationId){

        return [SELECT Id,Location__c,Person__c,Person__r.Name,Person__r.Health_Status__c, Person__r.Token__c,Visit_Date__c 
                FROM Location_Tracing__c 
                WHERE  Location__c =: locationId
                ORDER BY Visit_Date__c DESC];

    }
    /*
    ** Get all location Id's of visitors
    * @param personIds
    *@return List<Location_Tracing__c>
    */
    public Static List<Location_Tracing__c> getLocationByPersonIds(Set<Id> personIds){

        return [SELECT Id,Location__c,Person__c,Visit_Date__c 
                FROM Location_Tracing__c 
                WHERE Person__c IN : personIds 
                AND Visit_Date__c = LAST_N_DAYS:10];

    }

    /*
    *get all visitor Id's for locations
    ** @param locationIds
    ** @return List<Location_Tracing__c>
    */
    public Static List<Location_Tracing__c> getLocationByLocationIds(Set<Id> locationIds){

        return [SELECT Id,Person__c,Location__c 
                FROM Location_Tracing__c 
                WHERE Location__c IN : locationIds AND Person__r.Health_Status__c ='Green'
                AND Visit_Date__c = LAST_N_DAYS:10];
    }
    /*
    ** CheckDuplicates of LocationTraces 
    */
    public Static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLocationTraces){
        
        //store unique LocationIds
        Set<Id> uniqueLocationIds = new Set<Id>();
        //store unique PersonIds
        Set<Id> uniquePersonIds = new Set<Id>();

        for(Location_Tracing__c trace : newLocationTraces){

            uniqueLocationIds.add(trace.Location__c);
            uniquePersonIds.add(trace.Person__c);
        }

        //Map to store LocationId,SetofPersonIds
        //location1,[Person1,Person2]
        Map<Id,Set<Id>> mapOfExistingRecords = new Map<Id,Set<Id>>();

        //query existing location tracing records
        List<Location_Tracing__c> existingRecords = [SELECT Id,Person__c,Location__c 
                                                    FROM Location_Tracing__c
                                                    WHERE Location__c IN :uniqueLocationIds
                                                    AND Person__c IN: uniquePersonIds];


        List<Location_Tracing__c> duplicateRecords = new List<Location_Tracing__c>();

        if(existingRecords!= null && existingRecords.size()>0){
            for(Location_Tracing__c trace :existingRecords){
                if(!mapOfExistingRecords.containsKey(trace.Location__c)){
                    mapOfExistingRecords.put(trace.Location__c,new Set<Id>());
                }
                // add person ids to map set
                mapOfExistingRecords.get(trace.Location__c).add(trace.Person__c);
            }

            for(Location_Tracing__c trace: newLocationTraces){
                // first check for location id
                // if item found in map, then check for person in set
                if(mapOfExistingRecords.containsKey(trace.Location__c)&& 
                    mapOfExistingRecords.get(trace.Location__c).contains(trace.Person__c)){
                        duplicateRecords.add(trace);
                    }
            }
        }
        return duplicateRecords;

    }

    public static List<Location_Tracing__c> getPersonsByLocationIds(Set<Id> locationIds){

        return [SELECT Id,Person__c,Location__c 
                FROM Location_Tracing__c 
                WHERE Location__c IN : locationIds AND Person__r.Health_Status__c ='Green'
                AND Visit_Date__c = LAST_N_DAYS:10];
    }

}