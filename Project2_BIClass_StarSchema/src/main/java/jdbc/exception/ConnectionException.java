package jdbc.exception;

public class ConnectionException extends DatabaseException {

    public ConnectionException(String message) {
        super("CONNECTION", message, null);
    }

    public ConnectionException(String message, Throwable cause) {
        super("CONNECTION", message, cause);
    }
}
