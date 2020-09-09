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
    <xsl:for-each select="mods:subject">
      <xsl:for-each select="mods:topic">
        <field name="mods.subject">
          <xsl:value-of select="." />
        </field>
      </xsl:for-each>
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
    <xsl:for-each
      select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and (@type='text' and text()='author') or (@type='code' and text()='aut')]]">
      <xsl:if test="position()=1">
        <field name="mods.mainAuthor">
          <xsl:for-each select="mods:displayForm | mods:namePart | text()">
            <xsl:value-of select="concat(' ',mcrxsl:normalizeUnicode(.))" />
          </xsl:for-each>
        </field>
        <field name="mods.mainAuthor.affiliation">
          <xsl:value-of select="mods:affiliation" />
        </field>
      </xsl:if>
    </xsl:for-each>
    <xsl:for-each
      select="mods:name[mods:role/mods:roleTerm[@authority='marcrelator' and (@type='text' and text()='author') or (@type='code' and text()='aut')]]">
      <xsl:if test="position()= last()">
        <field name="mods.lastAuthor">
          <xsl:for-each select="mods:displayForm | mods:namePart | text()">
            <xsl:value-of select="concat(' ',mcrxsl:normalizeUnicode(.))" />
          </xsl:for-each>
        </field>
        <field name="mods.lastAuthor.affiliation">
          <xsl:value-of select="mods:affiliation" />
        </field>
      </xsl:if>
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
    <xsl:for-each select="//mods:identifier[@type='isbn']">
      <field name="mods.identifier.isbn"><xsl:value-of select="."/></field> 
    </xsl:for-each>
    <xsl:for-each select="//mods:identifier[@type='issn']">
      <field name="mods.identifier.issn"><xsl:value-of select="."/></field> 
    </xsl:for-each>
    
    <xsl:variable name="yearIssued" select="substring(//mods:mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf'],1,4)"/>
    <xsl:variable name="yearIssued1Yb" select="$yearIssued - 1"/>
    <xsl:if test="//mods:extension[@displayLabel='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued]">
      <xsl:variable name="encryptedJCR" select="//mods:extension[@displayLabel='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued]"/>
      <xsl:variable name="JCR" select="document(concat('decrypt:',$encryptedJCR))/value"/>
      <xsl:call-template name="JCR2JCRClass">
        <xsl:with-param name="JCR" select="$JCR"/>
        <xsl:with-param name="Fieldname" select="'oa.statistic.metric.jcr.class'"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="//mods:extension[@displayLabel='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued1Yb]">
      <xsl:variable name="encryptedJCR1Yb" select="//mods:extension[@displayLabel='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued1Yb]"/>
      <xsl:variable name="JCR1Yb" select="document(concat('decrypt:',$encryptedJCR1Yb))/value"/>
      <xsl:call-template name="JCR2JCRClass">
        <xsl:with-param name="JCR" select="$JCR1Yb"/>
        <xsl:with-param name="Fieldname" select="'oa.statistic.metric.jcr.class1Yb'"/>
      </xsl:call-template>
    </xsl:if>
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