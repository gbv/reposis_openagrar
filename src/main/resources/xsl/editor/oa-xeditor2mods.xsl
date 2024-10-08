<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mcr="http://www.mycore.org/"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:math="http://exslt.org/math"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  exclude-result-prefixes="xlink mcr acl" version="1.0"
>

  <xsl:template match="annualReviewComposit">
    <xsl:variable name="repeaterId">
      <xsl:choose>
        <xsl:when test="mods:name/@ID">
          <xsl:value-of select="mods:name/@ID" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat(generate-id(.),'-',(floor(math:random()*100000) mod 100000) + 1)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:apply-templates select="mods:name" mode="addIDToName">
      <xsl:with-param name="ID" select="$repeaterId" />
    </xsl:apply-templates>
    <xsl:for-each select="mods:classification[@authorityURI='https://www.openagrar.de/classifications/annual_review']">
      <xsl:copy>
        <xsl:attribute name="IDREF">
          <xsl:value-of select="$repeaterId" />
        </xsl:attribute>
        <xsl:apply-templates select='@*|node()' />
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="mods:note">
      <xsl:copy>
        <xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
          <xsl:value-of select="concat('#',$repeaterId)" />
        </xsl:attribute>
        <xsl:apply-templates select='@*|node()' />
      </xsl:copy>
    </xsl:for-each>
    <xsl:for-each select="mods:location">
      <xsl:copy>
        <xsl:for-each select="mods:physicalLocation">
          <xsl:copy>
            <xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
          <xsl:value-of select="concat('#',$repeaterId)" />
        </xsl:attribute>
            <xsl:apply-templates select='@*|node()' />
          </xsl:copy>
        </xsl:for-each>
      </xsl:copy>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mods:classification[contains(@authorityURI,'annual_review') and not(@IDREF)]"/> 

  <xsl:template match="mods:name" mode="addIDToName">
    <xsl:param name="ID" />
    <xsl:copy>
      <xsl:attribute name="ID">
        <xsl:value-of select="$ID" />
      </xsl:attribute>
      <xsl:apply-templates select='@*|node()' />
    </xsl:copy>
  </xsl:template>
  

  <!-- <xsl:template match="mods:affiliation[@xlink:href='https://www.openagrar.de/classifications/mir_institutes#']">
    <mods:affiliation>
      <xsl:attribute name="xlink:href">
        <xsl:value-of select="concat('https://www.openagrar.de/classifications/mir_institutes#',.)" />
      </xsl:attribute>
    </mods:affiliation>
  </xsl:template> -->

  <xsl:template match="mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value">
    <xsl:variable name="value" select="."/>
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:choose>
        <xsl:when test="acl:checkPermission('crypt:cipher:jcr','encrypt')">
          <xsl:value-of select="document(concat('crypt:encrypt:jcr:',$value))/value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$value"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
