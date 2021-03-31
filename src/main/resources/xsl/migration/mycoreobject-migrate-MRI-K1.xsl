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
  
  <xsl:template match="mods:genre[@valueURI='https://www.openagrar.de/classifications/genres#article']" mode="replaceArticle">
    <xsl:if test="../mods:genre[@valueURI='https://www.openagrar.de/classifications/genres#poster']">
      <mods:genre type="intern" authorityURI="https://www.openagrar.de/classifications/genres" valueURI="https://www.openagrar.de/classifications/genres#abstract"/>
    </xsl:if>
    <xsl:if test="../mods:genre[@valueURI='https://www.openagrar.de/classifications/genres#proceedings']">
      <mods:genre type="intern" authorityURI="https://www.openagrar.de/classifications/genres" valueURI="https://www.openagrar.de/classifications/genres#abstract"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="mods:mods">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:choose>
        <xsl:when test="
            mods:classification[
              ( 
                @valueURI='https://www.openagrar.de/classifications/annual_review#c24023bb-e788-4edc-b59e-a6396fc4ddf6'
                or @valueURI='https://www.openagrar.de/classifications/annual_review#2827aa42-40d3-456b-98bf-79986cd95f3c'
                or @valueURI='https://www.openagrar.de/classifications/annual_review#b3145e6e-2e67-400f-8ec6-d6984a59357c'
              )
            ] 
            and 
            mods:genre[
              (
                @valueURI='https://www.openagrar.de/classifications/genres#poster'
                or @valueURI='https://www.openagrar.de/classifications/genres#speech'
                or @valueURI='https://www.openagrar.de/classifications/genres#article'
              )
            ]
            and 
            not (mods:genre[
              
                @valueURI='https://www.openagrar.de/classifications/genres#abstract'
              
            ])
            ">
          <xsl:apply-templates  select="*[not(@valueURI='https://www.openagrar.de/classifications/genres#article')]" />
          <mods:genre type="intern" authorityURI="https://www.openagrar.de/classifications/genres" valueURI="https://www.openagrar.de/classifications/genres#abstract"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates  select="*"/>
        </xsl:otherwise>
      </xsl:choose>
      
    </xsl:copy>
    
  </xsl:template>
  
</xsl:stylesheet>