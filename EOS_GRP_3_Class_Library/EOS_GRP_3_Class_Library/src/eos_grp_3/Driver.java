package eos_grp_3;

import eos_grp_3.repositories.CustomerRepository;
import eos_grp_3.repositories.EmployeeRepository;
import eos_grp_3.repositories.OrderRepository;

import java.util.List;

/**
 * EOS_GRP_3_Class_Library
 * Main driver class — demonstrates all repository operations.
 */
public class Driver {

    public static void main(String[] args) {

        // ── Employees ──────────────────────────────────────────
        EmployeeRepository empRepo = new EmployeeRepository();
        try {
            System.out.println("========== All Employees ==========");
            List<String> employees = empRepo.getAll();
            for (String e : employees) System.out.println(e);

            System.out.println("\n========== Employee ID 9 ==========");
            System.out.println(empRepo.getById(9));

            System.out.println("\n========== Update Employee 9 Country ==========");
            int empRows = empRepo.update("USA");
            System.out.println("Rows affected: " + empRows);

        } catch (Exception e) { e.printStackTrace(); }

        // ── Customers ──────────────────────────────────────────
        CustomerRepository custRepo = new CustomerRepository();
        try {
            System.out.println("\n========== All Customers ==========");
            List<String> customers = custRepo.getAll();
            for (String c : customers) System.out.println(c);

            System.out.println("\n========== Customer ID 5 ==========");
            System.out.println(custRepo.getById(5));

        } catch (Exception e) { e.printStackTrace(); }

        // ── Orders ─────────────────────────────────────────────
        OrderRepository orderRepo = new OrderRepository();
        try {
            System.out.println("\n========== All Orders ==========");
            List<String> orders = orderRepo.getAll();
            for (String o : orders) System.out.println(o);

            System.out.println("\n========== Order ID 10248 ==========");
            System.out.println(orderRepo.getById(10248));

        } catch (Exception e) { e.printStackTrace(); }
    }
}