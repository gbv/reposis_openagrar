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
    
    <xsl:variable name="ID">
		<xsl:choose>
			<xsl:when test="mods:mods/mods:identifer[@type='doi']">
				<xsl:value-of select="concat($doiURL, mods:mods/mods:identifer[@type='doi'][1])"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($OAURL, /mycoreobject[1]/@ID)"/>
			</xsl:otherwise>
		</xsl:choose>
    </xsl:variable>


    <xsl:template match="/mycoreobject/metadata/def.modsContainer/modsContainer">
        <xsl:apply-templates />
    </xsl:template>

   <xsl:template match="@* | text()" />
   
   <!-- Must have: dcat:Catalog + dcat:Dataset -->
    <xsl:template match="mods:mods">
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dct="http://purl.org/dc/terms/" 
        xmlns:dcat="http://www.w3.org/ns/dcat#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#">
            <dcat:Catalog rdf:about="{concat($ID, '#catalog')}">
					<xsl:call-template name="title" />
					<xsl:call-template name="description" />
					<xsl:call-template name="publisher" />
					<xsl:call-template name="creator" />
					<xsl:call-template name="issued" />
					<xsl:call-template name="language" />
					<!-- <xsl:call-template name="license" /> -->
					<xsl:choose>
						<xsl:when test="mods:location/mods:url">
							<xsl:call-template name="URLs"/>
						</xsl:when>
						<xsl:when test="/mycoreobject/structure/derobjects"> 
							<xsl:call-template name="derobjects"/>
						</xsl:when>
					</xsl:choose>
					
            </dcat:Catalog>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="creator">
		<xsl:for-each select="mods:name[@type='personal']">
        <dct:creator>
            <rdf:Description>
                <xsl:if test="mods:nameIdentifier">
                    <xsl:attribute name="rdf:about">
                        <xsl:choose>
                            <xsl:when test="mods:nameIdentifier[lower-case(@type)='orcid']">
                                <xsl:value-of select="concat($orcidURL, mods:nameIdentifier[lower-case(@type)='orcid'])"/>
                            </xsl:when>
                            <xsl:when test="mods:nameIdentifier[lower-case(@type)='gnd']">
                                <xsl:value-of select="concat($gndURL, mods:nameIdentifier[lower-case(@type)='gnd'])"/>
                            </xsl:when>
                            <xsl:when test="mods:nameIdentifier[lower-case(@type)='viaf']">
                                <xsl:value-of select="concat($viafURL, mods:nameIdentifier[lower-case(@type)='viaf'])"/>
                            </xsl:when>
                            <xsl:when test="mods:nameIdentifier[lower-case(@type)='scopus']">
                                <xsl:value-of select="concat($scopusURL, mods:nameIdentifier[lower-case(@type)='scopus'])"/>
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
		<xsl:for-each select="/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo">
			<dct:title>
				<xsl:copy-of select="./@xml:lang"/>
				<xsl:value-of select="mods:title[1]" />
			</dct:title>
        </xsl:for-each>
    </xsl:template>

   
    <xsl:template name="publisher">
		<xsl:if test="/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='publication']">
        <dct:publisher>
            <foaf:Agent>
                <foaf:name><xsl:value-of select="/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='publication']/mods:publisher[1]" /></foaf:name>
            </foaf:Agent>
        </dct:publisher>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="issued">
		<xsl:if test="mods:originInfo[@eventType='publication']">
			<dct:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
            <xsl:value-of select="concat(mods:originInfo[@eventType='publication']/mods:dateIssued[1], 'T00:00:00')" />
        </dct:issued>      
		</xsl:if>
    </xsl:template>
  
    <xsl:template name="description">
        <xsl:for-each select="/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:abstract[not(@contentType='text/xml')]">
            <dct:description>
               	<xsl:copy-of select="./@xml:lang"/>
                <xsl:value-of select="." />
            </dct:description>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="URLs">
			<xsl:for-each select="mods:location/mods:url">
					<dcat:dataset>
						<dcat:Dataset rdf:about="{concat(., '#dataset')}">	
								<!-- Title and description are mandatory for dataset. Take them from dcat:Catalog  -->
								<xsl:call-template name="title"/>					
								<xsl:call-template name="description"/>
								<dcat:accessURL rdf:resource="{.}" />
								<xsl:call-template name="keywords" />
								<!-- Theme in Agrar Open is always AGRI -->
								<dcat:theme rdf:resource="{concat($dctTheme, 'AGRI')}"/>
						</dcat:Dataset>
			</dcat:dataset>
		</xsl:for-each>
			
    </xsl:template>
    
     <xsl:template name="derobjects">
				<xsl:variable name="objectID"><xsl:value-of select="./@xlink:href"/></xsl:variable>
				<xsl:for-each select="/mycoreobject/structure/derobjects/derobject">
					<dcat:dataset>
						<dcat:Dataset rdf:about="{concat($ID, '#dataset')}">	
							<xsl:call-template name="title"/>					
							<xsl:call-template name="description"/>
							<dcat:distribution>
									<dcat:Distribution rdf:about="{concat($ID, '#distribution')}">
										<!-- For mapping the file type to EU Vocabularies file-type usually -->
										<dcat:format rdf:resource="{concat($dctFileType, upper-case(substring-after(maindoc, '.')))}"/> 
										<dcat:accessURL rdf:resource="{$ID}"/>
										<dcat:downoadURL rdf:resource="{concat($OAFileURL, $objectID, maindoc)}"/>	
										<xsl:call-template name="license" />
									</dcat:Distribution>
							</dcat:distribution>	
							<xsl:call-template name="keywords" />
							<!-- Theme in Agrar Open is always AGRI -->
							<dcat:theme rdf:resource="{concat($dctTheme, 'AGRI')}"/>												
					</dcat:Dataset>
			</dcat:dataset>
		</xsl:for-each>
			
    </xsl:template>
    
    <xsl:template name="license">
		<xsl:for-each select="/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='use and reproduction']">
			<xsl:variable name="license">
				<xsl:choose>
					<xsl:when test="contains(./@xlink:href, 'cc_by')">
						<xsl:value-of select="concat($dctLicenseURI,'cc-by', translate(substring-after(./@xlink:href, 'cc_by'), '_', '/'))"/>
					</xsl:when>
					<xsl:when test="contains(./@xlink:href, 'cc_zero')">
						<xsl:value-of select="concat($dctLicenseURI, 'cc-zero')" />
						</xsl:when>
					<!-- To check !! -->
					<xsl:when test="contains(., 'mir_licenses#oa')"><xsl:value-of select="concat($dctLicenseURI, 'other-open')" /></xsl:when>
					<xsl:when test="contains(., 'mir_licenses#rights_reserved')"><xsl:value-of select="concat($dctLicenseURI, 'other-closed')" /></xsl:when>
				</xsl:choose>
			</xsl:variable>
			<!-- Replace last "_" in license by "/" !!! -->
			<dct:license rdf:resource="{$license}"/>
		</xsl:for-each>
		<!-- What to do with copyrightMD ??? -->
    </xsl:template>
    
    <xsl:template name="keywords">
			<xsl:for-each select="/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:subject/mods:topic">
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
