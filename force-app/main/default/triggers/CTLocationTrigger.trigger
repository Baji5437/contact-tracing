trigger CTLocationTrigger on Location__c (before insert,after insert,before update,after update) {

    Switch on Trigger.operationType{
        WHEN BEFORE_INSERT{
            CTLocationTriggerHandler.beforeInsert(Trigger.new);
        }
        WHEN BEFORE_UPDATE{
            CTLocationTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        WHEN AFTER_UPDATE{
            CTLocationTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
    }

}