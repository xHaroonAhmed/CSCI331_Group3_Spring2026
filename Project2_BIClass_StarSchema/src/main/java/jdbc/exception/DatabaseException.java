package jdbc.exception;
public class DatabaseException extends Exception {

    private String operation;

    public DatabaseException(String message) {
        super(message);
        this.operation = "Unknown";
    }

    public DatabaseException(String message, Throwable cause) {
        super(message, cause);
        this.operation = "Unknown";
    }

    public DatabaseException(String operation, String message, Throwable cause) {
        super(message, cause);
        this.operation = operation;
    }

    public String getOperation() { return operation; }

    @Override
    public String toString() {
        return "DatabaseException [operation=" + operation + "]: " + getMessage();
    }
}
