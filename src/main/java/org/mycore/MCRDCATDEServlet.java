package org.mycore;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.apache.solr.client.solrj.SolrClient;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;
import org.mycore.common.MCRException;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.xml.MCRLayoutService;

import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.servlets.MCRContentServlet;
import org.mycore.solr.MCRSolrClientFactory;
import org.jdom2.Element;
import org.xml.sax.SAXException;
import javax.xml.transform.TransformerException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * @author Marianna Muehlhoelzer
 *
 */

public class MCRDCATDEServlet extends MCRContentServlet {

    private static final String SOLR_QUERY = MCRConfiguration2.getString("MIR.DCATCatalog.solr_query").orElse("*");
    // private static final String SOLR_QUERY = "*";
    private static final Logger LOGGER = LogManager.getLogger();

    @Override
    public MCRContent getContent(HttpServletRequest httpServletRequest,
                                 HttpServletResponse httpServletResponse) throws IOException {

        Element root = new Element("dcatcollection");

        for (MCRObjectID id : getIdList(httpServletRequest)) {
            // Build content with all mycoreobjects wrapped in dcatcolletion-node as root

            MCRObject content = MCRMetadataManager.
                    retrieveMCRObject(id);

            root.addContent(content.createXML().detachRootElement());

        }
        MCRJDOMContent mcrdata = new MCRJDOMContent(root);

        MCRLayoutService layoutService = new MCRLayoutService();

        try {
            return layoutService.instance().getTransformedContent(httpServletRequest, httpServletResponse, mcrdata);
        } catch (final SAXException | TransformerException | IOException e) {
            throw new MCRException("Exception while transforming MCRContent to DCATDECatalog.", e);
        }

    }



    private List<MCRObjectID> getIdList(HttpServletRequest request){
        List<MCRObjectID> idList = new ArrayList<>();
        Integer start = request.getParameter("start") == null ? 0 : Integer.parseInt(request.getParameter("start"));
        Integer rows = request.getParameter("rows") == null ? 10 : Integer.parseInt(request.getParameter("rows"));

        SolrQuery query = new SolrQuery();
        query.setQuery(SOLR_QUERY);
        query.setStart(start);
        query.setRows(rows);
        SolrClient solrClient = MCRSolrClientFactory.getMainSolrClient();

        try {
            QueryResponse solrResponse = solrClient.query(query);
            SolrDocumentList docs = solrResponse.getResults();

            for (SolrDocument doc : docs) {
                MCRObjectID objectID = MCRObjectID.getInstance(doc.getFieldValue("id").toString());
                idList.add(objectID);
            }
        } catch (Exception exc) {
            // Skip invalid IDs
            LOGGER.info(exc);
        }
        return idList;

    }


}

