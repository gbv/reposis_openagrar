package org.mycore.pi.doi;

import java.io.IOException;
import java.net.URL;
import java.util.List;
import java.util.Map;

import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.filter.Filters;
import org.jdom2.transform.JDOMSource;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.mycore.common.config.MCRConfigurationException;
import org.mycore.common.content.MCRBaseContent;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.transformer.MCRContentTransformer;
import org.mycore.common.content.transformer.MCRContentTransformerFactory;
import org.mycore.common.content.transformer.MCRParameterizedTransformer;
import org.mycore.common.xsl.MCRParameterCollector;
import org.mycore.datamodel.metadata.MCRBase;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.pi.exceptions.MCRPersistentIdentifierException;
import org.mycore.services.i18n.MCRTranslation;
import org.xml.sax.SAXException;

/**
 * Replace this class with standard class in LTS 2019
 */
public class MCRParameteredDOIRegistrationService extends MCRDOIService {


    public MCRParameteredDOIRegistrationService(String serviceID) {
        super(serviceID);
    }

    private void insertDOI(Document datacite, MCRDigitalObjectIdentifier doi) throws MCRPersistentIdentifierException {
        Namespace namespace = Namespace.getNamespace("datacite", getProperties().getOrDefault("Namespace", "http://datacite.org/schema/kernel-3"));;
        XPathExpression<Element> compile = XPathFactory
            .instance().compile("//datacite:identifier[@identifierType='DOI']", Filters
                .element(), (Map)null, new Namespace[]{namespace});
        List<Element> doiList = compile.evaluate(datacite);
        if (doiList.size() > 1) {
            throw new MCRPersistentIdentifierException("There is more then one identifier with type DOI!");
        } else {
            Element doiElement;
            if (doiList.size() == 1) {
                doiElement = (Element)doiList.stream().findAny().get();
                doiElement.setText(doi.asString());
            } else {
                doiElement = new Element("identifier", namespace);
                datacite.getRootElement().addContent(doiElement);
                doiElement.setAttribute("identifierType", "DOI");
                doiElement.setText(doi.asString());
            }

        }
    }

    @Override
    protected Document transformToDatacite(MCRDigitalObjectIdentifier doi, MCRBase mcrBase)
        throws MCRPersistentIdentifierException {
        MCRObjectID id = mcrBase.getId();
        MCRBaseContent content = new MCRBaseContent(mcrBase);

        String transformerId = getProperties().get("Transformer");
        try {
            MCRContent transform;
            MCRContentTransformer transformer = MCRContentTransformerFactory.getTransformer(transformerId);
            if (transformer instanceof MCRParameterizedTransformer) {
                final MCRParameterCollector parameterCollector = new MCRParameterCollector(true);
                parameterCollector.setParameter("serviceId", getServiceID());
                getProperties().forEach(parameterCollector::setParameter);
                transform = ((MCRParameterizedTransformer) transformer).transform(content, parameterCollector);
            } else {
                transform = transformer.transform(content);
            }
            Document dataciteDocument = transform.asXML();
            this.insertDOI(dataciteDocument, doi);
            Schema dataciteSchema = this.loadDataciteSchema();

            try {
                dataciteSchema.newValidator().validate(new JDOMSource(dataciteDocument));
            } catch (SAXException var10) {
                String translatedInformation = MCRTranslation.translate("component.pi.register.error.4098");
                throw new MCRPersistentIdentifierException("The document " + id + " does not generate well formed Datacite!", translatedInformation, 4098, var10);
            }

            return dataciteDocument;
        } catch (JDOMException | SAXException | IOException var11) {
            throw new MCRPersistentIdentifierException("Could not transform the content of " + id + " with the transformer " + getProperties().get("Transformer"), var11);
        }
    }

    private Schema loadDataciteSchema() {
        final String schemaPath = getProperties().getOrDefault("Schema", "xsd/datacite/v3/metadata.xsd");

        try {
            SchemaFactory schemaFactory = SchemaFactory.newInstance("http://www.w3.org/2001/XMLSchema");
            schemaFactory.setFeature("http://apache.org/xml/features/validation/schema-full-checking", false);
            URL localSchemaURL = MCRDOIService.class.getClassLoader().getResource(schemaPath);
            if (localSchemaURL == null) {
                throw new MCRConfigurationException(
                    schemaPath + " was not found!");
            } else {
                return schemaFactory.newSchema(localSchemaURL);
            }
        } catch (SAXException var3) {
            throw new MCRConfigurationException("Error while loading datacite schema!", var3);
        }
    }
}
