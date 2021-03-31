<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink" >

  <xsl:include href="copynodes.xsl" />


  <!-- {!join from=mods.relatedItem to=id}objectType:mods -->

  <xsl:template match="mods:mods">
    <xsl:copy>
      <mods:recordInfo displayLabel="mcr_child_repair">
        <mods:recordChangeDate encoding="w3cdtf">2017-05-02</mods:recordChangeDate>
      </mods:recordInfo>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
