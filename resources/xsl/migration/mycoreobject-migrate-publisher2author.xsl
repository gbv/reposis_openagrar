<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3">
  <xsl:include href="copynodes.xsl" />
  
  <xsl:template match="mods:mods/mods:name[@type='corporate']/mods:role/mods:roleTerm[@authority='marcrelator'][text()='edt']/text()">
  <!-- <xsl:template match="mods:mods/mods:name[@type='corporate']"> -->
    <xsl:value-of select="'aut'"/>
  </xsl:template>

</xsl:stylesheet>