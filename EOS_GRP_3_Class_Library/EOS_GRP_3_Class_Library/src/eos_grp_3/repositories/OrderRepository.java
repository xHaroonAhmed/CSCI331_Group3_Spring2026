package eos_grp_3.repositories;

import eos_grp_3.factory.DataSourceFactory;
import eos_grp_3.interfaces.IDataRepository;
import eos_grp_3.interfaces.IDataSource;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * EOS_GRP_3_Class_Library
 * Repository for Sales.Order table.
 * getById() uses stored procedure: Sales.usp_GetOrderById
 */
public class OrderRepository implements IDataRepository<String> {

    private final IDataSource dataSource = DataSourceFactory.getDataSource();

    @Override
    public List<String> getAll() throws Exception {
        List<String> results = new ArrayList<>();
        Connection conn = dataSource.getConnection();

        String sql = "SELECT OrderId, CustomerId, OrderDate " +
                     "FROM Sales.[Order]";

        Statement stmt = conn.createStatement();
        ResultSet rs   = stmt.executeQuery(sql);

        while (rs.next()) {
            results.add("Order#: "    + rs.getInt("OrderId")    +
                        " | CustId: " + rs.getInt("CustomerId") +
                        " | Date: "   + rs.getDate("OrderDate"));
        }
        dataSource.closeConnection();
        return results;
    }

    @Override
    public String getById(int id) throws Exception {
        Connection conn = dataSource.getConnection();

        // Call stored procedure
        CallableStatement cs = conn.prepareCall(
            "{CALL Sales.usp_GetOrderById(?)}"
        );
        cs.setInt(1, id);
        ResultSet rs = cs.executeQuery();

        String result = null;
        if (rs.next()) {
            result = "Order#: "    + rs.getInt("OrderId")       +
                     " | CustId: " + rs.getInt("CustomerId")    +
                     " | Date: "   + rs.getDate("OrderDate");
        }
        dataSource.closeConnection();
        return result;
    }

    @Override
    public int insert(String entity) throws Exception {
        // Future implementation
        return 0;
    }

    @Override
    public int update(String entity) throws Exception {
        // Future implementation
        return 0;
    }

    @Override
    public int delete(int id) throws Exception {
        // Future implementation
        return 0;
    }
}