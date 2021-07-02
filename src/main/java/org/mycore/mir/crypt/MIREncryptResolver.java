package org.mycore.mir.crypt;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.jdom2.transform.JDOMSource;
import org.mycore.access.MCRAccessManager;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.config.MCRConfigurationException;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

public class MIREncryptResolver implements URIResolver {

    private static final Logger LOGGER = LogManager.getLogger(MIRDecryptResolver.class);

    @Override
    public Source resolve(String s, String s1) throws TransformerException {
        String s2 = s.substring("decrypt:".length());
        final String keyID = s2.contains(":") ? s2.substring(0,s2.indexOf(":")) : "key1";
        final String value = s2.contains(":") ? s2.substring(s2.indexOf(":") + 1) : s2;
        
        //String encodedKey = "FwoNZoiScGvNDCIlSt8/7A=="; 
        String encryptedString = "";
        
        try {
        	// Implement Key Generation
        	SecretKey tmpSecretKey = KeyGenerator.getInstance("AES").generateKey();
        	String tmpEncodedKey = java.util.Base64.getEncoder().encodeToString(tmpSecretKey.getEncoded());
            LOGGER.info("Temporaly Secret Key: {}", tmpEncodedKey );
            
            if (MCRAccessManager.checkPermission("key:" + keyID , "encrypt" )) {
            	String encodedKey = MCRConfiguration2.getStringOrThrow("MCR.URIResolver.Keys." + keyID);
	            byte[] decodedKey = java.util.Base64.getDecoder().decode(encodedKey);
	            SecretKey secretKey = new SecretKeySpec(decodedKey, 0, decodedKey.length, "AES"); 
		        Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5PADDING");
		        cipher.init(Cipher.ENCRYPT_MODE, secretKey);
		        byte[] utf8Bytes = value.getBytes("UTF8");
		        byte[] encryptedBytes = cipher.doFinal(utf8Bytes);
		        encryptedString = java.util.Base64.getEncoder().encodeToString(encryptedBytes);
		        LOGGER.info("EncyptedString: {}", encryptedString );
            } else {
            	throw new TransformerException("No Permission in ACL to encrypt with the key(" + keyID + ")");
            }
        } catch (MCRConfigurationException e) {
            throw new TransformerException("Can't encrypt value - missed key (" + keyID + ") in properties.", e);
        } catch ( NoSuchAlgorithmException | InvalidKeyException | UnsupportedEncodingException e) {
    		throw new TransformerException("Can't encrypt value - wrong configuration", e);
    	} catch ( GeneralSecurityException e) {
    		throw new TransformerException("Can't encrypt value.", e);
    	}
        final Element root = new Element("value");
        root.setText(encryptedString);
        
        return new JDOMSource(root);
    }
    
}