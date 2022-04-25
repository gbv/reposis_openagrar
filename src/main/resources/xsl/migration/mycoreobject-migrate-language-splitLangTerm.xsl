<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
     version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:mods="http://www.loc.gov/mods/v3">

  <xsl:include href="copynodes.xsl" />
  <xsl:include href="mods-utils.xsl"/>

  <xsl:template match="mods:language[count(mods:languageTerm[@authority='rfc5646']) &gt; 1]">
    <xsl:for-each select="mods:languageTerm[@authority='rfc5646']">
      <mods:language>
        <xsl:if test="position()=1">
          <xsl:attribute name="usage">
            <xsl:text>primary</xsl:text>
          </xsl:attribute>
        </xsl:if>
        <mods:languageTerm authority="rfc5646" type="code">
          <xsl:value-of select="."/>
        </mods:languageTerm>
      </mods:language>
    </xsl:for-each>
    
  </xsl:template>

</xsl:stylesheet>
