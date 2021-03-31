<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
                version="1.0">
  <xsl:include href="copynodes.xsl" />
  <xsl:variable name="failUser" select="'administrator'" />
  <xsl:variable name="objId" select="/mycoreobject/@ID" />
  <xsl:template match="mods:mods[not(mods:titleInfo)]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />

      <xsl:variable name="versions" select="document(concat('versioninfo:', $objId))" />
      <!-- versions are listed from first to current version -->
      <xsl:variable name="versionCandidates" select="$versions/versions/version[following-sibling::version/@user=$failUser]" />
      <xsl:call-template name="copyTitle">
        <xsl:with-param name="pos" select="count($versionCandidates)" />
        <xsl:with-param name="versions" select="$versionCandidates" />
      </xsl:call-template>

      <xsl:apply-templates select="node()" />

    </xsl:copy>
  </xsl:template>

  <!-- handles revisions in reverse order (from new to older) -->
  <xsl:template name="copyTitle">
    <xsl:param name="versions" />
    <xsl:param name="pos" />
    <xsl:if test="$pos &gt; 0 and $versions[$pos]">
      <xsl:variable name="oldRev" select="document(concat('notnull:mcrobject:',$objId,'?r=',$versions[$pos]/@r))"/>
      <xsl:variable name="titleInfo" select="$oldRev/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo" />
      <xsl:choose>
        <xsl:when test="$titleInfo">
          <xsl:copy-of select="$titleInfo" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="copyTitle">
            <xsl:with-param name="versions" select="$versions" />
            <xsl:with-param name="pos" select="$pos - 1" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
