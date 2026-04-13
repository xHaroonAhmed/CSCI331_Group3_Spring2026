package eos_grp_3.repositories;

import eos_grp_3.factory.DataSourceFactory;
import eos_grp_3.interfaces.IDataRepository;
import eos_grp_3.interfaces.IDataSource;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * EOS_GRP_3_Class_Library
 * Repository for HumanResources.Employee table.
 * getById() uses stored procedure: HumanResources.usp_GetEmployeeById
 */
public class EmployeeRepository implements IDataRepository<String> {

    private final IDataSource dataSource = DataSourceFactory.getDataSource();

    @Override
    public List<String> getAll() throws Exception {
        List<String> results = new ArrayList<>();
        Connection conn = dataSource.getConnection();

        String sql = "SELECT EmployeeId, EmployeeLastName, EmployeeFirstName " +
                     "FROM HumanResources.Employee";

        Statement stmt = conn.createStatement();
        ResultSet rs   = stmt.executeQuery(sql);

        while (rs.next()) {
            results.add(rs.getInt("EmployeeId")          + " - " +
                        rs.getString("EmployeeLastName")  + ", " +
                        rs.getString("EmployeeFirstName"));
        }
        dataSource.closeConnection();
        return results;
    }

    @Override
    public String getById(int id) throws Exception {
        Connection conn = dataSource.getConnection();

        // Call stored procedure
        CallableStatement cs = conn.prepareCall(
            "{CALL HumanResources.usp_GetEmployeeById(?)}"
        );
        cs.setInt(1, id);
        ResultSet rs = cs.executeQuery();

        String result = null;
        if (rs.next()) {
            result = rs.getInt("EmployeeId")          + " - " +
                     rs.getString("EmployeeLastName")  + ", " +
                     rs.getString("EmployeeFirstName");
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
        Connection conn = dataSource.getConnection();

        String sql = "UPDATE HumanResources.Employee " +
                     "SET EmployeeCountry = ? " +
                     "WHERE EmployeeId = ?";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, entity);
        ps.setInt(2, 9);

        int rows = ps.executeUpdate();
        dataSource.closeConnection();
        return rows;
    }
    @Override
    public int delete(int id) throws Exception {
        // Future implementation
        return 0;
    }
}