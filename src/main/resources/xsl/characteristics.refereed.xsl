<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="mods mcrxsl xlink"
>

  <xsl:template name="getCharacteristicsRefereed">
    <!-- central template to make the choice which state (no,yes,n/a) should be indexed -->
    <xsl:param name = "mods" />
    <xsl:choose>
      <xsl:when test="$mods/mods:extension/chars/@refereed='yes'">
        <refereed value="yes" level="1"/>
      </xsl:when>
      <xsl:when test="$mods/mods:extension/chars/@refereed='no'">
        <refereed value="no" level="1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$mods/mods:relatedItem[@type='host' or @type='series']/mods:extension/chars/@refereed='yes'">
            <refereed value="yes" level="2"/>
          </xsl:when>
          <xsl:when test="$mods/mods:relatedItem[@type='host' or @type='series']/mods:extension/chars/@refereed='no'">
            <refereed value="no" level="2"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$mods/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension/chars/@refereed='yes'">
                <refereed value="yes" level="3"/>
              </xsl:when>
              <xsl:when test="$mods/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension/chars/@refereed='no'">
                <refereed value="no" level="3"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="$mods/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension/chars/@refereed='yes'">
                    <refereed value="yes" level="4"/>
                  </xsl:when>
                  <xsl:when test="$mods/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:relatedItem[@type='host' or @type='series']/mods:extension/chars/@refereed='no'">
                    <refereed value="no" level="4"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <refereed value="n/a" level="0"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template> 
  
</xsl:stylesheet>