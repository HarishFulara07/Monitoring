package main.exception;

// Exception class for throwing exceptions whenever a server property is violated.

@SuppressWarnings("serial")
public class ServerException extends Exception {
	public ServerException (String message) {
		super(message);
	}
}