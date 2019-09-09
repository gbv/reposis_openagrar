/*
 * $Id$
 * $Revision: 34897 $ $Date: 2016-03-18 17:14:12 +0100 (Fr, 18 Mär 2016) $
 *
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * This program is free software; you can use it, redistribute it
 * and / or modify it under the terms of the GNU General Public License
 * (GPL) as published by the Free Software Foundation; either version 2
 * of the License or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program, in a file called gpl.txt or license.txt.
 * If not, write to the Free Software Foundation Inc.,
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
 */

package org.mycore.mir.metrics;

import java.util.List;

import org.apache.log4j.Logger;
import org.jdom2.Content;
import org.jdom2.Element;
import org.jdom2.output.XMLOutputter;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRException;
import org.mycore.common.MCRPersistenceException;
import org.mycore.common.events.MCREvent;
import org.mycore.common.events.MCREventHandlerBase;
import org.mycore.datamodel.metadata.MCRMetaLinkID;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mods.MCRMODSWrapper;

import org.mycore.common.xml.MCRURIResolver;
import org.mycore.datamodel.common.MCRISO8601Date;
import org.mycore.datamodel.metadata.MCRMetaElement;
import org.mycore.datamodel.metadata.MCRMetaXML;




/**
 * 
 * update the mods
 *
 * @author Paul Borchert
 */
public class MCRUpdateScopusMetricsEventHandler extends MCREventHandlerBase {

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectCreated(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectCreated(final MCREvent evt, final MCRObject obj) {
    	updateScopusMetrics(obj);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectUpdated(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectUpdated(final MCREvent evt, final MCRObject obj) {
    	updateScopusMetrics(obj);
    }

    /* (non-Javadoc)
     * @see org.mycore.common.events.MCREventHandlerBase#handleObjectRepaired(org.mycore.common.events.MCREvent, org.mycore.datamodel.metadata.MCRObject)
     */
    @Override
    protected void handleObjectRepaired(final MCREvent evt, final MCRObject obj) {
    	updateScopusMetrics(obj);
    }

    private final static Logger LOGGER = Logger.getLogger(MCRUpdateScopusMetricsEventHandler.class);

    
    private void ScopusMetrics(MCRObject obj) {
    	    	
		//XMLOutputter outp = new XMLOutputter();
    	if (!MCRMODSWrapper.isSupported(object)) {
            return;
        }

        Element mods = new MCRMODSWrapper(object).getMODS();
        
        for (Element identifier : mods.getChildren("identifier", MCRConstants.MODS_NAMESPACE)) {
        	String type = relatedItem.getAttributeValue("type");
        	if (type.equals('issn')) {
        		LOGGER.info("Found ISSN in {}, issn={}", object.getId(), issn);
        	}
        }
    }
    
}
