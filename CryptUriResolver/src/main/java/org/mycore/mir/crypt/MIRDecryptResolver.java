package org.mycore.mir.crypt;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.StringReader;
import java.net.MalformedURLException;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Content;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.jdom2.transform.JDOMSource;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import javax.crypto.KeyGenerator;
import javax.crypto.Cipher;
import java.security.GeneralSecurityException;
import java.security.NoSuchAlgorithmException;
import java.security.InvalidKeyException;
import java.io.UnsupportedEncodingException;

import org.mycore.common.MCRConstants;
import org.mycore.datamodel.common.MCRDataURL;



public class MIRDecryptResolver implements URIResolver {

    public static final String XML_PREFIX = "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
    
    private static final Logger LOGGER = LogManager.getLogger(MIRDecryptResolver.class);

    @Override
    public Source resolve(String s, String s1) throws TransformerException {
        final String value = s.substring("decrypt:".length());
        
        String encodedKey = "FwoNZoiScGvNDCIlSt8/7A=="; 
        String decryptedString = "";
        
        try {
        	byte[] decodedKey = java.util.Base64.getDecoder().decode(encodedKey);
            SecretKey secretKey = new SecretKeySpec(decodedKey, 0, decodedKey.length, "AES"); 
        	Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5PADDING");
        	cipher.init(Cipher.DECRYPT_MODE, secretKey);
        	byte[] encryptedBytes = java.util.Base64.getDecoder().decode(value);
        	byte[] utf8Bytes = cipher.doFinal(encryptedBytes);
	        decryptedString = new String(utf8Bytes, "UTF8");
	        LOGGER.info("DecyptedString: {}", decryptedString );
        } catch (java.lang.IllegalArgumentException e) {
        	decryptedString = value;
        	LOGGER.info("catch java.lang.IllegalArgumentException - i.e. value not encoded - return orignal value: {}", decryptedString );
    	} catch ( NoSuchAlgorithmException | InvalidKeyException | UnsupportedEncodingException e) {
    		throw new TransformerException("Error while building document!", e);
    	} catch ( GeneralSecurityException e) {
    		throw new TransformerException("Error while building document!", e);
    	}
        final Element root = new Element("value");
        root.setText(decryptedString);
        
        return new JDOMSource(root);
    }

}
