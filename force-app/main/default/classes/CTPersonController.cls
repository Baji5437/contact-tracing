/**
 * CCTPersonController
 * Main Controller class for Person__c Object;
 * @author Baji;
 */

public with sharing class CTPersonController {
    /*method to generate an unique Token for the person using MD5 has algorithm
    //@param mobileNo
    //return String token
    */
    public Static String getToken(String mobileNo){
        Blob value = Blob.valueOf(mobileNo);
        Blob hashtoken = Crypto.generateDigest('MD5',value);

        //return Encoded String
        return EncodingUtil.base64Encode(hashtoken);   
    }

    /*getRecentHealthChanges
    //This method returns 100 contacts with 
    //recent health status Change
    ////return List<Person__c>
    */
    public Static List<Person__c> getRecentHealthChanges(){
        List<Person__c> personsList = [SELECT Id,Name,Health_Status__c,Mobile__c,Status_Update_Date__c,Token__c 
                                        FROM Person__c order by Status_Update_Date__c DESC NULLS LAST LIMIT 100 ];

        return personsList;
    }

    /* searchPeople
    // This Method returns the List of people matches the searchTerm
    //@param searchTerm;
    //return List<Person__c>
    */
    public Static List<Person__c> searchPeople(String searchTerm){

       searchTerm = searchTerm + '%';

        return [SELECT Id,Name,Health_Status__c,Mobile__c,Status_Update_Date__c,Token__c 
            FROM Person__c 
            WHERE NAME LIKE :searchTerm 
            OR Mobile__c LIKE :searchTerm  
            OR Token__c LIKE :searchTerm
            order by Status_Update_Date__c DESC NULLS LAST];

    }

    //return people matches the personId
    //@return Person__c
    public Static Person__c getPersonById(String personId){
        List<Person__c> people = [SELECT Id,Name,Health_Status__c,Mobile__c,Status_Update_Date__c,Token__c FROM Person__c WHERE Id =:personId ];

        if(people != null && people.size()>0 ){
            return people[0];
        }
        return null;
    }

    /*
    **Get Count of People in each Health Status
    ** @return Map<String,Integer>
    */

    public Static Map<String,Integer> getHealthStatusCount(){

        Map<String,Integer> mapPeopleHealthCount = new Map<String,Integer>();
        AggregateResult[] groupedResult = [SELECT Health_Status__c,COUNT(Id) HealthStatusCount 
                                            FROM Person__c GROUP BY Health_Status__c];
        if(groupedResult != null && groupedResult.size()>0){
            for(AggregateResult result : groupedResult){
                mapPeopleHealthCount.put(String.valueOf(result.get('Health_Status__c')),Integer.valueOf(result.get('HealthStatusCount')));
            }
            return mapPeopleHealthCount;
        }
        return null;
    }

    //TO-DO if a person health Status Updates to RED, update all the
    //cohabitants health Status to ORANGE, expect already which are orange and red

    public static Set<Id> getAllCohabitants(Set<Id> personIds,Set<Id> alreadyProcessed){

        List<String> healthStatus = new List<String>{'Green','Yellow'};

        List<People_Tracing__c> peopleTraces = [SELECT Id, Person_1__c, Person_2__c 
                                                    FROM People_Tracing__c
                                                    WHERE (Person_1__c IN :personIds
                                                    OR Person_2__c IN :personIds) 
                                                    AND Contact_Type__c = 'Cohabitant'
                                                    AND (Person_1__r.Health_Status__c IN :healthStatus
                                                    OR Person_2__r.Health_Status__c IN :healthStatus)];
        
        Set<Id> cohabitants = new Set<Id>();

        for(People_Tracing__c peopleTrace : peopleTraces){
            if(!alreadyProcessed.contains(peopleTrace.Person_1__c)){
                cohabitants.add(peopleTrace.Person_1__c);
                alreadyProcessed.add(peopleTrace.Person_1__c);
            }
            if(!alreadyProcessed.contains(peopleTrace.Person_2__c)){
                cohabitants.add(peopleTrace.Person_2__c);
                alreadyProcessed.add(peopleTrace.Person_2__c);
            }
        }
        return cohabitants;
    }

    public static Set<Id> getAllNeighbours(Set<Id> personIds,Set<Id> alreadyProcessed){

        List<People_Tracing__c> peopleTraces = [SELECT Id,Person_1__c,Person_2__c
                                                FROM People_Tracing__c
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                AND Contact_Type__c ='Neighbour'
                                                AND (Person_1__r.Health_Status__c = 'GREEN' OR Person_2__r.Health_Status__c = 'GREEN')];
        
        Set<Id> neighbours = new Set<Id>();
        for(People_Tracing__c peopleTrace : peopleTraces){
            if(!alreadyProcessed.contains(peopleTrace.Person_1__c)){
                neighbours.add(peopleTrace.Person_1__c);
                alreadyProcessed.add(peopleTrace.Person_1__c);
            }
            if(!alreadyProcessed.contains(peopleTrace.Person_2__c)){
                neighbours.add(peopleTrace.Person_2__c);
                alreadyProcessed.add(peopleTrace.Person_2__c);
            }
        }
        return neighbours;
    }

    public static Set<Id> getAllPrimaryContacts(Set<Id> personIds,Set<Id> alreadyProcessed){

        List<String> healthStatus = new List<String>{'GREEN','YELLOW'};

        List<People_Tracing__c> peopleTraces = [SELECT Id,Person_1__c,Person_2__c
                                                FROM People_Tracing__c
                                                WHERE (Person_1__c IN :personIds OR Person_2__c IN :personIds)
                                                AND Contact_Type__c ='other'
                                                AND Contact_Date__c = LAST_N_DAYS:10
                                                AND (Person_1__r.Health_Status__c IN :healthStatus
                                                    OR Person_2__r.Health_Status__c IN :healthStatus)];
        
        Set<Id> primaryContacts = new Set<Id>();

        for(People_Tracing__c peopleTrace : peopleTraces){
            if(!alreadyProcessed.contains(peopleTrace.Person_1__c)){
                primaryContacts.add(peopleTrace.Person_1__c);
                alreadyProcessed.add(peopleTrace.Person_1__c);
            }
            if(!alreadyProcessed.contains(peopleTrace.Person_2__c)){
                primaryContacts.add(peopleTrace.Person_2__c);
                alreadyProcessed.add(peopleTrace.Person_2__c);
            }
        }
        return primaryContacts;
    }


    public static Set<Id> getAllSecondaryContacts(Set<Id> primaryContactIds,Set<Id> alreadyProcessed){

        List<People_Tracing__c> peopleTraces = [SELECT Id,Person_1__c,Person_2__c
                                                FROM People_Tracing__c
                                                WHERE (Person_1__c IN :primaryContactIds OR Person_2__c IN :primaryContactIds)
                                                AND Contact_Type__c ='other'
                                                AND Contact_Date__c = LAST_N_DAYS:10
                                                AND (Person_1__r.Health_Status__c = 'GREEN' OR Person_2__r.Health_Status__c = 'GREEN') ];
        
        Set<Id> secondaryContacts = new Set<Id>();

        for(People_Tracing__c peopleTrace : peopleTraces){
            if(!alreadyProcessed.contains(peopleTrace.Person_1__c)){
                secondaryContacts.add(peopleTrace.Person_1__c);
                alreadyProcessed.add(peopleTrace.Person_1__c);
            }
            if(!alreadyProcessed.contains(peopleTrace.Person_2__c)){
                secondaryContacts.add(peopleTrace.Person_2__c);
                alreadyProcessed.add(peopleTrace.Person_2__c);
            }
        }
        return secondaryContacts;
    }

    
}