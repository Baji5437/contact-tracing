/**
 * CTLocationController
 * Main Controller class for Location__c  Object;
 * @author Baji;
 */

public with sharing class CTLocationController {
    
    /*getRecentStatusChanges
    //This method returns 100 locations with 
    //recent health status Change
    //@ return List<Location__c>
    */
    public Static List<Location__c> getRecentStatusChanges(){
        List<Location__c> Locations = [SELECT Id,Name,Address__c,Pincode__c,Red_Score__c,Status__c,Status_Update_Date__c FROM Location__c
                                        order By Status_Update_Date__c DESC NULLS LAST LIMIT 100];
        return Locations;

    }
    /* searchLocations
    // This Method returns the List of locations matches the searchTerm
    //@param searchTerm;
    //return List<Location__c>
    */
    public Static List<Location__c> searchLocations(String searchTerm){
        searchTerm = '%' + searchTerm + '%';
        return [SELECT Id,Name,Address__c,Pincode__c,Red_Score__c,Status__c,Status_Update_Date__c 
                FROM Location__c 
                WHERE Address__c LIKE :searchTerm 
                OR Name LIKE :searchTerm
                OR Pincode__c LIKE :searchTerm
                order By Status_Update_Date__c DESC NULLS LAST];
    }
    //return Locations matches the locationId
    //@return Location__c
    public Static Location__c getLocationById(String locationId){
        List<Location__c> Locations = [SELECT Id,Name,Address__c,Pincode__c,Red_Score__c,Status__c,Status_Update_Date__c
                                        FROM Location__c WHERE Id =: locationId];
        if(Locations != null && Locations.size()>0){
            return Locations[0];
        }
        return null;
    }
    /*
    **Get Count of Locations with each Health Status
    ** @return Map<String,Integer>
    */

    public Static Map<String,Integer> getLocationHealthStatusCount(){

        Map<String,Integer> mapLocationHealthCount = new Map<String,Integer>();

        for(AggregateResult result : [SELECT Status__c,COUNT(Id) LocationStatusCount FROM Location__c  GROUP BY Status__c]){
            String status = String.valueOf(result.get('Status__c'));
            Integer count = Integer.valueOf(result.get('LocationStatusCount'));
            mapLocationHealthCount.put(status,count);
        }
        if(mapLocationHealthCount !=null && mapLocationHealthCount.size()>0){
            return mapLocationHealthCount;
        }
        return null;
    }
    
    public static void updateRedScore(Set<Id> locationIds){

        List<Location__c> locationsToUpdate = new List<Location__c>();
        AggregateResult[] results = [SELECT Location__c,Count(Id) total FROM Location_Tracing__c
                                  WHERE person__r.Health_Status__c = 'RED'
                                  AND Visit_Date__c = LAST_N_DAYS :10
                                  AND Location__c IN:locationIds
                                  GROUP BY Location__c];

        for(AggregateResult ar :results){

            String locationId = (Id)ar.get('Location__c');
            Integer redScore = (Integer)ar.get('total');
            String locationStatus = getLocationStatus(redScore);
            locationsToUpdate.add(new Location__c(Id=locationId,Red_Score__c=redScore,Status__c=locationStatus));
        }

        if(locationsToUpdate!= null && locationsToUpdate.size()>0){
            update locationsToUpdate;
        }
    }

    public static String getLocationStatus(Integer redScore){
        if(redScore == 0 ){
            return 'GREEN';
        }
        else if(redScore <= 5){
            return 'YELLOW';
        }
        else if(redScore > 5 && redScore <=10){
            return 'ORANGE';
        }
        else{
            return 'RED';
        }
    }

}