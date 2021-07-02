<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:math="http://exslt.org/math"
  xmlns:mcrdataurl="xalan://org.mycore.datamodel.common.MCRDataURL">
  
  <xsl:include href="copynodes.xsl" />
    
  <xsl:template match="mods:mods/mods:extension[@displayLabel='characteristics']">
    <xsl:if test="chars[@refereed='yes']" >
      <mods:extension displayLabel="characteristics">
        <chars refereed="yes"/>
      </mods:extension>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="mods:mods/mods:extension[@displayLabel='metrics']/journalMetrics/metric[@type='JCR']">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="*" />
      <xsl:call-template name="addJCR"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mods:mods/mods:extension[@displayLabel='metrics']/journalMetrics[ not (metric[@type='JCR'])]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="*" />
      <metric type="JCR">
        <xsl:call-template name="addJCR"/>
      </metric>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mods:mods/mods:extension[@displayLabel='metrics' and not(journalMetrics)]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="*" />
      <journalMetrics>
        <metric type="JCR">
          <xsl:call-template name="addJCR"/>
        </metric>
      </journalMetrics>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mods:mods[not(mods:extension[@displayLabel='metrics'])]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="*" />
      <mods:extension displayLabel="metrics">
        <journalMetrics>
          <metric type="JCR">
            <xsl:call-template name="addJCR"/>
          </metric>
        </journalMetrics>
      </mods:extension>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="addJCR">
    <xsl:for-each select="//mods:extension[@displayLabel='characteristics']/chars[@factor]">
      <xsl:variable name="year" select="@year" />
      <xsl:if test="not (//mods:mods/mods:extension[@displayLabel='metrics']/journalMetrics/metric[@type='JCR']/value[@year=$year])">
        <value year="{$year}">
          <xsl:value-of select="@factor"/>
        </value>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>  
  
  
</xsl:stylesheet>