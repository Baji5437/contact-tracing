public with sharing class CTHealthHeaderController {

    @AuraEnabled
    public static Map<String,Integer> getPeopleHealthStatusCount(){
        return CTPersonController.getHealthStatusCount();
    }

    @AuraEnabled
    public static Map<String,Integer> getLocationHealthStatusCount(){
        return CTLocationController.getLocationHealthStatusCount();
    }

}