public with sharing class CTDataCleanUpSchedule implements schedulable{
    public final static String CRON_EXP = '0 0 2 * * ?';

    public void execute(SchedulableContext ctx) {

        CTPeopleTracingDataCleanUpBatch peopleTracingBatch = new CTPeopleTracingDataCleanUpBatch();
        Database.executeBatch(peopleTracingBatch,2000);

        CTLocationTracingCleanUpBatch locationTracingBatch = new CTLocationTracingCleanUpBatch();
        Database.executeBatch(locationTracingBatch,2000);
    }
}