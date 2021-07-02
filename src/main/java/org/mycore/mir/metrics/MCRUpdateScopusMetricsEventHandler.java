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
import org.mycore.datamodel.metadata.MCRObjectService;
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
    
    public static void setValues(Element MetricList, Element journalMetrics, String MetricName) {
    	XPathFactory xFactory = XPathFactory.instance();
    	Element metric;
    	XPathExpression<Element> xPathMetric = xFactory.compile("metric[@type='" + MetricName + "']", Filters.element(),
      			 null, MCRConstants.MODS_NAMESPACE);
    	List<Element> metrics = xPathMetric.evaluate(journalMetrics);
    	if (metrics.isEmpty()) {
    		metric = new Element("metric");
            metric.setAttribute("type", MetricName);
            journalMetrics.addContent(metric);
    	} else {
    		metric = (Element) metrics.get(0);
    	}
    	
        for (Element SNIP : MetricList.getChildren()) {
        	String value = SNIP.getText();
        	String year = SNIP.getAttributeValue("year");
            LOGGER.debug("Found " + MetricName + ": {} ({}) ",value,year);
        	XPathExpression<Element> xPathValue = xFactory.compile("value[@year='" + year + "']", Filters.element(),
         			 null, MCRConstants.MODS_NAMESPACE);
       	    List<Element> valueNodes = xPathValue.evaluate(metric);
       	    if (valueNodes.isEmpty()) {
       	    	Element node = new Element("value");
                node.setAttribute("year",year);
                node.setText(value);
                metric.addContent(node);
       	    } else {
       	    	for(Element node : valueNodes){
       	    		node.setText(value);
       	    	}
       	    }
        }
    }
        
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
        		LOGGER.debug("Found ISSN in {}, issn={}", obj.getId(), issn);
        		String str = "https://api.elsevier.com/content/serial/title?"
            	    	+ "field=SJR,SNIP&view=STANDARD&apiKey=b59e9c2e9550f905bf3dfeabd0ae2c71"
            		    + "&httpAccept=text/xml&issn=" + issn;
        		LOGGER.info("Get SNIP, SJR from Scopus API: {}", str);
        		try {
        			URL url = new URL(str);
                    HttpURLConnection conn = null;
                    
        			conn = (HttpURLConnection) url.openConnection();
                    int response = conn.getResponseCode();
                    if (response == 200) {
                    	StringBuilder stringBuilder = new StringBuilder();
                    	try {
                    		SAXBuilder saxBuilder = new SAXBuilder();
                	        Document document = saxBuilder.build(conn.getInputStream());
                	        Element root = document.getRootElement();
                	        LOGGER.debug("received xml from source: "+outp.outputString(root));
                	        
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
                            	setValues(SNIPList,journalMetrics,"SNIP");
                            }
                            if (SJRList != null) {
                            	setValues(SJRList,journalMetrics,"SJR");
                            }
                            if (SNIPList != null || SJRList != null) {
                                obj.getService().setDate(MCRObjectService.DATE_TYPE_MODIFYDATE);
                            }
                        
                    	} catch (org.jdom2.JDOMException e) {
                    		LOGGER.info("JDOMException - didn't add Scopus Metrics");
                    		LOGGER.info(e);
                    	}
                    } else if (response == 401 || response == 403) {
                    	LOGGER.error("Acces denied to the Scopus API - didn't add Scopus Metrics");
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
        
        
    }
    
}
