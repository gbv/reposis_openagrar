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


import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Content;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.filter.Filters;
import org.jdom2.output.XMLOutputter;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;

import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;

import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.lang.StringBuilder;

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

    private final static Logger LOGGER = LogManager.getLogger(MCRUpdateScopusMetricsEventHandler.class);
        
    private void updateScopusMetrics(MCRObject obj) {
    	    	
		XMLOutputter outp = new XMLOutputter();
    	if (!MCRMODSWrapper.isSupported(obj)) {
            return;
        }
    	MCRMODSWrapper mcrmodsWrapper = new MCRMODSWrapper(obj);
        Element mods = mcrmodsWrapper.getMODS();
        
        XPathFactory xFactory = XPathFactory.instance();
        XPathExpression<Element> xPathModsExtension = xFactory.compile("mods:extension[@displayLabel='metrics']", Filters.element(),
    			 null, MCRConstants.MODS_NAMESPACE);
        XPathExpression<Element> xPathSnipMetric = xFactory.compile("metric[@type='SNIP']", Filters.element(),
   			 null, MCRConstants.MODS_NAMESPACE);
        XPathExpression<Element> xPathSjrMetric = xFactory.compile("metric[@type='SJR']", Filters.element(),
   			 null, MCRConstants.MODS_NAMESPACE);
    	
        List<Element> extensions = xPathModsExtension.evaluate(mods);
    	Element modsExtension;
    	if (extensions.size() == 0) {
    		modsExtension = new Element ("extension", MCRConstants.MODS_NAMESPACE);
    		modsExtension.setAttribute("displayLabel","metrics");
    		mods.addContent(modsExtension);
    	} else {
    		modsExtension = extensions.get(0);
    	}
        
        for (Element identifier : mods.getChildren("identifier", MCRConstants.MODS_NAMESPACE)) {
        	String type = identifier.getAttributeValue("type");
        	if (type.equals("issn")) {
        		String issn = identifier.getText();
        		LOGGER.info("Found ISSN in {}, issn={}", obj.getId(), issn);
        		String str = "https://api.elsevier.com/content/serial/title?"
            	    	+ "field=SJR,SNIP&view=STANDARD&apiKey=b59e9c2e9550f905bf3dfeabd0ae2c71"
            		    + "&httpAccept=text/xml&issn=" + issn;
                
        		try {
        			URL url = new URL(str);
                    HttpURLConnection conn = null;
                    
        			conn = (HttpURLConnection) url.openConnection();
                    int response = conn.getResponseCode();
                    if (response == 200) {
                    	StringBuilder stringBuilder = new StringBuilder();
                    	try {
                    		conn = (HttpURLConnection) url.openConnection();
                	        SAXBuilder saxBuilder = new SAXBuilder();
                	        Document document = saxBuilder.build(conn.getInputStream());
                	        Element root = document.getRootElement();
                	        LOGGER.info("received xml from source: "+outp.outputString(root));
                	        
                	        if ( root.getChild("error") != null) {
                	        	LOGGER.info("Error from Scopus API:" + root.getChild("error").getText());
                	        	continue;
                	        }
                            Element entry = root.getChild("entry");
                            if ( entry.getChild("SNIPList") == null && entry.getChild("SJRList") == null ) {
                                LOGGER.info("No SNIP or SJR Metrics for " + issn );
                	            continue;
                            }
                            Element SNIPList = entry.getChild("SNIPList");
                            Element SJRList = entry.getChild("SJRList");
                            
                            Element journalMetrics;
                            if (modsExtension.getChild("journalMetrics") != null) { 
                            	journalMetrics = modsExtension.getChild("journalMetrics");
                            } else {
                            	journalMetrics=new Element ("journalMetrics");
                         	    modsExtension.addContent(journalMetrics);
                            }
                            
                            
                            if (SNIPList != null) {
                            	List<Element> snipMetrics = xPathSnipMetric.evaluate(journalMetrics);
                            	for (Element snipMetric2 : snipMetrics) {
                            		snipMetric2.detach();
                            	}
                            	Element snipMetric = new Element("metric");
                                snipMetric.setAttribute("type","SNIP");
                                
                                Element snipValue;
                                for (Element SNIP : SNIPList.getChildren()) {
                                    LOGGER.info("Found SNIP: {} ({}) ",SNIP.getText(),SNIP.getAttributeValue("year"));
                                    snipValue = new Element("value");
                                    snipValue.setAttribute("year",SNIP.getAttributeValue("year"));
                                    snipValue.setText(SNIP.getText());
                                    snipMetric.addContent(snipValue);
                                }
                                if (snipMetric.getChildren().size() > 0) journalMetrics.addContent(snipMetric);
                            }
                            if (SJRList != null) {
                                List<Element> sjrMetrics = xPathSjrMetric.evaluate(journalMetrics);
                                for (Element sjrMetric2 : sjrMetrics) {
                            		sjrMetric2.detach();
                            	}
                                Element sjrMetric = new Element("metric");
                                sjrMetric.setAttribute("type","SJR");
                                
                                Element sjrValue;
                                for (Element SJR:SJRList.getChildren()) {
                                    LOGGER.info("Found SJR: {} ({}) ",SJR.getText(),SJR.getAttributeValue("year"));
                                    sjrValue = new Element("value");
                                    sjrValue.setAttribute("year",SJR.getAttributeValue("year"));
                                    sjrValue.setText(SJR.getText());
                                    sjrMetric.addContent(sjrValue);                                
                                }
                                if (sjrMetric.getChildren().size() > 0) journalMetrics.addContent(sjrMetric);
                            }
                            
                        
                    	} catch (org.jdom2.JDOMException e) {
                    		LOGGER.info("JDOMException - didn't add Scopus Metrics");
                    		LOGGER.info(e);
                    	}
                    } else {
                	    LOGGER.info("No 200 Response from ScopusAPI - didn't add Scopus Metrics");
                    }
        		} catch (MalformedURLException e) {
            		LOGGER.info("MalformedURLException - didn't add Scopus Metrics");
            		LOGGER.info(e);
            	} catch (IOException e) {
            		LOGGER.info("IOException - didn't add Scopus Metrics");
            		LOGGER.info(e);
            	}                 
        	}
        }
        
        mcrmodsWrapper.setMODS(mods);
    }
    
}
