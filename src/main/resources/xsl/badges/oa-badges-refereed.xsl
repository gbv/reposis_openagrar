<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="xslImport:badges:badges/oa-badges-refereed.xsl"/>
  <xsl:include href="resource:xsl/badges/mir-badges-style-template.xsl"/>

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
</xsl:stylesheet>
