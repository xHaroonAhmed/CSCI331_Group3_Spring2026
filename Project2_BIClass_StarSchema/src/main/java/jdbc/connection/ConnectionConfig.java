package jdbc.connection;


public class ConnectionConfig {

    private String serverName;
    private String instanceName;
    private String databaseName;


    public ConnectionConfig() {
        this.serverName = "localhost";
        this.instanceName = "SQLEXPRESS";
        this.databaseName = "Northwinds2024Student";
    }

    public ConnectionConfig(String serverName, String instanceName, String databaseName) {
        this.serverName = serverName;
        this.instanceName = instanceName;
        this.databaseName = databaseName;
    }

    
    public String getConnectionUrl() {
        return "jdbc:sqlserver://" + serverName + "\\" + instanceName
             + ";databaseName=" + databaseName
             + ";integratedSecurity=true"
             + ";encrypt=true;trustServerCertificate=true";
    }

    public String getServerName() { return serverName; }
    public void setServerName(String serverName) { this.serverName = serverName; }

    public String getInstanceName() { return instanceName; }
    public void setInstanceName(String instanceName) { this.instanceName = instanceName; }

    public String getDatabaseName() { return databaseName; }
    public void setDatabaseName(String databaseName) { this.databaseName = databaseName; }

    @Override
    public String toString() {
        return "ConnectionConfig [server=" + serverName + "\\" + instanceName
             + ", database=" + databaseName + "]";
    }
}
