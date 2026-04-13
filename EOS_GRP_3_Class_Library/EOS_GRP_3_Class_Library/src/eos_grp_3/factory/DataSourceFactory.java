package eos_grp_3.factory;

import eos_grp_3.connection.DBConnection;
import eos_grp_3.interfaces.IDataSource;

/**
 * EOS_GRP_3_Class_Library
 * Abstract Factory — returns the appropriate IDataSource implementation.
 */
public class DataSourceFactory {

    public static IDataSource getDataSource() {
        return new DBConnection();
    }
}