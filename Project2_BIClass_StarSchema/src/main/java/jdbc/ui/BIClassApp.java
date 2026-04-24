package jdbc.ui;

import jdbc.connection.ConnectionConfig;
import jdbc.connection.DatabaseConnection;
import jdbc.model.WorkflowStepModel;

import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;


public class BIClassApp extends JFrame {

   
    private final DatabaseConnection dbConnection;

   
    private JTable            workflowTable;
    private DefaultTableModel tableModel;
    private JTextArea         statusArea;
    private JButton           loadSchemaBtn;
    private JButton           showWorkflowBtn;
    private JLabel            summaryLabel;

    private static final String[] COLUMNS = {
        "Step", "Procedure", "Rows Loaded",
        "Start Time", "End Time", "Duration (ms)",
        "Executed By", "Person #"
    };

    public BIClassApp() {
       
        ConnectionConfig biClassConfig = new ConnectionConfig(
            "localhost", "SQLEXPRESS", "BIClass"
        );
        dbConnection = new DatabaseConnection(biClassConfig);

        buildUI();
        testConnection();
    }

  
    private void buildUI() {
        setTitle("CSCI 331 - Project 2  |  BIClass Star Schema  |  EOS Group 3");
        setSize(1100, 700);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

    
        JPanel bannerPanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 5));
        bannerPanel.setBackground(new Color(30, 90, 160));
        JLabel bannerLabel = new JLabel(
            "  Database: BIClass  |  Server: localhost\\SQLEXPRESS  |  EOS Group 3  |  CSCI 331"
        );
        bannerLabel.setForeground(Color.WHITE);
        bannerLabel.setFont(new Font("SansSerif", Font.BOLD, 13));
        bannerPanel.add(bannerLabel);
        add(bannerPanel, BorderLayout.NORTH);

        tableModel = new DefaultTableModel(COLUMNS, 0) {
            @Override public boolean isCellEditable(int row, int col) { return false; }
        };
        workflowTable = new JTable(tableModel);
        workflowTable.setAutoResizeMode(JTable.AUTO_RESIZE_ALL_COLUMNS);
        workflowTable.setRowHeight(22);
        workflowTable.getTableHeader().setFont(new Font("SansSerif", Font.BOLD, 12));
        workflowTable.setFont(new Font("Monospaced", Font.PLAIN, 11));

        JScrollPane tableScroll = new JScrollPane(workflowTable);
        tableScroll.setBorder(BorderFactory.createTitledBorder(
            "Workflow Execution Log  (Process.usp_ShowWorkflowSteps)"
        ));

        // --- Bottom: controls + status ---
        JPanel controlPanel = new JPanel(new BorderLayout(10, 5));
        controlPanel.setBorder(BorderFactory.createEmptyBorder(5, 10, 5, 10));

        // Buttons
        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 0));

        loadSchemaBtn = new JButton("▶  Load Star Schema  (Project2.LoadStarSchemaData)");
        loadSchemaBtn.setFont(new Font("SansSerif", Font.BOLD, 13));
        loadSchemaBtn.setBackground(new Color(34, 139, 34));
        loadSchemaBtn.setForeground(Color.WHITE);
        loadSchemaBtn.setOpaque(true);
        loadSchemaBtn.setPreferredSize(new Dimension(380, 38));
        loadSchemaBtn.addActionListener(e -> runLoadStarSchema());

        showWorkflowBtn = new JButton("📋  Show Workflow Steps  (Process.usp_ShowWorkflowSteps)");
        showWorkflowBtn.setFont(new Font("SansSerif", Font.BOLD, 13));
        showWorkflowBtn.setBackground(new Color(30, 90, 160));
        showWorkflowBtn.setForeground(Color.WHITE);
        showWorkflowBtn.setOpaque(true);
        showWorkflowBtn.setPreferredSize(new Dimension(380, 38));
        showWorkflowBtn.addActionListener(e -> runShowWorkflowSteps());

        JButton clearBtn = new JButton("Clear Log");
        clearBtn.setPreferredSize(new Dimension(110, 38));
        clearBtn.addActionListener(e -> {
            tableModel.setRowCount(0);
            summaryLabel.setText("Table cleared.");
            statusArea.setText("");
        });

        buttonPanel.add(loadSchemaBtn);
        buttonPanel.add(showWorkflowBtn);
        buttonPanel.add(clearBtn);

        summaryLabel = new JLabel("  Ready — click a button above to begin.");
        summaryLabel.setFont(new Font("SansSerif", Font.ITALIC, 12));

        statusArea = new JTextArea(5, 80);
        statusArea.setEditable(false);
        statusArea.setFont(new Font("Monospaced", Font.PLAIN, 11));
        statusArea.setBackground(new Color(240, 240, 240));
        JScrollPane statusScroll = new JScrollPane(statusArea);
        statusScroll.setBorder(BorderFactory.createTitledBorder("Status / Console"));

        controlPanel.add(buttonPanel,   BorderLayout.NORTH);
        controlPanel.add(summaryLabel,  BorderLayout.CENTER);
        controlPanel.add(statusScroll,  BorderLayout.SOUTH);

        add(tableScroll,   BorderLayout.CENTER);
        add(controlPanel,  BorderLayout.SOUTH);
    }

    
    private void testConnection() {
        if (dbConnection.testConnection()) {
            log("✅ Connected to BIClass successfully.");
            summaryLabel.setText("  Connected to BIClass. Ready.");
        } else {
            log("❌ Could not connect to BIClass. Check SQL Server Express is running.");
            summaryLabel.setText("  Connection FAILED — check your database.");
            JOptionPane.showMessageDialog(this,
                "Could not connect to BIClass.\n\nMake sure SQL Server Express is running.",
                "Connection Failed", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void runLoadStarSchema() {
        loadSchemaBtn.setEnabled(false);
        showWorkflowBtn.setEnabled(false);
        summaryLabel.setText("  Running ETL pipeline... please wait.");
        log("Executing [Project2].[LoadStarSchemaData]...");

        SwingWorker<Void, String> worker = new SwingWorker<>() {
            @Override
            protected Void doInBackground() {
                Connection conn = null;
                try {
                    conn = dbConnection.getConnection();
                    // Use CallableStatement to call the stored procedure
                    try (CallableStatement cs = conn.prepareCall(
                            "{CALL [Project2].[LoadStarSchemaData]}")) {
                        cs.execute();
                        publish("✅ [Project2].[LoadStarSchemaData] completed successfully!");
                    }
                } catch (SQLException e) {
                    publish("❌ Error running LoadStarSchemaData: " + e.getMessage());
                } finally {
                    if (conn != null) dbConnection.releaseConnection(conn);
                }
                return null;
            }

            @Override
            protected void process(List<String> chunks) {
                chunks.forEach(BIClassApp.this::log);
            }

            @Override
            protected void done() {
                loadSchemaBtn.setEnabled(true);
                showWorkflowBtn.setEnabled(true);
                summaryLabel.setText("  ETL complete. Click 'Show Workflow Steps' to see results.");
                // Auto-refresh the table after loading
                runShowWorkflowSteps();
            }
        };
        worker.execute();
    }

    private void runShowWorkflowSteps() {
        showWorkflowBtn.setEnabled(false);
        summaryLabel.setText("  Loading workflow steps...");
        log("Executing [Process].[usp_ShowWorkflowSteps]...");

        SwingWorker<List<WorkflowStepModel>, Void> worker = new SwingWorker<>() {
            @Override
            protected List<WorkflowStepModel> doInBackground() {
                List<WorkflowStepModel> steps = new ArrayList<>();
                Connection conn = null;
                try {
                    conn = dbConnection.getConnection();
                    try (CallableStatement cs = conn.prepareCall(
                            "{CALL [Process].[usp_ShowWorkflowSteps]}");
                         ResultSet rs = cs.executeQuery()) {

                        while (rs.next()) {
                            steps.add(new WorkflowStepModel(
                                rs.getInt("Step"),
                                rs.getString("Procedure"),
                                rs.getInt("Rows Loaded"),
                                rs.getString("Start Time"),
                                rs.getString("End Time"),
                                rs.getLong("Duration (ms)"),
                                rs.getString("Executed By"),
                                rs.getInt("Person #")
                            ));
                        }
                    }
                } catch (SQLException e) {
                    log("❌ Error running usp_ShowWorkflowSteps: " + e.getMessage());
                } finally {
                    if (conn != null) dbConnection.releaseConnection(conn);
                }
                return steps;
            }

            @Override
            protected void done() {
                try {
                    List<WorkflowStepModel> steps = get();
                    populateTable(steps);
                    showWorkflowBtn.setEnabled(true);
                } catch (Exception e) {
                    log("❌ " + e.getMessage());
                    showWorkflowBtn.setEnabled(true);
                }
            }
        };
        worker.execute();
    }

    private void populateTable(List<WorkflowStepModel> steps) {
        tableModel.setRowCount(0);

        if (steps.isEmpty()) {
            summaryLabel.setText("  No workflow steps found. Run 'Load Star Schema' first.");
            log("No rows returned from usp_ShowWorkflowSteps.");
            return;
        }

        long totalMs   = 0;
        int  totalRows = 0;

        for (WorkflowStepModel s : steps) {
            tableModel.addRow(new Object[]{
                s.getStepKey(),
                s.getProcedureName(),
                s.getRowsLoaded(),
                s.getStartTime(),
                s.getEndTime(),
                s.getDurationMs(),
                s.getExecutedBy(),
                s.getPersonNumber()
            });
            totalMs   += s.getDurationMs();
            totalRows += s.getRowsLoaded();
        }

        String summary = String.format(
            "  ✅ %d steps loaded  |  Total rows: %,d  |  Total time: %,d ms (%.2f sec)",
            steps.size(), totalRows, totalMs, totalMs / 1000.0
        );
        summaryLabel.setText(summary);
        log(summary.trim());
        log("Table populated with " + steps.size() + " workflow steps.");
    }
    private void log(String message) {
        SwingUtilities.invokeLater(() -> {
            statusArea.append("[" + java.time.LocalTime.now().toString().substring(0, 8) + "] "
                + message + "\n");
            statusArea.setCaretPosition(statusArea.getDocument().getLength());
        });
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new BIClassApp().setVisible(true));
    }
}
