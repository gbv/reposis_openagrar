<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink" version="1.0">
  <xsl:include href="copynodes.xsl" />
  <xsl:variable name="failUser" select="'administrator'" />
  <xsl:variable name="objId" select="/mycoreobject/@ID" />



  <xsl:template match="mods:mods[not(mods:name[@ID][@type='corporate'][mods:role/mods:roleTerm='his'])]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
	  <xsl:apply-templates select="node()" />

      <xsl:variable name="versions" select="document(concat('versioninfo:', $objId))" />
      <!-- versions are listed from first to current version -->
      <xsl:variable name="versionCandidates" select="$versions/versions/version[following-sibling::version/@user=$failUser]" />
      <xsl:call-template name="copyAndMigrateIntitute">
        <xsl:with-param name="pos" select="count($versionCandidates)" />
        <xsl:with-param name="versions" select="$versionCandidates" />
      </xsl:call-template>
	  
    </xsl:copy>
  </xsl:template>

  <xsl:template name="copyAndMigrateIntitute">
    <xsl:param name="versions" />
    <xsl:param name="pos" />
    <xsl:if test="$pos &gt; 0 and $versions[$pos]">
      <xsl:variable name="oldRev" select="document(concat('notnull:mcrobject:',$objId,'?r=',$versions[$pos]/@r))"/>
      <xsl:variable name="name" select="$oldRev/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:name[@ID][@type='corporate'][mods:role/mods:roleTerm='institution']" />
      <xsl:variable name="nameID" select="$name/@ID" />
      <xsl:choose>
        <xsl:when test="$name">
          <mods:name>
            <xsl:copy-of select="$name/@*[not (name(.)='authorityURI' or name(.)='valueURI')]"/>
            <xsl:copy-of select="$name/* [not (name(.)='mods:role')]"/>
            
            <xsl:variable name="institut" select="substring-after($name/@valueURI,'#')"/>
            <xsl:attribute name="authorityURI">
              <xsl:value-of select="'https://www.openagrar.de/classifications/institutes'" />
            </xsl:attribute>
            <xsl:attribute name="valueURI">
              <xsl:value-of select="concat('https://www.openagrar.de/classifications/institutes#',$institut)" />
            </xsl:attribute>
            <mods:role><mods:roleTerm authority="marcrelator" type="code">his</mods:roleTerm></mods:role>
          </mods:name>
          <xsl:copy-of select="$oldRev/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:note[@xlink:href=$nameID]"/>
          <xsl:copy-of select="$oldRev/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:location[mods:physicalLocation/@xlink:href=$nameID]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="copyAndMigrateIntitute">
            <xsl:with-param name="versions" select="$versions" />
            <xsl:with-param name="pos" select="$pos - 1" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
