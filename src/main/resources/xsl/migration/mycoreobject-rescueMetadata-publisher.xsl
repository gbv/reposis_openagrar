<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink" version="1.0">
  <xsl:include href="copynodes.xsl" />
  
  <xsl:variable name="objId" select="/mycoreobject/@ID" />



  <!-- <xsl:template match="mods:mods[mods:originInfo[@eventType='publication']]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
	  <xsl:apply-templates select="node()" />
      <xsl:apply-templates select="mods:originInfo[@eventType='publication']" />
    </xsl:copy>
  </xsl:template>
   
  <xsl:template match="mods:originInfo[@eventType='publication']">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
	  <xsl:apply-templates select="node()" />
      
      <xsl:variable name="versions" select="document(concat('versioninfo:', $objId))" />
      <xsl:variable name="versionCandidates" select="$versions/versions/version" />
      
      <xsl:if test="not(mods:publisher)">
        <xsl:call-template name="copyPublisher">
          <xsl:with-param name="pos" select="count($versionCandidates)" />
          <xsl:with-param name="versions" select="$versionCandidates" />
        </xsl:call-template>
      </xsl:if>
      
      <xsl:if test="not(mods:place)">
        <xsl:call-template name="copyPlace">
          <xsl:with-param name="pos" select="count($versionCandidates)" />
          <xsl:with-param name="versions" select="$versionCandidates" />
        </xsl:call-template>
      </xsl:if>
	  
    </xsl:copy>
  </xsl:template>
   -->
  <xsl:template match="mods:mods[not(mods:originInfo[@eventType='publication'])]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
	  <xsl:apply-templates select="node()" />

      <xsl:variable name="versions" select="document(concat('versioninfo:', $objId))" />
      <!-- versions are listed from first to current version -->
      <xsl:variable name="versionCandidates" select="$versions/versions/version" />
      <xsl:call-template name="copyOriginInfo">
        <xsl:with-param name="pos" select="count($versionCandidates)" />
        <xsl:with-param name="versions" select="$versionCandidates" />
      </xsl:call-template>
	  
    </xsl:copy>
  </xsl:template>

  <xsl:template name="copyPublisher">
    <xsl:param name="versions" />
    <xsl:param name="pos" />
    <xsl:if test="$pos &gt; 0 and $versions[$pos]">
      <xsl:variable name="oldRev" select="document(concat('notnull:mcrobject:',$objId,'?r=',$versions[$pos]/@r))"/>
      <xsl:variable name="publisher" select="$oldRev/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[not(@eventType)]/mods:publisher" />
      <!-- <xsl:variable name="nameID" select="$name/@ID" /> -->
      <xsl:choose>
        <xsl:when test="$publisher">
          <xsl:copy-of select="$publisher"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="copyPublisher">
            <xsl:with-param name="versions" select="$versions" />
            <xsl:with-param name="pos" select="$pos - 1" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="copyPlace">
    <xsl:param name="versions" />
    <xsl:param name="pos" />
    <xsl:if test="$pos &gt; 0 and $versions[$pos]">
      <xsl:variable name="oldRev" select="document(concat('notnull:mcrobject:',$objId,'?r=',$versions[$pos]/@r))"/>
      <xsl:variable name="place" select="$oldRev/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[not(@eventType)]/mods:place" />
      <!-- <xsl:variable name="nameID" select="$name/@ID" /> -->
      <xsl:choose>
        <xsl:when test="$place">
          <xsl:copy-of select="$place"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="copyPlace">
            <xsl:with-param name="versions" select="$versions" />
            <xsl:with-param name="pos" select="$pos - 1" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="copyOriginInfo">
    <xsl:param name="versions" />
    <xsl:param name="pos" />
    <xsl:if test="$pos &gt; 0 and $versions[$pos]">
      <xsl:variable name="oldRev" select="document(concat('notnull:mcrobject:',$objId,'?r=',$versions[$pos]/@r))"/>
      <xsl:variable name="originInfo" select="$oldRev/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[not(@eventType)]" />
      <!-- <xsl:variable name="nameID" select="$name/@ID" /> -->
      <xsl:choose>
        <xsl:when test="$originInfo">
          <xsl:copy-of select="$originInfo"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="copyOriginInfo">
            <xsl:with-param name="versions" select="$versions" />
            <xsl:with-param name="pos" select="$pos - 1" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
