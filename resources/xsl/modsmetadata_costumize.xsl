<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:mcr="http://www.mycore.org/"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:ns1="http://rdfs.org/ns/void#"
  exclude-result-prefixes="xalan xlink mcr mcrxsl i18n acl mods mcrmods rdf ns1"
  version="1.0">
  
  <xsl:template name="printMetaDate.mods.relatedItem">
    <xsl:param name="parentID" />
    <xsl:param name="label" />

    <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@xlink:href=$parentID]">
      <tr>
        <td valign="top" class="metaname">
          <xsl:value-of select="concat($label,':')" />
        </td>
        <td class="metavalue">
          <!-- Parent/Host -->
          <xsl:choose>
            <xsl:when test="string-length($parentID)!=0">
              <xsl:call-template name="objectLink">
                <xsl:with-param select="$parentID" name="obj_id" />
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="mods:titleInfo/mods:title" />
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text disable-output-escaping="yes">&lt;br /></xsl:text>
          <!-- Volume -->
          <xsl:if test="mods:part/mods:detail[@type='volume']/mods:number">
            <xsl:value-of
              select="concat('Vol. ',mods:part/mods:detail[@type='volume']/mods:number)" />
            <xsl:if test="mods:part/mods:detail[@type='issue']/mods:number">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:if>
          <!-- Issue -->
          <xsl:if test="mods:part/mods:detail[@type='issue']/mods:number">
            <xsl:value-of
              select="concat('H. ',mods:part/mods:detail[@type='issue']/mods:number)" />
          </xsl:if>
          <xsl:if test="mods:part/mods:detail[@type='issue']/mods:number and (mods:part/mods:date or mods:originInfo[@eventType='publication']/mods:dateIssued)">
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:if test="mods:part/mods:date or mods:originInfo[@eventType='publication']/mods:dateIssued[not(@point='start')][not(@point='end')]">
            <xsl:choose>
              <xsl:when test="mods:part/mods:date"><xsl:value-of select="concat('(',mods:part/mods:date,')')" /></xsl:when>
              <xsl:otherwise>
                <xsl:text>(</xsl:text>
                <xsl:apply-templates select="mods:originInfo[@eventType='publication']/mods:dateIssued" mode="formatDate" />
                <xsl:text>)</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="mods:part/mods:extent[@unit='pages']">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:if>
          <!-- Pages -->
          <xsl:if test="mods:part/mods:extent[@unit='pages']">
            <xsl:for-each select="mods:part/mods:extent[@unit='pages']">
              <xsl:call-template name="printMetaDate.mods.extent" />
            </xsl:for-each>
          </xsl:if>
        </td>
      </tr>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>