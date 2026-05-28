<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xlink" version="1.0"
>

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:mods">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates 
        select="*[not( (local-name()='name' and @ID and @type='corporate')  or (contains(@authorityURI,'annual_review'))
        or (starts-with(@xlink:href,'#')) or 
        (starts-with(mods:physicalLocation/@xlink:href,'#')))]" />
      <xsl:for-each select="mods:name[@ID and @type='corporate']">
        <annualReviewComposit>
          <xsl:variable name="ID" select="@ID" />
          <xsl:choose>
            <xsl:when test="../mods:classification[@IDREF=$ID]">
              <xsl:apply-templates select=".|../*[@xlink:href=concat('#',$ID) or 
                mods:physicalLocation/@xlink:href=concat('#',$ID)] | ../*[@IDREF=$ID]" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select=".|../*[@xlink:href=concat('#',$ID) or 
                mods:physicalLocation/@xlink:href=concat('#',$ID)] | 
                ../mods:classification[contains(@authorityURI,'annual_review')]" />
            </xsl:otherwise>
          </xsl:choose>         
        </annualReviewComposit>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <!-- <xsl:template match="mods:classification[contains(@authorityURI,'annual_review')]"/> -->
  
  <!-- <xsl:template match="mods:affiliation[starts-with(@xlink:href,'https://www.openagrar.de/classifications/mir_institutes#']">
    <mods:affiliation>
      <xsl:attribute name="xlink:href">
        <xsl:value-of select="'https://www.openagrar.de/classifications/mir_institutes#'" />
      </xsl:attribute>
      <xsl:value-of select="substring-after(@xlink:href,'#')" />
    </mods:affiliation>
  </xsl:template> -->
  
  <xsl:template match="mods:relatedItem/mods:name[@ID]">
  </xsl:template>

  <xsl:template match="mods:relatedItem/mods:classification[@IDREF]">
  </xsl:template>
  
  <xsl:template match="mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value">
    <xsl:variable name="value" select="."/>
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:value-of select="document(concat('crypt:decrypt:jcr:',$value))/value"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mods:classification[@authority='dcatHVD']">
    <mods:classification authority="dcatHVD" displayLabel="dcatHVD">
      <xsl:value-of select="."/>
    </mods:classification>
  </xsl:template>

</xsl:stylesheet>
