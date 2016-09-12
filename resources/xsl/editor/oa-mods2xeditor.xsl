<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="http://www.mycore.org/" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport" xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mcrdataurl="xalan://org.mycore.datamodel.common.MCRDataURL" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="mcrmods xlink mcr mcrxml mcrdataurl exslt" version="1.0"
>

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mods:mods">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates
        select="*[not( (local-name()='name' and @ID and @type='corporate') or (starts-with(@xlink:href,'#')) or (starts-with(mods:physicalLocation/@xlink:href,'#')) )]" />
      <xsl:for-each select="mods:name[@ID and @type='corporate']">
        <noteLocationCorp>
          <xsl:variable name="ID" select="@ID" />
          <xsl:apply-templates select=".|../*[@xlink:href=concat('#',$ID) or mods:physicalLocation/@xlink:href=concat('#',$ID)]" />
        </noteLocationCorp>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>