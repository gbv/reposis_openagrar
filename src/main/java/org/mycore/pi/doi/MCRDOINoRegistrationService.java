package org.mycore.pi.doi;

import org.mycore.access.MCRAccessException;
import org.mycore.datamodel.metadata.MCRBase;
import org.mycore.pi.MCRPIService;
import org.mycore.pi.doi.MCRDigitalObjectIdentifier;
import org.mycore.pi.exceptions.MCRPersistentIdentifierException;

public class MCRDOINoRegistrationService extends MCRPIService<MCRDigitalObjectIdentifier> {

    public MCRDOINoRegistrationService() {
        super("doi");
    }

    @Override
    public void validateRegistration(MCRBase obj, String additional)
        throws MCRPersistentIdentifierException, MCRAccessException {

        super.validateRegistration(obj, additional);
    }

    @Override
    public void registerIdentifier(MCRBase obj, String additional, MCRDigitalObjectIdentifier doi)
        throws MCRPersistentIdentifierException {
        if (!additional.equals("")) {
            throw new MCRPersistentIdentifierException(
                getClass().getName() + " doesn't support additional information! (" + additional + ")");
        }
    }



    @Override
    public void delete(MCRDigitalObjectIdentifier doi, MCRBase obj, String additional)
        throws MCRPersistentIdentifierException {

    }

    @Override
    protected void update(MCRDigitalObjectIdentifier identifier, MCRBase obj, String additional)
        throws MCRPersistentIdentifierException {

    }

}
