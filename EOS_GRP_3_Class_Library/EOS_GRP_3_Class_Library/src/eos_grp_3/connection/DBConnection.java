package eos_grp_3.connection;

import eos_grp_3.interfaces.IDataSource;
import java.sql.Connection;
import java.sql.DriverManager;

/**
 * EOS_GRP_3_Class_Library
 * Concrete implementation of IDataSource.
 * Manages SQL Server connection to NorthWinds2024Student.
 */
public class DBConnection implements IDataSource {

    private static final String URL =
        "jdbc:sqlserver://localhost:14001;" +
        "databaseName=NorthWinds2024Student;" +
        "encrypt=false;" +
        "trustServerCertificate=true";

    private static final String USER     = "sa";
    private static final String PASSWORD = "PH@123456789";

    private Connection conn = null;

    @Override
    public Connection getConnection() throws Exception {
        if (conn == null || conn.isClosed()) {
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("[EOS_GRP_3] Connection established successfully.");
        }
        return conn;
    }

    @Override
    public void closeConnection() throws Exception {
        if (conn != null && !conn.isClosed()) {
            conn.close();
            System.out.println("[EOS_GRP_3] Connection closed.");
        }
    }
}