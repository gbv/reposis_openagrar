<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="mcrxsl i18n xlink">
  
  <xsl:template match="mods:extension">
     
    <xsl:choose>
      <xsl:when test="mcrxsl:isCurrentUserGuestUser()">
        <mods:extension>
          <xsl:value-of select="'mods:extension is not accessable for quest'" />
        </mods:extension>            
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
