<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:math="http://exslt.org/math"
  xmlns:mcrdataurl="xalan://org.mycore.datamodel.common.MCRDataURL">
  
  <xsl:include href="copynodes.xsl" />
    
  <xsl:template match="mods:mods/mods:extension[@displayLabel='characteristics']">
    <xsl:if test="not (../mods:extension[@type='characteristics'])" >
      <xsl:if test="chars[@refereed='yes']" >
        <mods:extension type="characteristics">
          <chars refereed="yes"/>
        </mods:extension>
      </xsl:if>
      <xsl:if test="chars[@refereed='no']" >
        <mods:extension type="characteristics">
          <chars refereed="no"/>
        </mods:extension>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="mods:mods/mods:extension[@displayLabel='metrics']">
    <xsl:if test="not (../mods:extension[@type='metrics']) and count(node()) &gt; 0" >
      <mods:extension type="metrics">
        <xsl:copy-of select="*" />
      </mods:extension>
    </xsl:if>
  </xsl:template>
   
  
  
</xsl:stylesheet>