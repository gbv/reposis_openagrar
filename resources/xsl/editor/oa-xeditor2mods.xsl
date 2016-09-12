<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mcr="http://www.mycore.org/"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xlink mcr" version="1.0"
>

  <xsl:template match="noteLocationCorp">
    <xsl:variable name="repeaterId">
      <xsl:choose>
        <xsl:when test="mods:name/@ID">
          <xsl:value-of select="mods:name/@ID" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="generate-id(.)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:apply-templates select="mods:name" mode="addIDToName">
      <xsl:with-param name="ID" select="$repeaterId" />
    </xsl:apply-templates>
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

  <xsl:template match="mods:name" mode="addIDToName">
    <xsl:param name="ID" />
    <xsl:copy>
      <xsl:attribute name="ID">
        <xsl:value-of select="$ID" />
      </xsl:attribute>
      <xsl:apply-templates select='@*|node()' />
    </xsl:copy>
  </xsl:template>


</xsl:stylesheet>