<xsl:stylesheet version="1.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:dcatap="http://data.europa.eu/r5r/"
                xmlns:dcatde="http://dcat-ap.de/def/dcatde/"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:ns1="http://data.europa.eu/eli/ontology#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:org="http://www.w3.org/ns/org#"
                exclude-result-prefixes="mods xlink">


  <xsl:output method="xml" indent="yes" encoding="UTF-8" />

  <xsl:param name="WebApplicationBaseURL" />

  <!-- URLs in use -->
  <!-- open Agrar URLs -->
  <xsl:variable name="OABaseURL" select="$WebApplicationBaseURL" />
  <xsl:variable name="OAURL"><xsl:value-of select="concat($OABaseURL, 'receive/')" /></xsl:variable>
  <xsl:variable name="OAFileURL"><xsl:value-of select="concat($OABaseURL, 'servlets/MCRFileNodeServlet/')" /></xsl:variable>
  <xsl:variable name="OAZIPURL"><xsl:value-of select="concat($OABaseURL, 'servlets/MCRZipServlet/')" /></xsl:variable>

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
  <xsl:variable name="hvdcatURI">http://data.europa.eu/bna/c_60182062</xsl:variable>
  <xsl:variable name="applLegislationURI">http://data.europa.eu/eli/reg_impl/2023/138/oj</xsl:variable>
  <xsl:variable name="datatype">http://inspire.ec.europa.eu/metadata-codelist/ResourceType/dataset</xsl:variable>
  
  <xsl:variable name="rfc5646" select="document('classification:metadata:-1:children:rfc5646')" />
  <xsl:variable name="accessRights" select="document('classification:metadata:-1:children:mir_licenses')" />
  <xsl:variable name="theme"><xsl:value-of select="/dcatcollection/theme" /></xsl:variable>
  <xsl:variable name="contributorID"><xsl:value-of select="/dcatcollection/contributor" /></xsl:variable>

  <xsl:variable name="knownFormats">csv,pdf,xlsx,zip</xsl:variable>  
