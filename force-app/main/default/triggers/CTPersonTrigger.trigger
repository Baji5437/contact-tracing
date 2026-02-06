trigger CTPersonTrigger on Person__c (before insert,before update,after insert,after update, before delete, after delete, after undelete) {

    Switch on Trigger.operationType{
        WHEN BEFORE_INSERT{
            //Make Sure all the Person Records health Status green before inserting a record
            //Generate a Unique token for the user
            CTPersonTriggerHandler.beforeInsertHandler(Trigger.new);
        }

        WHEN BEFORE_UPDATE{
            CTPersonTriggerHandler.beforeUpdateHandler(Trigger.new,Trigger.oldMap);
        }

        WHEN AFTER_UPDATE{
            CTPersonTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }

    }

}