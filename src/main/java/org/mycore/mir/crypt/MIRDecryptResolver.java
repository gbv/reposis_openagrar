package org.mycore.mir.crypt;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.jdom2.transform.JDOMSource;
import org.mycore.access.MCRAccessManager;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.config.MCRConfigurationException;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;


public class MIRDecryptResolver implements URIResolver {

    private static final Logger LOGGER = LogManager.getLogger(MIRDecryptResolver.class);

    @Override
    public Source resolve(String s, String s1) throws TransformerException {
        String s2 = s.substring("decrypt:".length());
        final String keyID = s2.contains(":") ? s2.substring(0,s2.indexOf(":")) : "key1";
        final String value = s2.contains(":") ? s2.substring(s2.indexOf(":") + 1) : s2;
        
        //String encodedKey = "FwoNZoiScGvNDCIlSt8/7A=="; 
        String decryptedString = "";
        
        try {
        	if (MCRAccessManager.checkPermission("key:" + keyID , "decrypt" )) {
        		String encodedKey = MCRConfiguration2.getStringOrThrow("MCR.URIResolver.Keys." + keyID);
            	byte[] decodedKey = java.util.Base64.getDecoder().decode(encodedKey);
                SecretKey secretKey = new SecretKeySpec(decodedKey, 0, decodedKey.length, "AES"); 
            	Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5PADDING");
            	cipher.init(Cipher.DECRYPT_MODE, secretKey);
            	byte[] encryptedBytes = java.util.Base64.getDecoder().decode(value);
            	byte[] utf8Bytes = cipher.doFinal(encryptedBytes);
    	        decryptedString = new String(utf8Bytes, "UTF8");
    	        LOGGER.info("DecyptedString: {}", decryptedString );
        	} else {
        		LOGGER.info("No Permission in ACL to decrypt with the key(" + keyID + ") ");
        		decryptedString = value;
        	} 
        } catch (MCRConfigurationException e) {
            String msg = "Can't decrypt value - missed key (" + keyID + ") in properties.";
            LOGGER.info(msg, e);
            decryptedString = value;
        } catch (java.lang.IllegalArgumentException e) {
        	decryptedString = value;
        	LOGGER.info("catch java.lang.IllegalArgumentException - i.e. value not encoded - return orignal value: {}", decryptedString );
    	} catch ( NoSuchAlgorithmException | InvalidKeyException | UnsupportedEncodingException e) {
    		throw new TransformerException("Can't decrypt value - wrong configuration", e);
    	} catch ( GeneralSecurityException e) {
    		throw new TransformerException("Can't decrypt value.", e);
    	}
        final Element root = new Element("value");
        root.setText(decryptedString);
        
        return new JDOMSource(root);
    }

}
