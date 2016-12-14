package main.server;

public class IdIssuer {
	private static int serverId = 0;

	static int getServerId () {
		serverId += 1;
		return serverId;
	}
}