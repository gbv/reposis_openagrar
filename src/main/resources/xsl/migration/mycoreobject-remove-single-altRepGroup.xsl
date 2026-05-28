<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:xlink="http://www.w3.org/1999/xlink">

  <xsl:template match="classification[@classid='mir_access']">
    
  </xsl:template>

    <!-- copy from copynodes.xsl -->
  <xsl:template match='@*|node()'>
    <xsl:param name="ID" />
    <!-- default template: just copy -->
    <xsl:copy>
      <xsl:apply-templates select='@*|node()' />
      <xsl:if test="$ID">
        <xsl:attribute name="ID">
          <xsl:value-of select="$ID" />
        </xsl:attribute>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>