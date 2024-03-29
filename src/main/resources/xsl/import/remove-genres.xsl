<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:mods="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xsl mods">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:genre" />
    
  <xsl:template match="mods:identifier[@type='isbn']" >
    <xsl:variable name="isbn" select="translate(text(),'-','')" />
    <xsl:choose>
      <xsl:when test="translate($isbn,'123456789X','0000000000') = '0000000000000' and (starts-with($isbn,'978') or starts-with($isbn,'979')) ">
        <mods:identifier type="isbn">
           <xsl:value-of select="text()"/>
        </mods:identifier>
      </xsl:when>
      <xsl:when test="translate($isbn,'123456789X','0000000000') = '0000000000' ">
        <mods:identifier type="isbn">
          <xsl:value-of select="text()"/>
        </mods:identifier>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>