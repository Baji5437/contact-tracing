public with sharing class CTLocationTabController {

    @AuraEnabled
    public static LocationInformation getLocationDetails(String recordId){

        LocationInformation locationInfo = new LocationInformation();

        Location__c location = CTLocationController.getLocationById(recordId);

        if(location != null){
            locationInfo.name = location.Name;
            locationInfo.redScore = (Integer)location.Red_Score__c;
            locationInfo.statusUpdateOn = location.Status_Update_Date__c;
            locationInfo.address = location.Address__c;
            locationInfo.pincode = location.Pincode__c;
            locationInfo.status = location.Status__c;
        }
        
        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getVisitors(recordId);

        if(locationTraces !=null && locationTraces.size()>0){
            locationInfo.visitors = new List<visitorsList>();

            for(Location_Tracing__c trace : locationTraces){
                visitorsList vc = new visitorsList();

                vc.personName = trace.Person__r.Name;
                vc.personHealthStatus = trace.Person__r.Health_Status__c;
                vc.personToken = trace.Person__r.Token__c;
                vc.visitDate = trace.Visit_Date__c;

                locationInfo.visitors.add(vc);
            }
            locationInfo.visitorsCount = locationInfo.visitors.size();
        }

        return locationInfo;
        
    }
    public class LocationInformation{

        @AuraEnabled public String name;
        @AuraEnabled public Integer redScore;
        @AuraEnabled public Date statusUpdateOn;
        @AuraEnabled public String address;
        @AuraEnabled public String pincode;
        @AuraEnabled public String status;
        @AuraEnabled public Integer visitorsCount=0;
        @AuraEnabled public List<visitorsList> visitors;       
    }

    public class visitorsList{

        @AuraEnabled public String personName;
        @AuraEnabled public String personHealthStatus;
        @AuraEnabled public String personToken;
        @AuraEnabled public Date visitDate;
    }
}