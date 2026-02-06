public with sharing class CTPersonTabController {

    @AuraEnabled
    public static UserInformation getPersonDetails(String personId) {

        UserInformation info = new UserInformation();

        Person__c person = CTPersonController.getPersonById(personId);

        if (person != null) {
            info.name = person.Name;
            info.token = person.Token__c;
            info.statusUpdateOn = person.Status_Update_Date__c;
            info.phone = person.Mobile__c;
            info.status = person.Health_Status__c;
        }

        List<People_Tracing__c> traces = CTPeopleTracingController.getTraces(personId);

        if (traces != null && !traces.isEmpty()) {

            info.closeContacts = new List<CloseContacts>();
            Set<Id> uniqueIds = new Set<Id>();
            uniqueIds.add(personId);

            for (People_Tracing__c trace : traces) {

                // Person 1
                if (trace.Person_1__c != null && !uniqueIds.contains(trace.Person_1__c)) {
                    CloseContacts cc1 = new CloseContacts();
                    cc1.Id = trace.Person_1__c;
                    cc1.token = trace.Person_1__r.Token__c;
                    cc1.status = trace.Person_1__r.Health_Status__c;
                    cc1.contactDate = trace.Contact_Date__c;

                    info.closeContacts.add(cc1);
                    uniqueIds.add(trace.Person_1__c);
                }

                // Person 2
                if (trace.Person_2__c != null && !uniqueIds.contains(trace.Person_2__c)) {
                    CloseContacts cc2 = new CloseContacts();
                    cc2.Id = trace.Person_2__c;
                    cc2.token = trace.Person_2__r.Token__c;
                    cc2.status = trace.Person_2__r.Health_Status__c;
                    cc2.contactDate = trace.Contact_Date__c;

                    info.closeContacts.add(cc2);
                    uniqueIds.add(trace.Person_2__c);
                }
            }

            info.closeContactsCount = info.closeContacts.size();
        }

        return info;
    }

    public class UserInformation {
        @AuraEnabled public String name;
        @AuraEnabled public String token;
        @AuraEnabled public Date statusUpdateOn;
        @AuraEnabled public String phone;
        @AuraEnabled public String status;
        @AuraEnabled public Integer closeContactsCount = 0;
        @AuraEnabled public List<CloseContacts> closeContacts;
    }

    public class CloseContacts {
        @AuraEnabled public Id Id;
        @AuraEnabled public String token;
        @AuraEnabled public Date contactDate;
        @AuraEnabled public String status;
    }
}
