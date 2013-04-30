package com.SecureDMZ;
import org.simpleframework.xml.*;

@Root
public class Server {
	@Attribute
	public String ServerName;
	@Element
	public String IP;
	@Element
	public String UUID; 
	@Element
	public String Port;
	//@Element
	//public CertificateInfo SecuritySettings;
}
