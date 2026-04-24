package jdbc.model;

import java.time.LocalDateTime;

public class WorkflowStepModel {

    private int    stepKey;
    private String procedureName;
    private int    rowsLoaded;
    private String startTime;
    private String endTime;
    private long   durationMs;
    private String executedBy;
    private int    personNumber;

    public WorkflowStepModel(int stepKey, String procedureName, int rowsLoaded,
                              String startTime, String endTime, long durationMs,
                              String executedBy, int personNumber) {
        this.stepKey       = stepKey;
        this.procedureName = procedureName;
        this.rowsLoaded    = rowsLoaded;
        this.startTime     = startTime;
        this.endTime       = endTime;
        this.durationMs    = durationMs;
        this.executedBy    = executedBy;
        this.personNumber  = personNumber;
    }

    public int    getStepKey()       { return stepKey; }
    public String getProcedureName() { return procedureName; }
    public int    getRowsLoaded()    { return rowsLoaded; }
    public String getStartTime()     { return startTime; }
    public String getEndTime()       { return endTime; }
    public long   getDurationMs()    { return durationMs; }
    public String getExecutedBy()    { return executedBy; }
    public int    getPersonNumber()  { return personNumber; }
}
