package eos_grp_3.interfaces;

import java.sql.Connection;

public interface IDataSource {
    Connection getConnection() throws Exception;
    void closeConnection() throws Exception;
}