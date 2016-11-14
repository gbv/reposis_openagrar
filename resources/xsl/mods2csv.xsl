<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xalan="http://xml.apache.org/xalan" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" exclude-result-prefixes="xalan i18n">
  <xsl:param name="CurrentLang" />

  <xsl:output
    encoding="UTF-8"
    media-type="text/csv"
    method="text"
    standalone="yes"
    indent="no" />


  <xsl:strip-space elements="*"/>

<!--

zu klären:
- Identifikator (URL)?? - Entweder die URL, oder einen Identifikator



 Dokumenttyp Zeitschriftenartikel/Serie:
 - Autoren
 - Titel des Artikels
 - Titel der Zeitschrift/Serie
 - ISSN
 - Verlag
 - Seitenangaben
 - Heftangaben
 - Bandangaben
 - Jahr der Veröffentlichung
 - Jahresberichtskategorie
 - Institution (Organisationseinheit des BfR)

 Dokumenttyp Buchkapitel:
 - Autoren des Kapitels
 - Titel des Kapitels
 - Autoren des Buches
 - Titel des Buches
 - Seitenangaben des Kapitels
 - Verlag
 - Verlagsort
 - Jahr der Veröffentlichung
 - Jahresberichtskategorie
 - Institution (Organisationseinheit des BfR)

 Dokumenttyp Buch:
 - Autoren des Buches
 - Titel des Buches
 - Verlag
 - Verlagsort
 - Jahr der Veröffentlichung
 - Jahresberichtskategorie
 - Institution (Organisationseinheit des BfR)

 Dokumenttyp Konferenzbeitrag:
 - Genre (Aufsatz, Poster, Vortrag)
 - Titel der Konferenz
 - Zeitraum der Konferenz
 - Veranstaltungsort
 - Titel des Aufsatz, Poster, Vortrag
 - Autoren
 - Jahr der Veröffentlichung
 - Jahresberichtskategorie
 - Institution (Organisationseinheit des BfR)

 Dokumenttyp Konferenzband:
 - Titel des Buches
 - Autoren/Herausgeber
 - Verlag
 - Verlagsort
 - Identifikator (URL)
 - Jahr der Veröffentlichung
 - Jahresberichtskategorie
 - Institution (Organisationseinheit des BfR)

 Dokumenttyp Hochschulschrift:
 - Genre (Dissertation, Master-, Bachelorarbeit)
 - Titel des Hochschulschrift
 - Autor
 - Betreuer
 - Jahr der Veröffentlichung
 - Jahresberichtskategorie
 - Institution (Organisationseinheit des BfR)
-->


<!-- Type specific

  <xsl:include href="mods-utils.xsl" />

  <xsl:variable name="mods-type">
    <xsl:apply-templates mode="mods-type" select="." />
  </xsl:variable>

  <xsl:text xsl:lang="x-article">Titel;Autoren;in Zeitschrift/Serie;ISSN;Verlag;Seitenangaben;Heftangaben;Bandangaben;Jahr der Veröffentlichung;Jahresberichtskategorie;Institution&#xA;</xsl:text>
  <xsl:text xsl:lang="x-chapter">Titel;Autoren;Buch-Titel;Buch-Autoren;Verlag;Verlagsort;Seitenangaben;Jahr der Veröffentlichung;Jahresberichtskategorie;Institution&#xA;</xsl:text>
  <xsl:text xsl:lang="x-book">Titel;Autoren;Verlag;Verlagsort;Jahr der Veröffentlichung;Jahresberichtskategorie;Institution&#xA;</xsl:text>
  <xsl:text xsl:lang="x-confpub">Titel;Autoren;Konferenz-Titel;Konferenz-Zeitraum;Genre;Veranstaltungsort;Jahr der Veröffentlichung;Jahresberichtskategorie;Institution&#xA;</xsl:text>
  <xsl:text xsl:lang="x-confpro">Titel;Autoren;Herausgeber;Verlag;Verlagsort;Identifikator (URL);Jahr der Veröffentlichung;Jahresberichtskategorie;Institution&#xA;</xsl:text>
  <xsl:text xsl:lang="x-thesis">Titel;Autoren;Betreuer;Genre;Jahr der Veröffentlichung;Jahresberichtskategorie;Institution&#xA;</xsl:text>

-->

