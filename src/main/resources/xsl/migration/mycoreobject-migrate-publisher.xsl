<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:math="http://exslt.org/math"
  xmlns:mcrdataurl="xalan://org.mycore.datamodel.common.MCRDataURL">

  <xsl:include href="copynodes.xsl" />
  <xsl:include href="editor/mods-node-utils.xsl" />
  <xsl:include href="mods-utils.xsl"/>
  <xsl:include href="coreFunctions.xsl"/>

  <xsl:template match="mods:mods">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
      <xsl:if test="mods:originInfo[@eventType='publication']/mods:publisher and //servflag[@type='modifiedby']/text()='administrator' and //structure/children">
        <xsl:apply-templates select="//servdate[@type='modifydate']" mode="updateModifyDate" />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="servdate[@type='modifydate']" mode="updateModifyDate">
    <servdate type="modifydate" inherited="0">
      <xsl:choose>
        <xsl:when test="contains(.,'2017-03-27')">
          <xsl:value-of select="concat('2017-03-28',substring-after(.,'2017-03-27'))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </servdate>
  </xsl:template>

</xsl:stylesheet>