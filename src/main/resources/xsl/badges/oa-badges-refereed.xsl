<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:exslt="http://exslt.org/common"
                exclude-result-prefixes="mods exslt">

  <xsl:import href="xslImport:badges:badges/oa-badges-refereed.xsl"/>
  <xsl:include href="resource:xsl/badges/mir-badges-style-template.xsl"/>
  <xsl:include href="resource:xsl/characteristics.refereed.xsl"/>

  <xsl:variable name="label-refereed" select="document('i18n:oa.refereed')/i18n/text()"/>

  <xsl:template match="doc" mode="resultList">
    <xsl:apply-imports/>

    <xsl:if test="str[@name='mods.refereed']='yes'">
      <xsl:call-template name="output-badge">
        <xsl:with-param name="of-type" select="'hit_refereed'"/>
        <xsl:with-param name="badge-type" select="'badge-primary'"/>
        <xsl:with-param name="label" select="$label-refereed"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="mycoreobject-badge">
    <xsl:apply-imports/>

    <xsl:variable name="refereed">
      <xsl:call-template name="getCharacteristicsRefereed">
        <xsl:with-param name="mods" select="//mods:mods"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="exslt:node-set($refereed)/refereed/@value='yes'">
      <xsl:call-template name="output-badge">
        <xsl:with-param name="of-type" select="'oa_refereed'"/>
        <xsl:with-param name="badge-type" select="'badge-info'"/>
        <xsl:with-param name="label" select="$label-refereed"/>
        <xsl:with-param name="tooltip" select="$label-refereed"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
