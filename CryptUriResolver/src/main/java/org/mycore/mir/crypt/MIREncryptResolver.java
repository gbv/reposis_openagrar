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

public class MIREncryptResolver implements URIResolver {

    public static final String XML_PREFIX = "<?xml version=\"1.0\" encoding=\"utf-8\"?>";
    
    private static final Logger LOGGER = LogManager.getLogger(MIRDecryptResolver.class);

    @Override
    public Source resolve(String s, String s1) throws TransformerException {
        final String value = s.substring("decrypt:".length());
        
        String encryptedString = "";
        String encodedKey = "FwoNZoiScGvNDCIlSt8/7A==";
        
        try {
        	// Implement Key Generation
        	SecretKey tmpSecretKey = KeyGenerator.getInstance("AES").generateKey();
        	String tmpEncodedKey = java.util.Base64.getEncoder().encodeToString(tmpSecretKey.getEncoded());
            LOGGER.info("Temporaly Secret Key: {}", tmpEncodedKey );
            
            byte[] decodedKey = java.util.Base64.getDecoder().decode(encodedKey);
            SecretKey secretKey = new SecretKeySpec(decodedKey, 0, decodedKey.length, "AES"); 
	        Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5PADDING");
	        cipher.init(Cipher.ENCRYPT_MODE, secretKey);
	        byte[] utf8Bytes = value.getBytes("UTF8");
	        byte[] encryptedBytes = cipher.doFinal(utf8Bytes);
	        encryptedString = java.util.Base64.getEncoder().encodeToString(encryptedBytes);
	        LOGGER.info("EncyptedString: {}", encryptedString );
    	} catch ( NoSuchAlgorithmException | InvalidKeyException | UnsupportedEncodingException e) {
    		throw new TransformerException("Error while building document!", e);
    	} catch ( GeneralSecurityException e) {
    		throw new TransformerException("Error while building document!", e);
    	}
        final Element root = new Element("value");
        root.setText(encryptedString);
        
        return new JDOMSource(root);
    }
    
}