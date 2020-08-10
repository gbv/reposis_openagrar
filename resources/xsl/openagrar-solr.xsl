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
    <xsl:variable name="yearIssued" select="2019"/>
    <xsl:if test="//mods:extension[@displayLabel='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$yearIssued]">
      <field name="mods.extension.metric.jcr"><xsl:value-of select="document(concat('encrypt:','1.5'))/value"/></field>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>