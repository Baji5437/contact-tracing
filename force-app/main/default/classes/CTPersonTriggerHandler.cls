public with sharing class CTPersonTriggerHandler {

    //TO-DO we need to make sure the Person health Status is Green
    //before insertion
    //TO-DO We need to generate a unique token for each user inserted
    //and asign to user
    public Static Void beforeInsertHandler(List<Person__c> newRecords){
        for(Person__c people : newRecords){
            people.Health_Status__c = 'Green';
            people.Token__c = CTPersonController.getToken(people.Mobile__c);
        }

    }
    //TO-DO Whenever there is change in health Status of Person
    // we need to update the Status_Update_Date__c date field
    public Static Void beforeUpdateHandler(List<Person__c> newRecords, Map<Id,Person__c> oldMapPersonRecords){
        for(Person__c people : newRecords){
            if(people.Health_Status__c != oldMapPersonRecords.get(people.Id).Health_Status__c){
                people.Status_Update_Date__c = Date.today();
            }
        }
    }

    public Static void afterUpdateHandler(List<Person__c> newRecords, Map<Id,Person__c> oldMapPersonRecords){
        Set<Id> healthStatusChange = new Set<Id>();
        Set<Id> redHealthStatusChange = new Set<Id>();

        List<Person__c> personRecordsUpdate = new List<Person__c>();

        for(Person__c people : newRecords){
            if(people.Health_Status__c != oldMapPersonRecords.get(people.Id).Health_Status__c){
                healthStatusChange.add(people.Id);
            }

            if(people.Health_Status__c == 'RED' && oldMapPersonRecords.get(people.id).Health_Status__c != 'RED'){
                redHealthStatusChange.add(people.Id);
            }
        }

        /*
        // Cohabitants -- Health Status Should be changed to ORANGE
        // Neighbours -- Health Status Should be Changed to YELLOW
        // PrimaryContacts -- Health Status Should be Changed to ORANGE
        //SecondaryContacts -- Health Status Should be Changed to YELLOW
        */

        //one issue with this code is this its gonna process the same records again
        //Example, Lets say Abbas(Status:Red) --> Rubeena (Cohabitant) -- for this code will update rubeena health Status to ORANGE
        // Abbas --> Unish (Primary Contact) --> Unish Health Status -- ORANGE
        // Unish --> Rubeena (Neighbour) -- Now again Rubeena will come as secondary Contact for the main Contact abbas, the code will update the rubeena health status to yellow
        // this is a flaw in code, in order to avoid that, we use a set alreadyprocessed to not process same records again and again

        Set<Id> alreadyprocessed = new Set<Id>();
        alreadyprocessed.addAll(redHealthStatusChange);

        Set<Id> changeHealthStatusToYellow = new Set<Id>();
        Set<Id> changeHealthStatusToOrange = new Set<Id>();

        changeHealthStatusToOrange.addAll(CTPersonController.getAllCohabitants(redHealthStatusChange,alreadyprocessed));
        //high priorty to orange and then to yellow
        Set<Id> primaryContacts = CTPersonController.getAllPrimaryContacts(redHealthStatusChange,alreadyprocessed);
        changeHealthStatusToOrange.addAll(primaryContacts);

        changeHealthStatusToYellow.addAll(CTPersonController.getAllNeighbours(redHealthStatusChange,alreadyprocessed));
        changeHealthStatusToYellow.addAll(CTPersonController.getAllSecondaryContacts(primaryContacts,alreadyprocessed));

        for(Id personId :changeHealthStatusToOrange){
            personRecordsUpdate.add(new Person__c(Id=personId,Health_Status__c='Orange'));
        }
        for(Id personId : changeHealthStatusToYellow){
            personRecordsUpdate.add(new Person__c(Id=personId,Health_Status__c='Yellow'));
        }
        
        if(personRecordsUpdate != null && personRecordsUpdate.size()>0){
            update personRecordsUpdate;
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationByPersonIds(healthStatusChange);

        if(locationTraces != null && locationTraces.size()>0){

            Set<Id> locationIds = new Set<Id>();
            for(Location_Tracing__c trace : locationTraces){
                locationIds.add(trace.Location__c);
        }
        CTLocationController.updateRedScore(locationIds);
    }
    }

    
}