<!-- ************************************************************************************ -->
<!-- Main-Template                                                                        -->
<!-- ************************************************************************************ -->

  <xsl:template match="/">
    <xsl:text>Titel;Nebensachtitel;Autoren;Herausgeber;Betreuer;erschienen in;Buch-Autoren;Konferenz;Konferenz-Zeitraum;Veranstaltungsort;Genre;Seitenangaben;Heftangaben;Bandangaben;ISBN / ISSN;URN;DOI;Verlag;Verlagsort;Veröffentlichungsdatum;Jahresberichtskategorie;Institution&#xA;</xsl:text>
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

    <!-- Betreuer -->
    <xsl:text>&quot;</xsl:text>
      <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='ths']">
        <xsl:if test="position()!=1">
          <xsl:value-of select="'; '" />
        </xsl:if>
        <xsl:apply-templates select="." mode="printName" />
      </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Titel des Elternelementes -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:relatedItem[@type='host']/mods:titleInfo/mods:title" />
    </xsl:call-template>

    <!-- Autoren  des Elternelementes - XPath prüfen! -->
    <xsl:text>&quot;</xsl:text>
      <xsl:for-each select="mods:relatedItem[@type='host']/mods:name[mods:role/mods:roleTerm/text()='aut']">
        <xsl:if test="position()!=1">
          <xsl:value-of select="'; '" />
        </xsl:if>
        <xsl:apply-templates select="." mode="printName" />
      </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Konferenz -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select=".//mods:name[@type='conference']/mods:namePart[not(@type)]" />
    </xsl:call-template>

    <!-- Konferenz-Zeitraum -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select=".//mods:name[@type='conference']/mods:namePart[@type='date']" />
    </xsl:call-template>

    <!-- Veranstaltungsort -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select=".//mods:name[@type='conference']/mods:affiliation" />
    </xsl:call-template>

    <!-- Genre -->
    <xsl:variable name="modsType">
      <xsl:choose>
        <xsl:when test="mods:genre[@type='kindof']">
          <xsl:value-of select="substring-after(mods:genre[@type='kindof']/@valueURI,'#')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-after(mods:genre[@type='intern']/@valueURI,'#')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="document(concat('classification:metadata:0:children:bmelv_genres:',$modsType))//category/label[@xml:lang=$CurrentLang]/@text" />
    </xsl:call-template>

    <!-- Seitenangaben -->
    <xsl:text>&quot;</xsl:text>
    <xsl:choose>
      <xsl:when test="mods:relatedItem[@type='host']/mods:part/mods:extent[@unit='pages']">
        <xsl:apply-templates select="mods:relatedItem[@type='host']/mods:part/mods:extent[@unit='pages']" mode="printExtent" />
      </xsl:when>
      <xsl:when test="mods:physicalDescription/mods:extent[@unit='pages']">
        <xsl:apply-templates select="mods:physicalDescription/mods:extent[@unit='pages']" mode="printExtent" /></xsl:when>
      <xsl:when test="mods:physicalDescription/mods:extent">
        <xsl:apply-templates select="mods:physicalDescription/mods:extent" mode="printExtent" />
      </xsl:when>
    </xsl:choose>

    <xsl:text>&quot;;</xsl:text>

    <!-- Heftangaben -->
    <xsl:variable name="issue">
      <xsl:if test="mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:number">
        <xsl:value-of
          select="concat(mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:caption,' ',mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:number)" />
      </xsl:if>
      <xsl:if test="mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:number and mods:relatedItem[@type='host']/mods:part/mods:date">
        <xsl:text>/</xsl:text>
      </xsl:if>
      <xsl:if test="mods:relatedItem[@type='host']/mods:part/mods:date">
        <xsl:value-of select="concat(mods:relatedItem[@type='host']/mods:part/mods:date,' ')" />
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="$issue" />
    </xsl:call-template>

    <!-- Bandangaben -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume']" />
    </xsl:call-template>

    <!-- Identifier (ISSN,ISBN,URL?) -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select="mods:relatedItem[@type='host']/mods:identifier[@type='issn' or @type='isbn']" />
    </xsl:call-template>

    <!-- URN --><!-- only show own urn, not of host -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select=".//mods:identifier[@type='urn']" />
    </xsl:call-template>

    <!-- DOI --><!-- only show own urn, not of host -->
    <xsl:call-template name="convertStringToCsv">
      <xsl:with-param name="cstring" select=".//mods:identifier[@type='doi']" />
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

    <!-- Jahresberichtskategorie -->
    <xsl:text>&quot;</xsl:text>
      <xsl:for-each select="mods:classification[@displayLabel='annual_review']">
        <xsl:variable name="categ" select="substring-after(@valueURI, 'annual_review#')" />
        <xsl:value-of select="document(concat('classification:metadata:0:children:annual_review:',$categ))//category/label[@xml:lang=$CurrentLang]/@text" />
      </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

    <!-- Institution (Organisationseinheit des BfR) --><!-- TODO: check if empty, to prevent " ; ; MRI" -->
    <xsl:text>&quot;</xsl:text>
      <xsl:for-each select="mods:name[@type='corporate']">
        <xsl:if test="position()!=1">
          <xsl:value-of select="'; '" />
        </xsl:if>
        <xsl:variable name="institute" select="substring-after(@valueURI, 'institutes#')" />
        <xsl:value-of select="document(concat('classification:metadata:0:children:bmelv_institutes:',$institute))//category/label[@xml:lang=$CurrentLang]/@text" />
      </xsl:for-each>
    <xsl:text>&quot;;</xsl:text>

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
