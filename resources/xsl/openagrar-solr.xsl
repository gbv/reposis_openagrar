<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="mods mcrxsl xlink">
  <xsl:import href="xslImport:solr-document:openagrar-solr.xsl" />

  <xsl:template match="mycoreobject[contains(@ID,'_mods_')]">
    <xsl:variable name="status" select="mcrxml:isInCategory(@ID,'state:published')" />
    <xsl:apply-imports />
    <!-- fields from mycore-mods -->
    <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/mods:mods" mode="oa" />
  </xsl:template>

  <xsl:template match="mods:mods" mode="oa">
    <xsl:for-each select="mods:location/mods:physicalLocation">
      <field name="mods.physicalLocation">
        <xsl:value-of select="." />
      </field>
    </xsl:for-each>
    <xsl:for-each select="mods:classification[@displayLabel='annual_review']">
      <field name="mods.annual_review">
        <xsl:value-of select="@edition" />
      </field>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>