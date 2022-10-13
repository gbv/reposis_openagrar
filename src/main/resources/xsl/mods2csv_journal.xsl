<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xalan="http://xml.apache.org/xalan" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:ex="http://exslt.org/dates-and-times" 
  exclude-result-prefixes="xalan i18n">
  <xsl:param name="CurrentLang" />

  <xsl:output
    encoding="UTF-8"
    media-type="text/csv"
    method="text"
    standalone="yes"
    indent="no" />


  <xsl:strip-space elements="*"/>


<!-- ************************************************************************************ -->
<!-- Main-Template                                                                        -->
<!-- ************************************************************************************ -->

  <xsl:template match="/">
    <xsl:variable name="year" select="ex:year()"/>
    <xsl:variable name="year1Yb" select="$year - 1"/>
    <xsl:variable name="year2Yb" select="$year - 2"/>
    <xsl:variable name="year3Yb" select="$year - 3"/>
    <xsl:variable name="year4Yb" select="$year - 4"/>
    <xsl:text>Titel;Nebensachtitel;Autoren;Herausgeber;Genre;ISSN;Verlag;Verlagsort;Veröffentlichung;referiert;</xsl:text>
    <xsl:value-of select="concat('JCR_',$year,';JCR_',$year1Yb,';JCR_',$year2Yb,';JCR_',$year3Yb,';JCR_',$year4Yb)"/>
    <xsl:text>&#xA;</xsl:text>
    <xsl:for-each select="//mods:mods">
      <xsl:call-template name="convertToCsv" />
      <xsl:text>&#xA;</xsl:text>
    </xsl:for-each>
  </xsl:template>


  <xsl:template name="convertToCsv">
    <!-- Titel --><!-- TODO: [@type!='translated' and @transliteration!='text/html'] -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:titleInfo/mods:title" />
    </xsl:call-template>

    <!-- Nebensachtitel --><!-- TODO: [@type!='translated' and @transliteration!='text/html'] -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:titleInfo/mods:subTitle" />
    </xsl:call-template>

    <!-- Autoren -->
    <xsl:text>&quot;</xsl:text>
      <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='aut']">
        <xsl:if test="position()!=1">
          <xsl:value-of select="'; '" />
        </xsl:if>
        <xsl:apply-templates select="." mode="printName" />
      </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Herausgeber -->
    <xsl:text>&quot;</xsl:text>
      <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='edt']">
        <xsl:if test="position()!=1">
          <xsl:value-of select="'; '" />
        </xsl:if>
        <xsl:apply-templates select="." mode="printName" />
      </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Genre -->
    <xsl:variable name="modsType">
      <xsl:value-of select="substring-after(mods:genre[@type='intern']/@valueURI,'#')" />
    </xsl:variable>
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="document(concat('classification:metadata:0:children:mir_genres:',$modsType))//category/label[@xml:lang=$CurrentLang]/@text" />
    </xsl:call-template>

    <!-- Identifier (ISSN,ISBN,URL?) -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:identifier[@type='issn']" />
    </xsl:call-template>

    <!-- Verlag -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select=".//mods:originInfo/mods:publisher" />
    </xsl:call-template>

    <!-- Verlagsort -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select=".//mods:originInfo/mods:place/mods:placeTerm[@type='text']" />
    </xsl:call-template>

    <!-- Jahr der Veröffentlichung -->
    <xsl:choose>
      <xsl:when test="mods:originInfo/mods:dateIssued">
        <xsl:call-template name="convertStringToCsv">
          <xsl:with-param name="cstring" select="mods:originInfo/mods:dateIssued" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="convertStringToCsv">
          <xsl:with-param name="cstring" select="mods:relatedItem[@type='host']/mods:originInfo/mods:dateIssued" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

    <!-- referiert -->
    <xsl:variable name="refereed">
      <xsl:value-of select="document(concat('solr:q=id:',@ID, '&amp;fl=mods.refereed'))//str[@name='mods.refereed']" />
    </xsl:variable>
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="$refereed" />
    </xsl:call-template>

   
    <!-- IP Factors of the last 5 Years -->
    <xsl:variable name="year" select="ex:year()"/>
    <xsl:variable name="year1Yb" select="$year - 1"/>
    <xsl:variable name="year2Yb" select="$year - 2"/>
    <xsl:variable name="year3Yb" select="$year - 3"/>
    <xsl:variable name="year4Yb" select="$year - 4"/>
    <xsl:text>&quot;</xsl:text>
    <xsl:value-of select="mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year = $year]"/>
    <xsl:text>&quot;;</xsl:text>
    <xsl:text>&quot;</xsl:text>
    <xsl:value-of select="mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year = $year1Yb]"/>
    <xsl:text>&quot;;</xsl:text>
    <xsl:text>&quot;</xsl:text>
    <xsl:value-of select="mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year = $year2Yb]"/>
    <xsl:text>&quot;;</xsl:text>
    <xsl:text>&quot;</xsl:text>
    <xsl:value-of select="mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year = $year3Yb]"/>
    <xsl:text>&quot;;</xsl:text>
    <xsl:text>&quot;</xsl:text>
    <xsl:value-of select="mods:extension[@type='metrics']/journalMetrics/metric[@type='JCR']/value[@year = $year4Yb]"/>
    <xsl:text>&quot;</xsl:text>
    
  </xsl:template>



<!-- ************************************************************************************ -->
<!-- Helper templates                                                                     -->
<!-- ************************************************************************************ -->

  <xsl:template name="convertStringToCsv">
    <xsl:param name="cstring" />
     <xsl:choose>
       <xsl:when test="not(contains($cstring, '&quot;'))">
         <xsl:value-of select="concat('&quot;', $cstring, '&quot;;')"></xsl:value-of>
       </xsl:when>
       <xsl:otherwise>
         <xsl:text>&quot;</xsl:text>
         <xsl:call-template name="doubleQuoteValue">
           <xsl:with-param name="value" select="$cstring"/>
         </xsl:call-template>
         <xsl:text>&quot;;</xsl:text>
       </xsl:otherwise>
     </xsl:choose>
  </xsl:template>

  <xsl:template name="doubleQuoteValue">
    <xsl:param name="value" />
     <xsl:choose>
       <xsl:when test="not(contains($value, '&quot;'))">
         <xsl:value-of select="$value"></xsl:value-of>
       </xsl:when>
       <xsl:otherwise>
         <xsl:value-of select="concat(substring-before($value, '&quot;'), '&quot;&quot;')" />
         <xsl:call-template name="doubleQuoteValue">
           <xsl:with-param name="value" select="substring-after($value, '&quot;')"/>
         </xsl:call-template>
       </xsl:otherwise>
     </xsl:choose>
  </xsl:template>

  <!-- copied from modsmetadata.xsl -->
  <xsl:template match="mods:name" mode="printName">
    <xsl:choose>
      <xsl:when test="mods:namePart">
        <xsl:choose>
          <xsl:when test="mods:namePart[@type='given'] and mods:namePart[@type='family']">
            <xsl:value-of select="concat(mods:namePart[@type='family'], ', ',mods:namePart[@type='given'])" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mods:namePart" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="mods:displayForm">
        <xsl:value-of select="mods:displayForm" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:extent" mode="printExtent">
    <xsl:choose>
      <xsl:when test="count(mods:start) &gt; 0">
        <xsl:choose>
          <xsl:when test="count(mods:end) &gt; 0">
            <xsl:value-of select="concat(mods:start,'-',mods:end)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mods:start" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="mods:total">
        <xsl:value-of select="mods:total" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