<!--  <xsl:key name="category" match="category" use="@ID" /> -->

  <xsl:template match="@* | text()" />

  <xsl:template match="/dcatcollection">
	
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dct="http://purl.org/dc/terms/"
             xmlns:dcat="http://www.w3.org/ns/dcat#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#">
      <dcat:Catalog>
        <!-- Mandatory fields: dct:title, dct:description, dct:publisher, dcat:dataset -->
        <xsl:call-template name="catalogproperties" />

        <xsl:for-each select="mycoreobject">
          <dcat:dataset>
            <!-- Mandatory fields: dct:title, dct:description -->
            <dcat:Dataset rdf:about="{concat($OAURL,./@ID)}">
              <xsl:apply-templates />
              <xsl:call-template name="derivates"/>
            </dcat:Dataset>
          </dcat:dataset>
        </xsl:for-each>
      </dcat:Catalog>
    </rdf:RDF>
  </xsl:template>

  <xsl:template name="catalogproperties">
    <dct:title xml:lang="de"><xsl:value-of select="title[@lang='de']" /></dct:title>
    <dct:title xml:lang="en"><xsl:value-of select="title[@lang='en']" /></dct:title>
    <dct:description xml:lang="de"><xsl:value-of select="beschreibung[@lang='de']" /></dct:description>
    <dct:description xml:lang="en"><xsl:value-of select="description[@lang='en']" /></dct:description>

    <dct:publisher>
      <foaf:Agent>
        <foaf:name><xsl:value-of select="publisher" /></foaf:name>
      </foaf:Agent>
    </dct:publisher>
    <foaf:homepage>
      <xsl:attribute name="rdf:resource"><xsl:value-of select="homepage" /></xsl:attribute>
    </foaf:homepage>
    <xsl:for-each select="language">
      <xsl:variable name="langcode"><xsl:value-of select="."/></xsl:variable>
      <dct:language>
        <xsl:attribute name="rdf:resource">
	  <xsl:value-of select="concat($dctLanguageURI,upper-case($rfc5646//category[@ID=$langcode]/label[@xml:lang='x-term']/@text)[1])" />
        </xsl:attribute>
      </dct:language>
    </xsl:for-each> 
  </xsl:template>

  <xsl:template match="mycoreobject/metadata/def.modsContainer/modsContainer">
    <xsl:apply-templates />
  </xsl:template>


  <xsl:template match="mods:mods">
    <xsl:call-template name="title" />
    <xsl:call-template name="description" />
    <xsl:call-template name="identifier" />
    <dcat:type rdf:resource="{$datatype}" />
    <xsl:call-template name="publisher" />
    <xsl:call-template name="issued" />
    <xsl:call-template name="theme" />
    <xsl:call-template name="keywords" />
    <xsl:call-template name="language" />
    <xsl:call-template name="creator" />
    <xsl:call-template name="accessRights" /> 
    <xsl:call-template name="hvdCategory" />
    <xsl:call-template name="contributor" /> 
  </xsl:template>

  <xsl:template name="title">
    <xsl:for-each select="mods:titleInfo">
	  <xsl:if test="mods:title">
        <dct:title>
		  <xsl:copy-of select="./@xml:lang"/>
          <xsl:value-of select="mods:title" />
        </dct:title>
      </xsl:if>
    </xsl:for-each>
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

  <xsl:template name="creator">
    <xsl:for-each select="mods:name[@type='personal']">
      <xsl:if test="mods:role/mods:roleTerm = 'aut'">
        <dct:creator>
          <rdf:Description>
            <xsl:if test="mods:nameIdentifier[@type != 'scopus']">
              <xsl:attribute name="rdf:about">
                <xsl:choose>
                  <xsl:when test="mods:nameIdentifier[@type='orcid']">
                    <xsl:value-of select="concat($orcidURL, mods:nameIdentifier[lower-case(@type)='orcid'])"/>
                  </xsl:when>
                  <xsl:when test="mods:nameIdentifier[@type='gnd']">
                    <xsl:value-of select="concat($gndURL, mods:nameIdentifier[lower-case(@type)='gnd'])"/>
                  </xsl:when>
                  <xsl:when test="mods:nameIdentifier[@type='viaf']">
                    <xsl:value-of select="concat($viafURL, mods:nameIdentifier[lower-case(@type)='viaf'])"/>
                  </xsl:when>
                 <!-- <xsl:when test="mods:nameIdentifier[@type='scopus']">
                    <xsl:value-of select="concat($scopusURL, mods:nameIdentifier[lower-case(@type)='scopus'])"/>
                  </xsl:when> -->
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
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <xsl:template name="publisher">
    <xsl:if test="mods:originInfo/mods:publisher">
      <dct:publisher>
        <foaf:Agent>
          <foaf:name>
            <xsl:value-of select="mods:originInfo/mods:publisher" />
          </foaf:name>
        </foaf:Agent>
      </dct:publisher>
    </xsl:if>
  </xsl:template>

  <xsl:template name="issued">
    <xsl:if test="mods:originInfo[@eventType='publication']/mods:dateIssued">
      <dct:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">
        <xsl:value-of select="substring(mods:originInfo[@eventType='publication']/mods:dateIssued[1], 1,4)" />
      </dct:issued>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="theme">
    <xsl:if test="$theme != 'NONE'">
      <dcat:theme rdf:resource="{concat($dctTheme, $theme)}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="derivates">
    <xsl:variable name="MCRID"><xsl:value-of select="./@ID" /></xsl:variable>
    <!-- Dataset documentation -->
    <xsl:for-each select="structure/derobjects/derobject">
      <xsl:if test="classification[contains(@categid,'documentation')]">
        <foaf:page rdf:resource="{concat($OAFileURL, @xlink:href, '/', maindoc)}"/>
      </xsl:if>
    </xsl:for-each>
    <!-- Do not create distribution if content-derivates are under embargo -->
    <xsl:if test="not(metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='embargo'])">
      <xsl:variable name="ifs">
        <xsl:for-each select="./structure/derobjects/derobject[@xlink:href]">
          <der id="{@xlink:href}">
            <xsl:copy-of select="document(concat('xslStyle:mcr_directory-recursive:ifs:',@xlink:href,'/'))" />
          </der>
        </xsl:for-each>
      </xsl:variable>     
      <xsl:if test="$ifs/der">
        <xsl:for-each select="structure/derobjects/derobject[classification[contains(@categid,'content')]]">
          <!-- Create distribution only if derivate is of category "content" or "content_other_format" -->
          <dcat:distribution>
            <dcat:Distribution rdf:about="{concat($OAURL, $MCRID)}">
              <!-- Mandatory fields: dcat:accessURL -->
              <!-- TODO: check if derivate contains more than one file -->
              <dcat:accessURL rdf:resource="{concat($OAFileURL, @xlink:href, '/', maindoc)}" />
              <xsl:if test="contains($knownFormats, tokenize(maindoc,'\.')[last()])">
                <dct:format rdf:resource="{concat($dctFileType, upper-case(tokenize(maindoc,'\.')[last()]))}"/>
              </xsl:if>
              <xsl:if test="../../../metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[@generator='mir_licenses2dcat_license-mycore']">
                <dct:license rdf:resource="{concat($dctLicenseURI, substring-after(../../../metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[@generator='mir_licenses2dcat_license-mycore'][1]/@valueURI, '#'))}"/>
              </xsl:if>
            </dcat:Distribution>
          </dcat:distribution>
        </xsl:for-each>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="identifier">
    <dct:identifier>
      <xsl:value-of select="../../../../@ID" />
    </dct:identifier>
  </xsl:template>

  <xsl:template name="keywords">
    <xsl:for-each select="mods:subject/mods:topic">
      <dcat:keyword>
        <xsl:value-of select="."/>
      </dcat:keyword>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="language">
    <xsl:for-each select="mods:language">
      <xsl:if test="mods:languageTerm[@authority='rfc5646']">
        <xsl:variable name="langcode"><xsl:value-of select="mods:languageTerm[@authority='rfc5646']"/></xsl:variable>
        <dct:language>
          <xsl:attribute name="rdf:resource">
            <xsl:value-of select="concat($dctLanguageURI,upper-case($rfc5646//category[@ID=$langcode]/label[@xml:lang='x-term']/@text)[1])" />
          </xsl:attribute>
        </dct:language>   
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="contributor">
    <xsl:if test="$contributorID != 'NONE'"> 
      <dcatde:contributorID rdf:resource="{$contributorID}" />
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="accessRights">
    <xsl:for-each select="mods:accessCondition[@type='use and reproduction']">
      <xsl:variable name="access"><xsl:value-of select="substring-after(./@xlink:href, '#')"/></xsl:variable>
      <dct:accessRights>
        <dct:RightsStatement rdf:nodeID="{../../../../../@ID}">
          <rdfs:label>
			<xsl:choose>
			  <xsl:when test="$accessRights//category[@ID=$access]/label[@xml:lang='de']/@description">
			    <xsl:value-of select="$accessRights//category[@ID=$access]/label[@xml:lang='de']/@description" />
			  </xsl:when>
			  <xsl:otherwise>
			    <xsl:value-of select="$accessRights//category[@ID=$access]/label[@xml:lang='de']/@text" />
			  </xsl:otherwise>
			</xsl:choose>	        
          </rdfs:label>
        </dct:RightsStatement>
      </dct:accessRights>
    </xsl:for-each> 
  </xsl:template>
    
  <xsl:template name="hvdCategory">
    <xsl:for-each select="mods:classification[@authority='dcatHVD']">
	  <dcatap:hvdCategory>
	    <xsl:attribute name="rdf:resource">
		  <xsl:value-of select="concat($hvdcatURI, .)" />
		</xsl:attribute>
	  </dcatap:hvdCategory>
    </xsl:for-each>
    <xsl:if test="mods:classification[@authority='dcatHVD']">
      <dcatap:applicableLegislation>
        <ns1:LegalResource rdf:about="{$applLegislationURI}"/>
      </dcatap:applicableLegislation>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
