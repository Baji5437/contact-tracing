public with sharing class CTStatusUpdateSchedule implements Schedulable{
    public final static String CRON_EXP = '0 0 3 * * ?';

    public void execute(SchedulableContext ctx) {

        CTPeopleHealthStatusUpdateBatch peoplehealthUpdate = new CTPeopleHealthStatusUpdateBatch();
       Database.executeBatch(peoplehealthUpdate,2000);

        CTLocationStatusUpdateBatch locationStatusUpdate = new CTLocationStatusUpdateBatch();
        Database.executeBatch(locationStatusUpdate, 2000);

    }
}