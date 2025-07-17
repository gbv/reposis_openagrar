package org.mycore;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.jdom2.Element;
import org.apache.solr.client.solrj.SolrClient;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.content.transformer.MCRContentTransformerFactory;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.servlets.MCRContentServlet;
import org.mycore.solr.MCRSolrClientFactory;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * @author Marianna Muehlhoelzer
 *
 */

public class MCRDCATDEServlet extends MCRContentServlet {

    private static final String SOLR_QUERY = MCRConfiguration2.getString("MIR.DCATCatalog.solr_query")
            .orElse("*");

    // DCATDE Catalog properties
    private final String TITLE_DE = MCRConfiguration2.getString("MCR.DCATCatalog.title_de")
            .orElse("MyCoRe Forschungsdaten");
    private final String TITLE_EN = MCRConfiguration2.getString("MCR.DCATCatalog.title_en")
            .orElse("MyCoRe Research Data");
    private final String DESCRIPTION_DE = MCRConfiguration2.getString("MCR.DCATCatalog.description_de")
            .orElse("Open Data Katalog des MyCoRe Repositoriums");
    private final String DESCRIPTION_EN = MCRConfiguration2.getString("MCR.DCATCatalog.description_en")
            .orElse("Open Data Catalog of MyCoRe Repository");
    private final String HOMEPAGE = MCRConfiguration2.getString("MCR.DCATCatalog.homepage")
            .orElse("https://www.mycore.de/");
    private final List<String> LANGUAGES = MCRConfiguration2.getString("MCR.DCATCatalog.language_list")
            .stream()
            .flatMap(MCRConfiguration2::splitValue)
            .collect(Collectors.toList());
    private final String PUBLISHER = MCRConfiguration2.getString("MCR.DCATCatalog.publisher")
            .orElse("MyCoRe Repositorium");
    private final String PUBLISHER_ROR = MCRConfiguration2.getString("MCR.DCATCatalog.publisher_ror")
        .orElse("NONE");
    private final String THEME = MCRConfiguration2.getString("MCR.DCATCatalog.theme")
            .orElse("NONE");
    private final String CONTRIBUTOR = MCRConfiguration2.getString("MCR.DCATCatalog.contributorID")
            .orElse("NONE");

    private static final Logger LOGGER = LogManager.getLogger();

    @Override
    public MCRContent getContent(HttpServletRequest httpServletRequest,
                                 HttpServletResponse httpServletResponse) throws IOException {

        Element root = new Element("dcatcollection");

        Element titleDE = new Element("title").setAttribute("lang", "de");
        titleDE.setText(TITLE_DE);
        root.addContent(titleDE);

        Element titleEN = new Element("title").setAttribute("lang", "en");
        titleEN.setText(TITLE_EN);
        root.addContent(titleEN);

        Element descriptionDE = new Element("beschreibung").setAttribute("lang", "de");
        descriptionDE.setText(DESCRIPTION_DE);
        root.addContent(descriptionDE);

        Element descriptionEN = new Element("description").setAttribute("lang", "en");
        descriptionEN.setText(DESCRIPTION_EN);
        root.addContent(descriptionEN);

        root.addContent(new Element("publisher").setText(PUBLISHER));
        root.addContent(new Element("publisher_ror").setText(PUBLISHER_ROR));
        root.addContent(new Element("homepage").setText(HOMEPAGE));
        root.addContent(new Element("theme").setText(THEME));
	    root.addContent(new Element("contributor").setText(CONTRIBUTOR));

        for (String lang : LANGUAGES) {
            root.addContent(new Element("language").setText(lang));
        }

        for (MCRObjectID id : getIdList(httpServletRequest)) {

            MCRObject content = MCRMetadataManager.
                    retrieveMCRObject(id);

            root.addContent(content.createXML().detachRootElement());

        }
        MCRJDOMContent mcrdata = new MCRJDOMContent(root);
        return MCRContentTransformerFactory.getTransformer("dcatcollection").transform(mcrdata);
    }



    private List<MCRObjectID> getIdList(HttpServletRequest request){
        List<MCRObjectID> idList = new ArrayList<>();
        Integer start = request.getParameter("start") == null ? 0 : Integer.parseInt(request.getParameter("start"));
        Integer rows = request.getParameter("rows") == null ? 100 : Integer.parseInt(request.getParameter("rows"));

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

