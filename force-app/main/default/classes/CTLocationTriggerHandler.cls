public with sharing class CTLocationTriggerHandler {
    
    public static void beforeInsert(List<Location__c> newRecords){
        for(Location__c location: newRecords){
            location.Status__c = 'GREEN';
        }
    }

    public static void beforeUpdate(List<Location__c> newRecords, Map<Id,Location__c> oldLocationMapRecords){
        for(Location__c location : newRecords){
            if(location.Status__c != oldLocationMapRecords.get(location.Id).Status__c){
                location.Status_Update_Date__c = Date.today();
            }
        }
    }
    //If a locatin status changes to RED
    // Mark all Persons health status as YELLOW who visited that location in LAST 10 days
    public static void afterUpdate(List<Location__c> newRecords, Map<Id,Location__c> oldLocationMapRecords){

        Set<Id> redHealthStatusChangeLocationIds= new Set<Id>();

        for(Location__c location : newRecords){
            if(location.Status__c == 'RED' && oldLocationMapRecords.get(location.Id).Status__c != 'RED'){
                redHealthStatusChangeLocationIds.add(location.Id);
            }
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getPersonsByLocationIds(redHealthStatusChangeLocationIds);

        List<Person__c> personsToUpdate = new List<Person__c>();

        if(locationTraces != null && locationTraces.size()>0){

            Set<Id> personIds = new Set<Id>();

            for(Location_Tracing__c trace : locationTraces){
                personIds.add(trace.Person__c);
            }

             for(Id personId : personIds){
                personsToUpdate.add(new Person__c(Id=personId,Health_Status__c = 'YELLOW'));
             }
        }

        if(personsToUpdate!= null && personsToUpdate.size()>0){
            update personsToUpdate;
        }
      
    }
}