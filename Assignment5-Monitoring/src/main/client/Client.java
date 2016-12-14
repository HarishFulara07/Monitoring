package main.client;

import main.server.Server;

// Client class that communicates with the server.
public class Client {
	public static void main(String[] args)
	{
		Server s = new Server();
		try {
			s.process();
			s.process();
			s.process();
			s.process();
			s.start();
			s.start();
			s.process();
			s.stop();
			s.process();
			s.stop();
			s.stop();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}
}