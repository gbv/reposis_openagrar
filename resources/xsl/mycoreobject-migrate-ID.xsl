<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:math="http://exslt.org/math"
  xmlns:mcrdataurl="xalan://org.mycore.datamodel.common.MCRDataURL">
  
  <xsl:include href="copynodes.xsl" />
  <xsl:include href="editor/mods-node-utils.xsl" />
  <xsl:include href="mods-utils.xsl"/>
  <xsl:include href="coreFunctions.xsl"/>
  
  <xsl:template match="mods:mods">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates
        select="*[not( 
                (local-name()='name' and starts-with(@ID,'N') and string-length(@ID)=6 and @type='corporate') 
                or 
                (starts-with(@xlink:href,'#N') and string-length(@xlink:href)=6) 
                or 
                (starts-with(mods:physicalLocation/@xlink:href,'#N') and string-length(mods:physicalLocation/@xlink:href)=6) 
            )]" />
      <xsl:for-each select="mods:name[starts-with(@ID,'N') and string-length(@ID)=6  and @type='corporate']">
        
        <xsl:variable name="newid" select="concat(@ID,'-',(floor(math:random()*100000) mod 100000) + 1)"/>
        <xsl:variable name="ID"    select="@ID" />

        <xsl:copy>
          <xsl:attribute name="ID">
            <xsl:value-of select="$newid" />
          </xsl:attribute>
          <xsl:apply-templates select="@* [not (name(.)='ID')] " />
          <xsl:apply-templates />
        </xsl:copy> 
        
        <xsl:apply-templates select="../*[@xlink:href=concat('#',$ID) or mods:physicalLocation/@xlink:href=concat('#',$ID)]" mode="replaceID">
          <xsl:with-param name="newid" select="$newid"/>
        </xsl:apply-templates>
        
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mods:note|mods:physicalLocation" mode="replaceID">
    <xsl:param name="newid"/>
    <xsl:copy>
      <xsl:attribute name="xlink:href">
        <xsl:value-of select="concat('#',$newid)" />
      </xsl:attribute>
      <xsl:apply-templates select="@* [not (name(.)='xlink:href')] " />
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template> 
  
  <xsl:template match="mods:location" mode="replaceID">
    <xsl:param name="newid"/>
    <xsl:copy>
      <xsl:apply-templates select="@* [not (name(.)='xlink:href')] " />
      <xsl:apply-templates select="*" mode="replaceID">
        <xsl:with-param name="newid" select="$newid"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>