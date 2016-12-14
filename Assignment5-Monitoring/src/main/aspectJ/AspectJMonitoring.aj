package main.aspectJ;

import java.util.HashMap;
import java.util.Map;

import main.client.Client;
import main.exception.ServerException;
import main.server.Server;

// AspectJ for monitoring the server class.
// It will throw an appropriate exception if client violates any property of the server.

// Following are the properties of the server
/*
 * Property 1 : Every server start must be followed by a stop.
 * Property 2 : A start must precede every stop.
 * Property 3 : Two or more consecutive stops are acceptable.
 * Property 4 : Two or more consecutive starts are unacceptable.
 * Property 5 : A server that is stopped can be restarted.
 * Property 6 : Multiple process requests are acceptable,
 *              but no processing can happen between two consecutive
 *              starts or two consecutive stops.
 * Property 7 : The total process time between every pair of start and stop
 *              must not exceed three seconds. This may result due to multiple process requests.
 */

// ASSUMPTIONS
/*
 * 1. The client will keep on executing commands. If there is a property violation,
 *    an appropriate exception will be thrown but client execution will continue.
 *    
 *    For example, if client issues START START STOP, then an appropriate exception will
 *    be thrown for second START command but client will continue and execute STOP also.
 *    
 * 2. The monitor will only report error in case of property violation. It will not take
 *    any evasive steps.
 *    
 */

public aspect AspectJMonitoring {
	// Map to maintain server state.
	// Key - Server Id.
	// Value - Server State (true means server is in RUNNING state, false means server is in STOPPED state .
	Map<Integer, Boolean> serverStateMap = new HashMap<Integer, Boolean>();
	
	// Checking that a started server eventually stops.
	pointcut checkServerStopBeforeExit() : execution (public static void Client.main(String []));
	// Performing checks before server starts.
	pointcut serverStartChecks(Server server) : call (* Server.start(..)) && target(server);
	// Performing checks before server stops.
	pointcut serverStopChecks(Server server) : call (* Server.stop(..)) && target(server);
	// Performing checks before and after running a process.
	pointcut serverProcessChecks(Server server) : call (* Server.process(..)) && target(server);
	// Checking whether total process time has exceeded 3 seconds
	
	after() : checkServerStopBeforeExit () {
		for (Map.Entry<Integer, Boolean> entry : serverStateMap.entrySet()) {			
			// If the server is running even after main method has returned, then it violates property 1.
			if (entry.getValue()) {
				try {
					throw new ServerException("[SEVERE] Server RUNNING forever : Server ID " + entry.getKey());
				} catch (ServerException e) {
					e.printStackTrace();
				}
			}
		}
	}
	
	Object around(Server server) : serverStartChecks (server) {
		// If the server is starting for the first time, then we can simply start the server.
		if (!serverStateMap.containsKey(server.getServerId())) {
			// Server state is running.
			serverStateMap.put(server.getServerId(), true);
		}
		// If the server is currently not running, then we can simply start the server.
		else if (!serverStateMap.get(server.getServerId())) {
			// Server state is running.
			serverStateMap.put(server.getServerId(), true);
		}
		// If the server is already running and we again try to start the server, then it violates property 4.
		else if (serverStateMap.get(server.getServerId())) {
			try {
				throw new ServerException("[SEVERE] Server already RUNNING : Server ID " + server.getServerId());
			} catch (ServerException e) {
				e.printStackTrace();
			}
			return null;
		}
		return proceed(server);
	}
	
	Object around (Server server) : serverStopChecks (server) {
		// If the server is being stopped before even being created, then it is a violation of property 2.
		if (!serverStateMap.containsKey(server.getServerId())) {
			try {
				throw new ServerException("[SEVERE] Attempt to STOP a NON-RUNNING server : Server ID " 
						+ server.getServerId());
			} catch (ServerException e) {
				e.printStackTrace();
			}
			return null;
		}
		// If the server is running, then just stop the server.
		else if (serverStateMap.get(server.getServerId())) {
			serverStateMap.put(server.getServerId(), false);
		}
		return proceed(server);
	}
	
	Object around (Server server) : serverProcessChecks (server) {
		// If the server does not exist, then we cannot run a process on the server.
		if (!serverStateMap.containsKey(server.getServerId())) {
			try {
				throw new ServerException("[SEVERE] Attempt to run a process on a NON-RUNNING server : Server ID " 
						+ server.getServerId());
			} catch (ServerException e) {
				e.printStackTrace();
			}
		}
		// If the server is not running, then we cannot run a process on the server.
		else if (!serverStateMap.get(server.getServerId())) {
			try {
				throw new ServerException("[SEVERE] Attempt to run a process on a NON-RUNNING server : Server ID " 
						+ server.getServerId());
			} catch (ServerException e) {
				e.printStackTrace();
			}
		}
		else {
			return proceed(server);
		}
		
		return null;
	}
	
	after (Server server) : serverProcessChecks (server) {
		// Check if the server processing time has exceeded 3 seconds.
		if (server.getTime() > 3) {
			try {
				throw new ServerException("[SEVERE] Server processing time has "
						+ "exceeded 3 seconds : Server ID " + server.getServerId());
			} catch (ServerException e) {
				e.printStackTrace();
			}
		}
	}
}