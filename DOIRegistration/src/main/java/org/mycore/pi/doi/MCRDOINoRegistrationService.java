package org.mycore.pi.doi;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

import javax.xml.XMLConstants;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.filter.Filters;
import org.jdom2.transform.JDOMSource;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRException;
import org.mycore.common.MCRSessionMgr;
import org.mycore.common.MCRSystemUserInformation;
import org.mycore.common.content.MCRBaseContent;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.transformer.MCRContentTransformerFactory;
import org.mycore.common.xml.MCRXMLFunctions;
import org.mycore.datamodel.metadata.MCRBase;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.niofs.MCRContentTypes;
import org.mycore.datamodel.niofs.MCRPath;
import org.mycore.pi.MCRPIRegistrationService;
import org.mycore.pi.exceptions.MCRPersistentIdentifierException;
import org.mycore.services.i18n.MCRTranslation;
import org.xml.sax.SAXException;

import java.util.Date;

/**
 *
 */
public class MCRDOINoRegistrationService extends MCRPIRegistrationService<MCRDigitalObjectIdentifier> {

    public static final String TEST_PREFIX = "UseTestPrefix";

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String TYPE = "doi";

    /**
     * A media URL is longer then 255 chars
     */
    private static final int ERR_CODE_1_1 = 0x1001;

    /**
     * The datacite document is not valid
     */
    private static final int ERR_CODE_1_2 = 0x1002;

    private static final int MAX_URL_LENGTH = 255;

    private static final String TRANSLATE_PREFIX = "component.pi.register.error.";
    
    private String registerURL;

    private boolean useTestPrefix;

    public MCRDOINoRegistrationService(String serviceID) {
        super(serviceID, "doi");

        Map<String, String> properties = getProperties();
        useTestPrefix = properties.containsKey(TEST_PREFIX) && Boolean.valueOf(properties.get(TEST_PREFIX));
        this.registerURL = properties.get("RegisterBaseURL");
    }

    
    public boolean usesTestPrefix() {
        return useTestPrefix;
    }

    public String getRegisterURL() {
        return registerURL;
    }

    @Override
    public void validateRegistration(MCRBase obj, String additional)
        throws MCRPersistentIdentifierException, MCRAccessException {
        
        super.validateRegistration(obj, additional);
    }

    @Override
    public MCRDigitalObjectIdentifier registerIdentifier(MCRBase obj, String additional)
        throws MCRPersistentIdentifierException {
        if (!additional.equals("")) {
            throw new MCRPersistentIdentifierException(
                getClass().getName() + " doesn't support additional information! (" + additional + ")");
        }

        return getNewIdentifier(obj.getId(), additional);
        
    }

    
   

    
    @Override
    public void delete(MCRDigitalObjectIdentifier doi, MCRBase obj, String additional)
        throws MCRPersistentIdentifierException {
    	
    }

    @Override
    protected void update(MCRDigitalObjectIdentifier identifier, MCRBase obj, String additional)
        throws MCRPersistentIdentifierException {

    }

    /*@Override
    protected Date provideRegisterDate(MCRBase obj, String additional) {
        return null;
    }*/

}
