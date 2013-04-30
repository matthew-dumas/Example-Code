package com.dmz;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Scanner;

import com.SecureDMZ.ConfigFile;
import com.SecureDMZ.Server;
import com.SecureDMZ.localhost;

import org.simpleframework.xml.*;
import org.simpleframework.xml.core.Persister;


public class SecureDMZ {
	
	private ConfigFile config;
	private String Error = "";
	Serializer file = new Persister();
	private static final String CONF_LOCATION = "C:\\!\\CONFFILE_ENC.txt";
	
	
	public String runOperation(String uuid, String message) throws IOException {
		String output = "\n"+AddTabs(4)+"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";
		output += AddTabs(4) + "<DMZ_RESP>\r\n";
		localhost lh = new localhost();
		ByteArrayOutputStream baos = new ByteArrayOutputStream(); 
		
		
		Server a = new Server(); 
		a.IP = "127.0.0.79";
		a.Port = "50";
		a.ServerName = "Sillypup";
		a.UUID = "sfsdf-sdfdsfd";		
		
		
		try {
			file.write(a, baos);
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		output += baos.toString();
		
		if (LoadConfig()) {
			if (uuid.equals("00000-127001localhost-ZZZZZ")) {   // Give localhost command 
				try {
					lh = file.read(localhost.class, message);
				} catch (Exception e) {
					output += "<ERROR> Error thrown while reading message: "+e.getMessage() + "</ERROR>\r\n";
				}
				
				if (lh.command.toLowerCase().trim().equals("add server")){
					
					try {
						config.Servers.add(file.read(Server.class, lh.details));
					} catch (Exception e) {
						output += "<ERROR> Error adding server to list: " +e.getMessage() + "</ERROR>\r\n";
					}
				}
				
				try {
					file.write(config, baos);
					
					FileWriter fstream = new FileWriter("C:\\!\\CONFFILE_ENC.txt");
					BufferedWriter out = new BufferedWriter(fstream);
					out.write(ConfigFile.encrypt(baos.toString()));  
					out.close();
					
				} catch (IOException e) {
					output += "<ERROR> Error editing configuration file: " +e.getMessage() + "</ERROR>\r\n";
				} catch (Exception e) {
					output += "<ERROR> Error with streams: " +e.getMessage() + "</ERROR>\r\n";
				}

			} else {
		
				try {
					file.write(config,baos);  // Convert XML from SimpleXML to a Byte Array
					output += baos.toString() + "\r\n"; // Convert byte array to a string
				} catch (Exception e) {
					output += e.getMessage();
				}
			}
		}else {
			output += AddTabs(5) + "<ERROR>"+Error+"</ERROR>\r\n";
		}
	
		output += AddTabs(4) + "</DMZ_RESP>\r\n" + AddTabs(2);
		
		baos.reset();
		baos.close();
		
		return output;
	}
	
	private String AddTabs(int tabs) { 
		String out = ""; 
		while (tabs > 0) { 
			out += "\t";
			tabs--;
		}
		return out;
	}
	
	private boolean LoadConfig() {
		try {
			String configurations = new Scanner(new File("C:\\!\\CONFFILE.txt")).useDelimiter("\\Z").next();	
			
			config = file.read(ConfigFile.class, configurations);
					
			//String a = ConfigFile.decrypt(configurations);
			
			//config = file.read(ConfigFile.class, ConfigFile.decrypt(configurations));

			return true;
		} catch (Exception ex) {
			Error = ex.getMessage();
			return false;	
		}
	}
	
}

/*  ---- Encrypt file output ----
 * FileWriter fstream = new FileWriter("C:\\!\\CONFFILE_ENC.txt");
			  BufferedWriter out = new BufferedWriter(fstream);
			  out.write(ConfigFile.encrypt(configurations));
			  //Close the output stream
			  out.close();
			  
			  */
