package jdbc.connection;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;



public class DatabaseConnection {

    private ConnectionConfig config;
    private List<Connection> connectionPool;
    private int poolSize;

  
    public DatabaseConnection() {
        this.config = new ConnectionConfig();
        this.poolSize = 5;
        this.connectionPool = new ArrayList<>();
    }

   
    public DatabaseConnection(ConnectionConfig config) {
        this.config = config;
        this.poolSize = 5;
        this.connectionPool = new ArrayList<>();
    }

   
    public DatabaseConnection(ConnectionConfig config, int poolSize) {
        this.config = config;
        this.poolSize = poolSize;
        this.connectionPool = new ArrayList<>();
    }

  
    public Connection getConnection() throws SQLException {
        // Check pool for a usable connection
        for (int i = 0; i < connectionPool.size(); i++) {
            Connection conn = connectionPool.get(i);
            if (conn != null && !conn.isClosed()) {
                connectionPool.remove(i);
                return conn;
            }
        }

    
        try {
            Connection conn = DriverManager.getConnection(config.getConnectionUrl());
            System.out.println("Connected to " + config.getDatabaseName() + " successfully.");
            return conn;
        } catch (SQLException e) {
            System.out.println("Connection failed: " + e.getMessage());
            throw e;
        }
    }

   
    public void releaseConnection(Connection conn) {
        if (conn == null) return;

        try {
            if (!conn.isClosed()) {
                if (connectionPool.size() < poolSize) {
                    connectionPool.add(conn);
                } else {
                    conn.close();
                }
            }
        } catch (SQLException e) {
            System.out.println("Error releasing connection: " + e.getMessage());
        }
    }

    
    public void closeAllConnections() {
        for (Connection conn : connectionPool) {
            try {
                if (conn != null && !conn.isClosed()) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.out.println("Error closing connection: " + e.getMessage());
            }
        }
        connectionPool.clear();
        System.out.println("All connections closed.");
    }

   
    public boolean testConnection() {
        try {
            Connection conn = getConnection();
            boolean valid = conn != null && !conn.isClosed();
            releaseConnection(conn);
            return valid;
        } catch (SQLException e) {
            System.out.println("Test connection failed: " + e.getMessage());
            return false;
        }
    }

    public ConnectionConfig getConfig() { return config; }
    public int getPoolSize() { return poolSize; }
    public int getActivePoolCount() { return connectionPool.size(); }
}
