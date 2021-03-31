<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="mods mcrxsl xlink"
>

  <xsl:template name="getDateStatistic">
    <!-- central template to make the choice which date is used for grouping document in the statistic -->
    <xsl:param name = "mods" />
    
    <xsl:variable name="dateIssued">
      <xsl:call-template name="date2number">
        <xsl:with-param name="date" select="$mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="dateIssued_print">
      <xsl:call-template name="date2number">
        <xsl:with-param name="date" select="$mods/mods:originInfo[@eventType='publication_print']/mods:dateIssued[@encoding='w3cdtf']"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="dateIssued_online">
      <xsl:call-template name="date2number">
        <xsl:with-param name="date" select="$mods/mods:originInfo[@eventType='publication_online']/mods:dateIssued[@encoding='w3cdtf']"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- return value -->
    <xsl:choose>
      <xsl:when test="$dateIssued &lt;= $dateIssued_online and $dateIssued &lt;= $dateIssued_print">
        <xsl:value-of select="$mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']"/>
      </xsl:when>
      <xsl:when test="$dateIssued_online &lt; $dateIssued and $dateIssued_online &lt; $dateIssued_print">
        <xsl:value-of select="$mods/mods:originInfo[@eventType='publication_online']/mods:dateIssued[@encoding='w3cdtf']"/>
      </xsl:when>
      <xsl:when test="$dateIssued_print &lt; $dateIssued_online and $dateIssued_print &lt; $dateIssued">
        <xsl:value-of select="$mods/mods:originInfo[@eventType='publication_print']/mods:dateIssued[@encoding='w3cdtf']"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'Error: no date selected.'"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template> 
  
  <xsl:template name="date2number">
    <xsl:param name = "date" />
    <xsl:choose>
      <xsl:when test="10 = string-length($date)">
        <xsl:value-of select="translate($date,'-','')"/>
      </xsl:when>
      <xsl:when test="7 = string-length($date)">
        <xsl:value-of select="translate(concat($date,'-00'),'-','')"/>
      </xsl:when>
      <xsl:when test="4 = string-length($date)">
        <xsl:value-of select="translate(concat($date,'-00-00'),'-','')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'99990000'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template> 

</xsl:stylesheet>