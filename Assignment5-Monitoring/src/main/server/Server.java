package main.server;

import java.util.Random;

public class Server {
	int serverId;
	int time;
	
	public Server () {
		this.serverId = IdIssuer.getServerId();
		this.time = 0;
	}
	
	public void start () {
		// Server is running.
		System.out.println("Server " + this.getServerId() + " : starting");
		// Server is yet to process requests, so set time equals to zero.
		this.time = 0;
	}
	
	public void stop () {
		// Server is stopped, i.e, not running.
		System.out.println("Server " + this.getServerId() + " : stopping");
		// Server cannot process requests, so set time equals to zero.
		this.time = 0;
	}
	
	public void process () throws InterruptedException {
		// Execute the process.
		Random r = new Random();
		int processTime = r.nextInt(5);
		System.out.println("Server " + this.getServerId() +" : Process will run for " + processTime + " sec");
		time = time + processTime;
		if(time <= 3) {
			System.out.println("Server " + this.getServerId() + " : processing");
			Thread.sleep(processTime*1000);
		}
	}
	
	public int getServerId () {
		return this.serverId;
	}
	
	public int getTime () {
		return time;
	}
}