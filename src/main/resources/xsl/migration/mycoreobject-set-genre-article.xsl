<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mcrdataurl="xalan://org.mycore.datamodel.common.MCRDataURL">
  <xsl:include href="copynodes.xsl" />
  <xsl:include href="editor/mods-node-utils.xsl" />
  <xsl:include href="mods-utils.xsl"/>
  <xsl:include href="coreFunctions.xsl"/>
  
  <!-- delete the normal main title in hope that ist the same as the html title -->
  <xsl:template match="mods:titleInfo[not(@transliteration) and //mods:titleInfo/@transliteration='text/html']">
  </xsl:template>
  <xsl:template match="mods:titleInfo[@transliteration='text/html']">
    <xsl:choose>
      <xsl:when test="mcrxml:isHtml(mods:nonSort/text()) or mcrxml:isHtml(mods:title/text()) or mcrxml:isHtml(mods:subTitle/text()) or mcrxml:isHtml(text())">
        <xsl:variable name="altRepGroup" select="generate-id(.)" />
        <xsl:copy>
          <xsl:attribute name="altRepGroup">
            <xsl:value-of select="$altRepGroup" />
          </xsl:attribute>
          <xsl:apply-templates select="@* [not (name(.)='transliteration')] " />
          <xsl:apply-templates mode="asPlainTextNode" />
        </xsl:copy>
        <xsl:element name="{name(.)}">
          <xsl:variable name="content">
            <xsl:apply-templates select="." mode="asXmlNode">
              <xsl:with-param name="ns" select="''" />
              <xsl:with-param name="serialize" select="false()" />
              <xsl:with-param name="levels">
                <xsl:choose>
                  <xsl:when test="name() = 'mods:titleInfo'">
                    <xsl:value-of select="2" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="1" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:variable>
          <xsl:attribute name="altRepGroup">
            <xsl:value-of select="$altRepGroup" />
          </xsl:attribute>
          <xsl:attribute name="altFormat">
            <xsl:value-of select="mcrdataurl:build($content, 'base64', 'text/xml', 'utf-8')" />
          </xsl:attribute>
          <xsl:attribute name="contentType">
            <xsl:value-of select="'text/xml'" />
          </xsl:attribute>
          <xsl:apply-templates select="@*" />
        </xsl:element>
      </xsl:when>
      
    </xsl:choose>
  </xsl:template>

  
</xsl:stylesheet>