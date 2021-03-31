<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:xlink="http://www.w3.org/1999/xlink">
  
  <xsl:include href="copynodes.xsl" />
  
  <xsl:template match="mods:mods/mods:genre">
    <mods:genre type="intern" authorityURI="https://www.openagrar.de/classifications/genres" valueURI="https://www.openagrar.de/classifications/genres#report" />
  </xsl:template>
  
</xsl:stylesheet>