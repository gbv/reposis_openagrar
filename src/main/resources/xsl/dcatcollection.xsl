<xsl:stylesheet version="2.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:org="http://www.w3.org/ns/org#"
                exclude-result-prefixes="mods xlink">


  <xsl:output method="xml" indent="yes" encoding="UTF-8" />

  <!-- URLs in use -->
  <!-- open Agrar URLs -->
  <xsl:variable name="OABaseURL">https://www.openagrar.de/</xsl:variable>
  <xsl:variable name="OAURL"><xsl:value-of select="concat($OABaseURL, 'receive/')" /></xsl:variable>
  <xsl:variable name="OAFileURL"><xsl:value-of select="concat($OABaseURL, 'servlets/MCRFileNodeServlet/')" /></xsl:variable>

  <!-- Identifier URLs -->
  <xsl:variable name="doiURL">https://doi.org/</xsl:variable>
  <xsl:variable name="orcidURL">https://orcid.org/</xsl:variable>
  <xsl:variable name="gndURL">https://d-nb.info/gnd/</xsl:variable>
  <xsl:variable name="viafURL">https://viaf.org/viaf/</xsl:variable>
  <xsl:variable name="scopusURL">https://???</xsl:variable>

  <!-- EU Vocabularies -->
  <xsl:variable name="dctLicenseURI">http://dcat-ap.de/def/licenses/</xsl:variable>
  <xsl:variable name="dctLanguageURI">http://publications.europa.eu/resource/authority/language/</xsl:variable>
  <xsl:variable name="dctFileType">http://publications.europa.eu/resource/authority/file-type/</xsl:variable>
  <xsl:variable name="dctTheme">http://publications.europa.eu/resource/authority/data-theme/</xsl:variable>

  <xsl:template match="@* | text()" />

 <xsl:template match="/dcatcollection">
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dct="http://purl.org/dc/terms/"
             xmlns:dcat="http://www.w3.org/ns/dcat#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#">
      <dcat:Catalog>
		<dct:description xml:lang="de">Open Data Katalog des Open Agrar Repositoriums</dct:description>
		<dct:description xml:lang="en">Open Data Catalogue of Open Agrar Repository</dct:description>
        <dct:publisher>
          <foaf:Agent>
            <foaf:name>Open Agrar Repositorium</foaf:name>
          </foaf:Agent>
        </dct:publisher>
        <dct:title>Open Agrar Datasets</dct:title>
        <foaf:homepage rdf:resource="https://opendata.stadt-muenster.de/welcomehttps://www.openagrar.de/content/index.xml"/>
        <dct:language rdf:resource="http://publications.europa.eu/resource/authority/language/DEU"/>
        <dct:language rdf:resource="http://publications.europa.eu/resource/authority/language/ENG"/>
        <dcat:theme rdf:resource="{concat($dctTheme, 'AGRI')}"/>
        <xsl:for-each select="mycoreobject">
		  <dcat:dataset>
		    <dcat:Dataset rdf:about="{concat($OAURL,./@ID)}">
              <xsl:apply-templates />
              <xsl:call-template name="derivates"/>
            </dcat:Dataset>
          </dcat:dataset>
        </xsl:for-each>
      </dcat:Catalog>
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="mycoreobject/metadata/def.modsContainer/modsContainer">
    <xsl:apply-templates />
  </xsl:template>
  
 
  <xsl:template match="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods">
	<rdf:type rdf:resource="http://www.w3.org/ns/dcat#Dataset"/>
    <xsl:call-template name="title" />
    <xsl:call-template name="description" />
    <xsl:call-template name="publisher" />
    <xsl:call-template name="creator" />
    <xsl:call-template name="issued" />
    <xsl:call-template name="language" />
    <xsl:call-template name="license" /> 
  </xsl:template>

  <xsl:template name="creator">
    <xsl:for-each select="mods:name[@type='personal']">
      <dct:creator>
        <rdf:Description>
          <xsl:if test="mods:nameIdentifier">
            <xsl:attribute name="rdf:about">
              <xsl:choose>
                <xsl:when test="mods:nameIdentifier[@type='orcid']">
                  <xsl:value-of select="concat($orcidURL, mods:nameIdentifier[@type='orcid'])"/>
                </xsl:when>
                <xsl:when test="mods:nameIdentifier[@type='gnd']">
                  <xsl:value-of select="concat($gndURL, mods:nameIdentifier[@type='gnd'])"/>
                </xsl:when>
                <xsl:when test="mods:nameIdentifier[@type='viaf']">
                  <xsl:value-of select="concat($viafURL, mods:nameIdentifier[@type='viaf'])"/>
                </xsl:when>
                <xsl:when test="mods:nameIdentifier[@type='scopus']">
                  <xsl:value-of select="concat($scopusURL, mods:nameIdentifier[@type='scopus'])"/>
                </xsl:when>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>
          <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Person"/>
          <foaf:name><xsl:value-of select="concat(mods:namePart[@type='family'], ', ', mods:namePart[@type='given'][1])"/></foaf:name>
          <foaf:givenName><xsl:value-of select="mods:namePart[@type='given'][1]"/></foaf:givenName>
          <foaf:familyName><xsl:value-of select="mods:namePart[@type='family']"/></foaf:familyName>
          <xsl:if test="mods:affiliation">
            <org:OrganizationOf>
              <foaf:Organization>
                <foaf:name><xsl:value-of select="mods:affiliation" /></foaf:name>
              </foaf:Organization>
            </org:OrganizationOf>
          </xsl:if>
        </rdf:Description>
      </dct:creator>
    </xsl:for-each>
  </xsl:template>


  <xsl:template name="title">
    <xsl:for-each select="mods:titleInfo">
      <dct:title>
        <xsl:copy-of select="./@xml:lang"/>
        <xsl:value-of select="mods:title[1]" />
      </dct:title>
    </xsl:for-each>
  </xsl:template>


  <xsl:template name="publisher">
	<xsl:choose>
      <xsl:when test="./mods:originInfo/mods:publisher">
        <dct:publisher>
          <foaf:Agent>
            <foaf:name><xsl:value-of select="./mods:originInfo/mods:publisher" /></foaf:name>
          </foaf:Agent>
        </dct:publisher>
      </xsl:when>
      <xsl:otherwise>
		  <dct:publisher>
          <foaf:Agent>
            <foaf:name>NO PUBLISHER</foaf:name>
          </foaf:Agent>
        </dct:publisher>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="issued">
    <xsl:if test="mods:originInfo[@eventType='publication']">
      <dct:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
        <xsl:value-of select="substring(mods:originInfo[@eventType='publication']/mods:dateIssued[1], 1,4)" />
      </dct:issued>
    </xsl:if>
  </xsl:template>

  <xsl:template name="description">
    <xsl:for-each select="mods:abstract[not(@contentType='text/xml')]">
      <dct:description>
        <xsl:copy-of select="./@xml:lang"/>
        <xsl:value-of select="." />
      </dct:description>
    </xsl:for-each>
    <xsl:if test="count(mods:abstract[not(@contentType='text/xml')]) = 0">
		 <dct:description xml:lang="en">No Abstract available</dct:description>
    </xsl:if>
  </xsl:template>

  <xsl:template name="derivates">
    
    <xsl:for-each select="structure/derobjects/derobject">
		 <xsl:variable name="objectID"><xsl:value-of select="./@xlink:href"/></xsl:variable>
          <dcat:distribution>
		    <dcat:Distribution>
              <xsl:attribute name="rdf:resource">
              <xsl:value-of select="concat($OAURL, $objectID)"/>
              </xsl:attribute>
              <dcat:accessURL>
				  <xsl:attribute name="rdf:resource">
					  <xsl:value-of select="concat($OAURL,../../../@ID)"/>
				  </xsl:attribute>
		      </dcat:accessURL>
		      <dcat:downloadURL>
				  <xsl:attribute name="rdf:resource">
					  <xsl:value-of select="concat($OAFileURL, maindoc)"/>
				  </xsl:attribute>
		      </dcat:downloadURL>
		      <dct:format>
				  <xsl:attribute name="rdf:resource">
					  <xsl:value-of select="concat($dctFileType, translate(substring-after(maindoc, '.'), 'pdf', 'PDF'))"/>
				  </xsl:attribute>
		      </dct:format>
           </dcat:Distribution>
          </dcat:distribution>

    </xsl:for-each>

  </xsl:template>

  <xsl:template name="license">
    <xsl:for-each select="mods:accessCondition[@type='use and reproduction']">
      <xsl:variable name="license">
        <xsl:choose>
          <xsl:when test="contains(./@xlink:href, 'cc_by')">
            <xsl:value-of select="concat($dctLicenseURI,'cc-by', translate(substring-after(./@xlink:href, 'cc_by'), '_', '/'))"/>
          </xsl:when>
          <xsl:when test="contains(./@xlink:href, 'cc_zero')">
            <xsl:value-of select="concat($dctLicenseURI, 'cc-zero')" />
          </xsl:when>
          <!-- To check !! -->
          <xsl:when test="contains(./@xlink:href., 'mir_licenses#oa')"><xsl:value-of select="concat($dctLicenseURI, 'other-open')" /></xsl:when>
          <xsl:when test="contains(./@xlink:href, 'mir_licenses#rights_reserved')"><xsl:value-of select="concat($dctLicenseURI, 'other-closed')" /></xsl:when>
        </xsl:choose>
      </xsl:variable>
      <!-- Replace last "_" in license by "/" !!! -->
      <dct:license rdf:resource="{$license}"/>
    </xsl:for-each>
    <!-- What to do with copyrightMD ??? -->
  </xsl:template>

  <xsl:template name="keywords">
    <xsl:for-each select="mods:subject/mods:topic">
      <dcat:keyword>
        <xsl:value-of select="."/>
      </dcat:keyword>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="language">
    <xsl:if test="mods:language">
      <dct:language>
        <xsl:variable name="lang">
          <xsl:choose>
            <xsl:when test="mods:language/mods:languageTerm[@authority='rfc5646'][1] = 'de'"><xsl:text></xsl:text>DEU</xsl:when>
            <xsl:when test="mods:language/mods:languageTerm[@authority='rfc5646'][1] = 'en'">ENG</xsl:when>
            <xsl:otherwise>ENG</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($dctLanguageURI, $lang)"/></xsl:attribute>
      </dct:language>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>


