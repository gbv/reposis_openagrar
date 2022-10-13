<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mcrdataurl="xalan://org.mycore.datamodel.common.MCRDataURL">
  <xsl:include href="copynodes.xsl" />
  <xsl:include href="editor/mods-node-utils.xsl" />
  <xsl:include href="mods-utils.xsl"/>
  <xsl:include href="coreFunctions.xsl"/>
  
  
  <xsl:template match="mods:mods/mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value">
    <value>
      <xsl:copy-of select="@*" />
      <xsl:variable name="value" select="."/>
      <!-- Decrypt if ist it allready encrypted -->
      <xsl:variable name="decrpyted_value" select="document(concat('decrypt:key1:',$value))/value"/>
      <xsl:value-of select="document(concat('encrypt:key1:',$decrpyted_value))/value"/> 
    </value>
    
  </xsl:template>

  
</xsl:stylesheet>