package com.SecureDMZ;

import java.security.Key;
import java.util.List;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import com.SecureDMZ.Server;


import org.simpleframework.xml.*;

import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;


@Root
public class ConfigFile {
	@ElementList
	public List<Server> Servers;
	
	private static final String ALGORITHM = "AES";
	private static String m_key = "m#J$%kS(93jn$^lk"; // must be 16 characters until different algo used
	
	public static String encrypt(String Data) throws Exception {
        Key key = generateKey();
        Cipher c = Cipher.getInstance(ALGORITHM);
        c.init(Cipher.ENCRYPT_MODE,  key);
        byte[] encVal = c.doFinal(Data.getBytes());
        String encryptedValue = new BASE64Encoder().encode(encVal);
        return encryptedValue;
    }

    public static String decrypt(String encryptedData) throws Exception {
        Key key = generateKey();
        Cipher c = Cipher.getInstance(ALGORITHM);
        c.init(Cipher.DECRYPT_MODE, key);
        byte[] decordedValue = new BASE64Decoder().decodeBuffer(encryptedData);
        byte[] decValue = c.doFinal(decordedValue);
        String decryptedValue = new String(decValue);
        return decryptedValue;
    }
    private static Key generateKey() throws Exception {
    	Key key = new SecretKeySpec(m_key.getBytes(), ALGORITHM);
        return key;
    }

	
}




