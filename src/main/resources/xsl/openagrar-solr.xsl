<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="mods mcrxsl xlink"
>
  <xsl:import href="xslImport:solr-document:openagrar-solr.xsl" />
  <xsl:include href="date.statistic.xsl"/>

  <xsl:template match="mycoreobject[contains(@ID,'_mods_')]">
    <xsl:apply-imports />
    <!-- fields from mycore-mods -->
    <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods" mode="oa" />
  </xsl:template>

  <xsl:template match="mods:mods" mode="oa">
    <xsl:for-each select="mods:titleInfo[not(@type)][1]">
      <field name="mods.title.autocomplete">
        <xsl:value-of select="mods:title" />
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:location/mods:physicalLocation">
      <field name="mods.physicalLocation">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:classification[@displayLabel='annual_review']">
      <field name="mods.annual_review">
        <xsl:value-of select="@edition" />
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:name/mods:affiliation">
      <field name="mods.affiliation">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and (@type='text' and text()='author') or (@type='code' and text()='aut')]]/mods:affiliation">
      <field name="mods.author.affiliation">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and (@type='text' and text()='editor') or (@type='code' and text()='edt')]]/mods:affiliation">
      <field name="mods.editor.affiliation">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
    <xsl:for-each
      select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and (@type='text' and text()='author') or (@type='code' and text()='aut')]]">
      <xsl:choose>
        <xsl:when test="not(../mods:name/mods:role/mods:roleTerm[contains(@valueURI, '#')])">
          <xsl:variable name="autrole">
            <xsl:choose>
              <xsl:when test="position()=1">
                <xsl:text>mainAuthor</xsl:text>
              </xsl:when>	
              <xsl:when test="position()=last()">
                <xsl:text>lastAuthor</xsl:text>
              </xsl:when>
              <xsl:otherwise>
               <xsl:text>noRole</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>						
          <xsl:if test="$autrole != 'noRole'">
            <field name="{concat('mods.', $autrole)}">
			  <xsl:choose>
			    <xsl:when test="mods:displayForm">
				  <xsl:value-of select="mcrxsl:normalizeUnicode(mods:displayForm)" />
			    </xsl:when>
			    <xsl:when test="mods:namePart">
                  <xsl:for-each select="mods:namePart">
				    <xsl:choose>
					  <xsl:when test="@type='family'">
						  <xsl:value-of select="concat(mcrxsl:normalizeUnicode(.), ',')" />
					  </xsl:when>
					  <xsl:when test="@type='given'">
						 <xsl:value-of select="concat(' ',mcrxsl:normalizeUnicode(.))" />
					  </xsl:when>
					  <xsl:otherwise>
						  <xsl:value-of select="concat(mcrxsl:normalizeUnicode(.), ' ')" />
					  </xsl:otherwise>
					</xsl:choose>    
                  </xsl:for-each>
                </xsl:when>
              </xsl:choose>
            </field>
            <xsl:if test="mods:affiliation">
              <field name="{concat('mods.', $autrole, '.affiliation')}">
                <xsl:value-of select="mods:affiliation" />
              </field>
            </xsl:if>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="mods:role/mods:roleTerm[contains(@valueURI, '#')]">
            <xsl:variable name="autrole">
              <xsl:choose>
                <xsl:when test="substring-after(@valueURI, '#') ='main_author'">
                  <xsl:text>mainAuthor</xsl:text>
                </xsl:when>
                <xsl:when test="substring-after(@valueURI, '#') ='co_author'">
                  <xsl:text>coAuthor</xsl:text>
                </xsl:when>
                <xsl:when test="substring-after(@valueURI, '#') ='corresponding_author'">
                  <xsl:text>correspondingAuthor</xsl:text>
                </xsl:when>
                <xsl:when test="substring-after(@valueURI, '#') ='last_author'">
                  <xsl:text>lastAuthor</xsl:text>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            <field name="{concat('mods.', $autrole)}">
			  <xsl:choose>
			    <xsl:when test="../../mods:displayForm">
				  <xsl:value-of select="mcrxsl:normalizeUnicode(../../mods:displayForm)" />
			    </xsl:when>
			    <xsl:when test="../../mods:namePart">
				  <xsl:for-each select="../../mods:namePart">
					<xsl:choose>
					  <xsl:when test="@type='family'">
						  <xsl:value-of select="concat(mcrxsl:normalizeUnicode(.), ',')" />
					  </xsl:when>
					  <xsl:when test="@type='given'">
						 <xsl:value-of select="concat(' ',mcrxsl:normalizeUnicode(.))" />
					  </xsl:when>
					  <xsl:otherwise>
						  <xsl:value-of select="concat(mcrxsl:normalizeUnicode(.), ' ')" />
					  </xsl:otherwise>
					</xsl:choose>                    
                  </xsl:for-each>
			    </xsl:when>
			  </xsl:choose>             
            </field>
            <xsl:if test="../../mods:affiliation">
              <field name="{concat('mods.', $autrole, '.affiliation')}">
                <xsl:value-of select="../../mods:affiliation" />
              </field>
            </xsl:if>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each> 
    <xsl:for-each select="mods:genre[contains(@authorityURI,'classifications/genres')]">
      <xsl:variable name="genre" select="."/>
      <xsl:if test="not(../mods:relatedItem[@type='host'])">
        <field name="mods.genre.composite">
          <xsl:value-of select="concat(substring-after($genre/@valueURI,'#'),'.')" />
        </field>
      </xsl:if>
      <xsl:for-each select="../mods:relatedItem[@type='host']/mods:genre">
        <field name="mods.genre.composite">
          <xsl:value-of select="concat(substring-after($genre/@valueURI,'#'),'.',substring-after(@valueURI,'#'))" />
        </field>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:for-each select="mods:relatedItem[@type='host' or @type='series']/mods:part">
      <xsl:if test="mods:detail[@type='issue']">
        <field name="mods.part.issue"><xsl:value-of select="mods:detail[@type='issue']"/></field>
      </xsl:if>
      <xsl:if test="mods:detail[@type='volume']">
        <field name="mods.part.volume"><xsl:value-of select="mods:detail[@type='volume']"/></field>
      </xsl:if>
      <xsl:if test="mods:extent[@unit='pages']/mods:start">
        <field name="mods.part.pages.start"><xsl:value-of select="mods:extent[@unit='pages']/mods:start"/></field>
      </xsl:if>
      <xsl:if test="mods:extent[@unit='pages']/mods:end">
        <field name="mods.part.pages.end"><xsl:value-of select="mods:extent[@unit='pages']/mods:end"/></field>
      </xsl:if>
      <xsl:if test="mods:detail[@type='article_number']">
        <field name="mods.part.articlenumber"><xsl:value-of select="mods:detail[@type='article_number']"/></field>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="mods:relatedItem[@type='host']/mods:relatedItem[@type='series']">
      <xsl:if test="mods:titleInfo[not(@type)]/mods:title">
        <field name="mods.title.series.host"><xsl:value-of select="mods:titleInfo[not(@type)]/mods:title"/></field>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="mods:relatedItem[@type='host']/mods:relatedItem[@type='host' or @type='series']/mods:part">
      <xsl:if test="mods:detail[@type='issue']">
        <field name="mods.part.issue.host"><xsl:value-of select="mods:detail[@type='issue']"/></field>
      </xsl:if>
      <xsl:if test="mods:detail[@type='volume']">
        <field name="mods.part.volume.host"><xsl:value-of select="mods:detail[@type='volume']"/></field>
      </xsl:if>
      <xsl:if test="mods:extent[@unit='pages']/mods:start">
        <field name="mods.part.pages.start.host"><xsl:value-of select="mods:extent[@unit='pages']/mods:start"/></field>
      </xsl:if>
      <xsl:if test="mods:extent[@unit='pages']/mods:end">
        <field name="mods.part.pages.end.host"><xsl:value-of select="mods:extent[@unit='pages']/mods:end"/></field>
      </xsl:if>
      <xsl:if test="mods:detail[@type='article_number']">
        <field name="mods.part.articlenumber.host"><xsl:value-of select="mods:detail[@type='article_number']"/></field>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each select="mods:relatedItem[@type='host']/mods:genre">
      <field name="mods.genre.host">
        <xsl:value-of select="substring-after(@valueURI,'#')" />
      </field>
    </xsl:for-each>
    <xsl:choose>
      <xsl:when test="mods:extension/chars/@refereed='yes'">
        <field name="mods.refereed">yes</field>
      </xsl:when>
      <xsl:when test="mods:extension/chars/@refereed='no'">
        <field name="mods.refereed">no</field>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="mods:relatedItem[@type='host' or @type='series']/mods:extension/chars/@refereed='yes'">
            <field name="mods.refereed">yes</field>
          </xsl:when>
          <xsl:when test="mods:relatedItem[@type='host' or @type='series']/mods:extension/chars/@refereed='no'">
            <field name="mods.refereed">no</field>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension/chars/@refereed='yes'">
                <field name="mods.refereed">yes</field>
              </xsl:when>
              <xsl:when test="mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension/chars/@refereed='no'">
                <field name="mods.refereed">no</field>
              </xsl:when>
              <xsl:otherwise>
                <field name="mods.refereed">n/a</field>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="mods:extension/chars/@refereed='yes'">
        <field name="mods.refereed.public">yes</field>
      </xsl:when>
      <xsl:when test="mods:extension/chars/@refereed='no'">
        <field name="mods.refereed.public">no</field>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="mods:relatedItem[@type='host' or @type='series']/mods:extension/chars/@refereed='yes'">
            <field name="mods.refereed.public">yes</field>
          </xsl:when>
          <xsl:when test="mods:relatedItem[@type='host' or @type='series']/mods:extension/chars/@refereed='no'">
            <field name="mods.refereed.public">no</field>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension/chars/@refereed='yes'">
                <field name="mods.refereed.public">yes</field>
              </xsl:when>
              <xsl:when test="mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension/chars/@refereed='no'">
                <field name="mods.refereed.public">no</field>
              </xsl:when>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:for-each select="mods:identifier[@type='isbn']">
      <field name="mods.identifier.isbn"><xsl:value-of select="."/></field> 
    </xsl:for-each>
    <xsl:for-each select="mods:relatedItem[@type='host']/mods:identifier[@type='isbn']">
      <field name="mods.identifier.isbn"><xsl:value-of select="."/></field> 
    </xsl:for-each>
    <xsl:for-each select="mods:identifier[@type='issn']">
      <field name="mods.identifier.issn"><xsl:value-of select="."/></field> 
    </xsl:for-each>
    <xsl:for-each select="mods:relatedItem[@type='host' or @type='series']/mods:identifier[@type='issn']">
      <field name="mods.identifier.issn"><xsl:value-of select="."/></field> 
    </xsl:for-each>
    <xsl:for-each select="mods:relatedItem[@type='host']/mods:relatedItem[@type='host' or @type='series']/mods:identifier[@type='issn']">
      <field name="mods.identifier.issn"><xsl:value-of select="."/></field> 
    </xsl:for-each>
    
    <xsl:variable name="dateIssued_statistics">
      <xsl:call-template name="getDateStatistic">
        <xsl:with-param name="mods" select="."/>
      </xsl:call-template>
    </xsl:variable>
    
    <field name="mods.dateIssued.statistic"> <xsl:value-of select="$dateIssued_statistics" /> </field>
    <field name="mods.yearIssued.statistic"> <xsl:value-of select="substring($dateIssued_statistics,1,4)" /> </field>


    <field name="mods.dateIssuedPrint">
      <xsl:value-of select="mods:originInfo[@eventType='publication_print']/mods:dateIssued[@encoding='w3cdtf']"/>
    </field>
    <field name="mods.dateIssuedOnline">
      <xsl:value-of select="mods:originInfo[@eventType='publication_online']/mods:dateIssued[@encoding='w3cdtf']"/>
    </field>

    <!-- JCR -->
    <xsl:variable name="yearIssued" select="substring($dateIssued_statistics,1,4)"/>
    <xsl:variable name="yearIssued1Yb" select="$yearIssued - 1"/>
    <xsl:variable name="yearIssued2Yb" select="$yearIssued - 2"/>
    <xsl:variable name="encryptedJCR">
      <xsl:choose>
        <xsl:when test="mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued]">
          <xsl:value-of select="mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued]"/>
        </xsl:when>
        <xsl:when test="mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem/mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued]">
          <xsl:value-of select="mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued]"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$encryptedJCR">
      <xsl:variable name="JCR" select="document(concat('crypt:decrypt:jcr:',$encryptedJCR))/value"/>
      <xsl:call-template name="JCR2JCRClass">
        <xsl:with-param name="JCR" select="$JCR"/>
        <xsl:with-param name="Fieldname" select="'oa.statistic.metric.jcr.class'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="encryptedJCR1Yb">
      <xsl:choose>
        <xsl:when test="mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued1Yb]">
          <xsl:value-of select="mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued1Yb]"/>
        </xsl:when>
        <xsl:when test="mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem/mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued1Yb]">
          <xsl:value-of select="mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued1Yb]"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$encryptedJCR1Yb">
      <xsl:variable name="JCR1Yb" select="document(concat('crypt:decrypt:jcr:',$encryptedJCR1Yb))/value"/>
      <xsl:call-template name="JCR2JCRClass">
        <xsl:with-param name="JCR" select="$JCR1Yb"/>
        <xsl:with-param name="Fieldname" select="'oa.statistic.metric.jcr.class1Yb'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="encryptedJCR2Yb">
      <xsl:choose>
        <xsl:when test="mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued2Yb]">
          <xsl:value-of select="mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued2Yb]"/>
        </xsl:when>
        <xsl:when test="mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem/mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued2Yb]">
          <xsl:value-of select="mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued2Yb]"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$encryptedJCR2Yb">
      <xsl:variable name="JCR2Yb" select="document(concat('crypt:decrypt:jcr:',$encryptedJCR2Yb))/value"/>
      <xsl:call-template name="JCR2JCRClass">
        <xsl:with-param name="JCR" select="$JCR2Yb"/>
        <xsl:with-param name="Fieldname" select="'oa.statistic.metric.jcr.class2Yb'"/>
      </xsl:call-template>
    </xsl:if>
    <!-- / JCR -->
    
    <xsl:for-each select="mods:location/mods:url">
      <field name="mods.location.url"><xsl:value-of select="."/></field> 
    </xsl:for-each>
    <xsl:for-each select="mods:physicalDescription/mods:extent">
      <field name="mods.physicalDescription.extent"><xsl:value-of select="."/></field> 
    </xsl:for-each>
    
    
  </xsl:template>
  
  <xsl:template name="JCR2JCRClass">
    <xsl:param name = "Fieldname" />
    <xsl:param name = "JCR" />

    <xsl:if test="number($JCR) = $JCR">
      <field name="{$Fieldname}">
        <xsl:choose>
          <xsl:when test="$JCR &lt; 1">
            <xsl:value-of select="'&lt; 1'"></xsl:value-of>
          </xsl:when>
          <xsl:when test="1 &lt;= $JCR and $JCR &lt; 3">
            <xsl:value-of select="'1-3'"></xsl:value-of>
          </xsl:when>
          <xsl:when test="3 &lt;= $JCR and $JCR &lt; 6">
            <xsl:value-of select="'3-6'"></xsl:value-of>
          </xsl:when>
          <xsl:when test="6 &lt;= $JCR and $JCR &lt; 9">
            <xsl:value-of select="'6-9'"></xsl:value-of>
          </xsl:when>
          <xsl:when test="$JCR &gt;= 9">
            <xsl:value-of select="'&gt; 9'"></xsl:value-of>
          </xsl:when>
        </xsl:choose>
      </field>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
