package org.mycore.pi.doi;

import java.util.Date;
import java.util.Locale;
import java.util.Optional;

import org.mycore.common.MCRPersistenceException;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.datamodel.common.MCRISO8601Date;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.pi.MCRPersistentIdentifier;
import org.mycore.pi.MCRPersistentIdentifierGenerator;
import org.mycore.pi.exceptions.MCRPersistentIdentifierException;

//public class MCRCreateDateDOIGenerator2 extends MCRPersistentIdentifierGenerator<MCRDigitalObjectIdentifier> {
public class MCRCreateDateDOIGeneratorTI implements MCRPersistentIdentifierGenerator<MCRDigitalObjectIdentifier> {

    private String datePattern = "yyyyMMdd-HHmmss";

    private final MCRDOIParser mcrdoiParser;

    private String prefix = "10.3220/DATA";
    
    private String subPrefix = "";

    public MCRCreateDateDOIGeneratorTI() {
        //super(generatorID);
        
        mcrdoiParser = new MCRDOIParser();
        
    }

    @Override
    public MCRDigitalObjectIdentifier  generate(MCRObjectID mcrID, String additional)
        throws MCRPersistentIdentifierException {
        Date createdate = MCRMetadataManager.retrieveMCRObject(mcrID).getService().getDate("createdate");
        if (createdate != null) {
            MCRISO8601Date mcrdate = new MCRISO8601Date();
            mcrdate.setDate(createdate);
            String format = mcrdate.format(datePattern, Locale.ENGLISH);
            String identifier = (prefix.contains("/")) ? prefix + format : prefix + "/" + format ;
            //Optional<MCRDigitalObjectIdentifier> parse = mcrdoiParser.parse(identifier);
            Optional<MCRPersistentIdentifier> parse = mcrdoiParser.parse(identifier);
            MCRPersistentIdentifier doi = parse.get();
            return (MCRDigitalObjectIdentifier) doi;
        } else {
            throw new MCRPersistenceException("The object " + mcrID.toString() + " doesn't have a createdate!");
        }
    }
}
