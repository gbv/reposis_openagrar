<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:str="http://exslt.org/strings" xmlns:exslt="http://exslt.org/common" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" xmlns:basket="xalan://org.mycore.frontend.basket.MCRBasketManager"
  xmlns:decoder="xalan://java.net.URLDecoder" exclude-result-prefixes="i18n mods str exslt mcr acl mcrxsl basket encoder decoder"
>

  <xsl:include href="response-mir-utils.xsl" />

  <xsl:param name="UserAgent" />
  <xsl:param name="MIR.testEnvironment" />
  <xsl:param name="MCR.ORCID.OAuth.ClientSecret" select="''" />

  <xsl:variable name="maxScore" select="//result[@name='response'][1]/@maxScore" />
  
  <!-- START: OA specific changes -->
  <xsl:variable name="query">
  	<xsl:value-of select="$params/str[@name='q']"/>
  </xsl:variable>
  
  <xsl:variable name="instID">
    <xsl:if test="not (contains(substring-after($query,'mir_institutes:'),'mir_institutes:'))">
  	  <xsl:value-of select="substring-before(substring-after($query,'mir_institutes:'),'&quot;')"/>
  	</xsl:if>
  </xsl:variable>
  
  
  <xsl:variable name="institut_str">
  	<xsl:if test="string-length($instID) &gt; 0">
  	  <xsl:variable name="intitutes" select="document(concat('classification:metadata:0:parents:mir_institutes:',$instID))" />
      <xsl:for-each select="$intitutes//category/label[@xml:lang='de']">
        <xsl:value-of select="@text"/>
        <xsl:if test="not(position() = last())" >
      	  <xsl:value-of select="' &#8212; '"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:variable>
  
  <xsl:variable name="nameGND">
    <xsl:if test="not (contains(substring-after($query,'mods.nameIdentifier:'),'mods.nameIdentifier:'))">
      <xsl:choose>
        <xsl:when test="contains(substring-after($query,'mods.nameIdentifier:'),' ')">
          <xsl:value-of select="substring-after(substring-before(substring-after($query,'mods.nameIdentifier:'),' '),':')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-after(substring-after($query,'mods.nameIdentifier:'),':')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:variable>
  
  
  <xsl:variable name="name_str">
    <xsl:if test="string-length($nameGND) &gt; 0">
      <xsl:variable name="names" select="document(concat($WebApplicationBaseURL,'/servlets/solr/personindex?XSL.Style=xml&amp;terms.regex=.*:gnd:',$nameGND))" />
  	  <xsl:value-of select="substring-before($names//int[contains(@name,$nameGND)]/@name,':gnd')"/>
      
    </xsl:if>
  </xsl:variable>
  <!-- END: OA specific changes -->
  
        <xsl:template match="/response/result|lst[@name='grouped']/lst[@name='returnId']" priority="10">
    <xsl:variable name="ResultPages">
      <xsl:if test="($hits &gt; 0) and ($hits &gt; $rows)">
        <div class="pagination_box text-center">
          <xsl:call-template name="resultList.Pagination">
            <xsl:with-param name="id" select="'solr-result'" />
            <xsl:with-param name="numPerPage" select="$rows" />
            <xsl:with-param name="page" select="$currentPage" />
            <xsl:with-param name="pages" select="$totalPages" />
            <xsl:with-param name="class" select="'pagination-sm'" />
          </xsl:call-template>
        </div>
      </xsl:if>
    </xsl:variable>

    <div class="row result_head">
      <div class="col-xs-12 result_headline">
        <h1>
          <!-- START: OA specific changes -->
          <xsl:choose>
            <xsl:when test="string-length($institut_str) &gt; 0">
              <span class="resultText"><xsl:value-of select="i18n:translate('results.text')" /></span>
              <xsl:text> </xsl:text>
              <xsl:value-of select="$institut_str"/>
            </xsl:when>
            <xsl:when test="string-length($name_str) &gt; 0">
              <span class="resultText"><xsl:value-of select="i18n:translate('results.text')" /></span>
              <xsl:text> </xsl:text>
              <xsl:value-of select="$name_str"/>
            </xsl:when>
          </xsl:choose>
          <!-- END: OA specific changes -->
        </h1>
        <h2>
          <xsl:choose>
            <xsl:when test="$hits=0">
              <xsl:value-of select="i18n:translate('results.noObject')" />
            </xsl:when>
            <xsl:when test="$hits=1">
              <xsl:value-of select="i18n:translate('results.oneObject')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="i18n:translate('results.nObjects',$hits)" />
            </xsl:otherwise>
          </xsl:choose>
        </h2>
      </div>
    </div>

<!-- Suchschlitz mit Suchbegriff, Treffer - Nummer, Vorschau, Autor, Ã„nderungsdatum, Link zu den Details, Filter  -->
    <div class="row result_searchline">
      <div class="col-xs-12 col-sm-8 text-center result_search">
        <div class="search_box">
          <xsl:variable name="searchlink" select="concat($proxyBaseURL, $HttpSession, $solrParams)" />
          <form action="{$searchlink}" class="search_form" method="post">
            <div class="input-group input-group-sm">
              <div class="input-group-btn">
                <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" value="all" id="search_type_button">
                  <span id="search_type_label">
                    <xsl:value-of select="i18n:translate('mir.dropdown.all')" />
                  </span>
                  <span class="caret"></span>
                </button>
                <ul class="dropdown-menu search_type">
                  <li>
                    <a href="#" value="all">
                      <xsl:value-of select="i18n:translate('mir.dropdown.all')" />
                    </a>
                  </li>
                  <li>
                    <a href="#" value="mods.title">
                      <xsl:value-of select="i18n:translate('mir.dropdown.title')" />
                    </a>
                  </li>
                  <li>
                    <a href="#" value="mods.author">
                      <xsl:value-of select="i18n:translate('mir.dropdown.author')" />
                    </a>
                  </li>
                  <li>
                    <a href="#" value="mods.name.top">
                      <xsl:value-of select="i18n:translate('mir.dropdown.name')" />
                    </a>
                  </li>
                  <li>
                    <a href="#" value="mods.nameIdentifier">
                      <xsl:value-of select="i18n:translate('mir.dropdown.nameIdentifier')" />
                    </a>
                  </li>
                  <li>
                    <a href="#" value="allMeta">
                      <xsl:value-of select="i18n:translate('mir.dropdown.allMeta')" />
                    </a>
                  </li>
                  <li>
                    <a href="#" value="content">
                      <xsl:value-of select="i18n:translate('mir.dropdown.content')" />
                    </a>
                  </li>
                </ul>
              </div>
              <xsl:variable name="resolver">
                <xsl:call-template name="substring-after-last">
                  <xsl:with-param name="string" select="$proxyBaseURL" />
                  <xsl:with-param name="delimiter" select="'/'" />
                </xsl:call-template>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="$resolver = 'find'">
                  <xsl:variable name="qry">
                    <xsl:variable name="encodedQry">
                      <xsl:call-template name="UrlGetParam">
                        <xsl:with-param name="url" select="$RequestURL" />
                        <xsl:with-param name="par" select="'condQuery'" />
                      </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="decoder:decode($encodedQry, 'UTF-8')" />
                  </xsl:variable>
                  <xsl:choose>
                    <xsl:when test="$qry = '*'">
                      <input class="form-control" name="qry" placeholder="{i18n:translate('mir.placeholder.response.search')}" type="text" />
                    </xsl:when>
                    <xsl:otherwise>
                      <input class="form-control" name="qry" placeholder="{i18n:translate('mir.placeholder.response.search')}" type="text" value="{$qry}" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <input class="form-control" name="condQuery" placeholder="{i18n:translate('mir.placeholder.response.search')}" type="text" />
                </xsl:otherwise>
              </xsl:choose>
              <span class="input-group-btn">
                <button class="btn btn-primary" type="submit">
                  <span class="fa fa-search"></span>
                   <xsl:value-of select="i18n:translate('editor.search.search')"/>
                </button>
              </span>
            </div>
          </form>
        </div>
      </div>

      <!-- START: alle zu basket -->
      <div class="col-xs-12 col-sm-4">
        <form class="basket_form" action="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}" method="post">
          <input type="hidden" name="action" value="add" />
          <input type="hidden" name="redirect" value="referer" />
          <input type="hidden" name="type" value="objects" />
          <xsl:for-each select="/response/result/doc|/response/lst[@name='grouped']/lst[@name='returnId']/arr[@name='groups']/lst/str[@name='groupValue']">
            <xsl:variable name="docID">
              <xsl:choose>
                <xsl:when test="@id!=''">
                  <xsl:value-of select="@id" />
                </xsl:when>
                <xsl:when test="str[@name='id']">
                  <xsl:value-of select="str[@name='id']" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="." />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <input type="hidden" name="id" value="{$docID}" />
            <input type="hidden" name="uri" value="{concat('mcrobject:',$docID)}" />
          </xsl:for-each>
          <button type="submit" tabindex="1" class="basket_button btn-primary form-control" value="add">
            <i class="fa fa-plus"></i>
            <xsl:text> </xsl:text>
            <xsl:value-of select="i18n:translate('basket.add.searchpage')" />
          </button>
        </form>
      </div>
      <!-- ENDE: alle zu basket -->

    </div> <!-- ENDE: Suchschlitz mit Suchbegriff -->

    <!-- xsl:if test="string-length(/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='q']) &gt; 0">
      <div class="row">
        <div class="col-xs-12 col-sm-8">
          <span class="fa fa-remove-circle"></span>
          <xsl:value-of select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='q']" />
        </div>
      </div>
    </xsl:if -->

<!-- Filter, Pagination & Trefferliste -->
    <div class="row result_body">
      <div class="col-xs-12 col-sm-4 result_filter">
        <xsl:if test="/response/lst[@name='facet_counts']/lst[@name='facet_fields']/lst[@name='worldReadableComplete']/int">
          <div class="panel panel-default oa">
            <div class="panel-heading" data-toggle="collapse-next">
              <h3 class="panel-title">
                <xsl:value-of select="i18n:translate('mir.response.openAccess.facet.title')" />
              </h3>
            </div>
            <div class="panel-body collapse in">
              <ul class="filter">
                <xsl:apply-templates select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
                  <xsl:with-param name="facet_name" select="'worldReadableComplete'" />
                  <xsl:with-param name="i18nPrefix" select="'mir.response.openAccess.facet.'" />
                </xsl:apply-templates>
              </ul>
            </div>
          </div>
        </xsl:if>
        <!-- OA specific changes: " and $hits &gt; 0" -->
        <xsl:if test="/response/lst[@name='facet_counts']/lst[@name='facet_fields']/lst[@name='mods.genre']/int and $hits &gt; 0">
          <div class="panel panel-default genre">
            <div class="panel-heading" data-toggle="collapse-next">
              <h3 class="panel-title">
                <xsl:value-of select="i18n:translate('editor.search.mir.genre')" />
              </h3>
            </div>
            <div class="panel-body collapse in">
              <ul class="filter">
                <xsl:apply-templates select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
                  <xsl:with-param name="facet_name" select="'mods.genre'" />
                  <xsl:with-param name="classId" select="'mir_genres'" />
                </xsl:apply-templates>
              </ul>
            </div>
          </div>  
          <!-- START: OA specific changes -->
          <div class="panel panel-default">
            <div class="panel-heading" data-toggle="collapse-next">
              <h3 class="panel-title">
                <xsl:value-of select="i18n:translate('editor.search.mir.genre.host')" />
              </h3>
            </div>
            <div class="panel-body collapse in">
              <ul class="filter">
                <xsl:apply-templates select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
                  <xsl:with-param name="facet_name" select="'mods.genre.host'" />
                  <xsl:with-param name="classId" select="'mir_genres'" />
                </xsl:apply-templates>
              </ul>
            </div>
          </div> 
          <!--
          <div class="panel panel-default">
            <div class="panel-heading" data-toggle="collapse-next">
              <h3 class="panel-title">
                <xsl:value-of select="'Genre'" />
              </h3>
            </div>
            <div class="panel-body collapse in">
              <ul class="filter">
                <xsl:apply-templates select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']/lst[@name='mods.genre.composite']/int[string-length(substring-after(@name,'.')) = 0]">
                  <xsl:with-param name="facet_name" select="'mods.genre.composite'" />
                  <xsl:with-param name="i18nPrefix" select="'oa.genres.composite'" />
                  <xsl:with-param name="i18nCallback" select="'printGenresComposite'" />
                </xsl:apply-templates>
                <xsl:for-each select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']/lst[@name='mods.genre.host']/int">
                  <xsl:variable name="hostGenre" select="@name"/>
                  <li>
                    <h4>
                      <xsl:value-of select="concat('Beitrag in ',mcrxsl:getDisplayName('mir_genres',$hostGenre))"/>
                    </h4>
                  </li>
                  <xsl:apply-templates select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']/lst[@name='mods.genre.composite']/int[substring-after(@name,'.')=$hostGenre]">
                    <xsl:with-param name="facet_name" select="'mods.genre.composite'" />
                    <xsl:with-param name="i18nPrefix" select="'oa.genres.composite'" />
                    <xsl:with-param name="i18nCallback" select="'printGenresComposite'" />
                  </xsl:apply-templates>
                  
                  
                </xsl:for-each>
              </ul>
            </div>
          </div>-->
          
          <div class="panel panel-default">
            <div class="panel-heading" data-toggle="collapse-next">
              <h3 class="panel-title">
                <xsl:value-of select="'referiert'" />
              </h3>
            </div>
            <xsl:variable name="facetname">
              <xsl:choose>
                <xsl:when test="mcrxsl:isCurrentUserGuestUser()">
                  <xsl:value-of select="'mods.refereed.public'" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="'mods.refereed'" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <div class="panel-body collapse in">
              <ul class="filter">
                <xsl:apply-templates select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
                  <xsl:with-param name="facet_name" select="$facetname" />
                  <xsl:with-param name="i18nPrefix" select="'oa.refereed.'" />
                </xsl:apply-templates>
              </ul>
            </div>
          </div>
          <div class="panel panel-default">
            <div class="panel-heading" data-toggle="collapse-next">
              <h3 class="panel-title">
                <xsl:value-of select="i18n:translate('editor.search.status')" />
              </h3>
            </div>
            <div class="panel-body collapse in">
              <ul class="filter">
                <xsl:apply-templates select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
                  <xsl:with-param name="facet_name" select="'state'" />
                  <xsl:with-param name="classId" select="'state'" />
                </xsl:apply-templates>
              </ul>
            </div>
          </div>
          <!-- END: OA specific changes -->
        </xsl:if>
        <xsl:if test="$MIR.testEnvironment='true'"> <!-- filters in development, show only in test environments -->
          <xsl:call-template name="print.classiFilter">
            <xsl:with-param name="classId" select="'mir_institutes'" />
            <xsl:with-param name="i18nKey" select="'editor.search.mir.institute'" />
          </xsl:call-template>
          <xsl:call-template name="print.classiFilter">
            <xsl:with-param name="classId" select="'SDNB'" />
            <xsl:with-param name="i18nKey" select="'editor.search.mir.sdnb'" />
          </xsl:call-template>
          <xsl:call-template name="print.dateFilter" />
        </xsl:if>
      </div>

      <div class="col-xs-12 col-sm-8 result_list">
        <xsl:comment>
          RESULT LIST START
        </xsl:comment>
        <div id="hit_list">
          <xsl:apply-templates select="doc|arr[@name='groups']/lst/str[@name='groupValue']" />
        </div>
        <xsl:comment>
          RESULT LIST END
        </xsl:comment>
        <div class="result_list_end" />
        <xsl:copy-of select="$ResultPages" />
      </div>

    </div>
  </xsl:template>

  <xsl:template match="doc" priority="10" mode="resultList">
    <xsl:param name="hitNumberOnPage" select="count(preceding-sibling::*[name()=name(.)])+1" />
    <!--
      Do not read MyCoRe object at this time
    -->
    <xsl:variable name="identifier" select="@id" />
    <xsl:variable name="mcrobj" select="." />
    <xsl:variable name="mods-genre">
      <xsl:choose>
        <xsl:when test="arr[@name='mods.genre']">
          <xsl:value-of select="arr[@name='mods.genre']/str" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'article'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="parentGenre">
      <xsl:choose>
        <xsl:when test="arr[@name='mods.genre.host']">
          <xsl:value-of select="arr[@name='mods.genre.host']/str" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="mods-genre-i18n" >
      <xsl:choose>
        <xsl:when test="$parentGenre"> 
          <xsl:value-of select="concat(mcrxsl:getDisplayName('mir_genres',$mods-genre),' in ',mcrxsl:getDisplayName('mir_genres',$parentGenre))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="mcrxsl:getDisplayName('mir_genres',$parentGenre)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="hitItemClass">
      <xsl:choose>
        <xsl:when test="$hitNumberOnPage mod 2 = 1">
          odd
        </xsl:when>
        <xsl:otherwise>
          even
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- generate browsing url -->
    <xsl:variable name="href" select="concat($proxyBaseURL,$HttpSession,$solrParams)" />
    <xsl:variable name="startPosition" select="$hitNumberOnPage - 1 + (($currentPage) -1) * $rows" />
    <xsl:variable name="completeHref">
      <xsl:value-of select="concat($href, '&amp;start=',$startPosition, '&amp;fl=id&amp;rows=1&amp;origrows=', $rows, '&amp;XSL.Style=browse')" />
    </xsl:variable>
    <xsl:variable name="hitHref">
      <xsl:value-of select="mcrxsl:regexp($completeHref, '&amp;XSL.Transformer=response-resultlist', '')" />
    </xsl:variable>

    <!-- derivate variables -->
    <xsl:variable name="derivates" select="key('derivate', $identifier)" />
    <xsl:variable name="derivid" select="$derivates/str[@name='maindoc'][1]/../str[@name='id']" />
    <xsl:variable name="maindoc" select="$derivates/str[@name='maindoc'][1]" />
    <xsl:variable name="derivbase" select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derivid,'/')" />
    <xsl:variable name="derivifs" select="concat($derivbase,$maindoc,$HttpSession)" />

    <xsl:variable name="hitCount" select="$hitNumberOnPage + (($currentPage) -1) * $rows" />

<!-- hit entry -->
    <div id="hit_{$hitCount}" class="hit_item {$hitItemClass}">

<!-- hit head -->
      <div class="row hit_item_head">
        <div class="col-xs-12">

<!-- hit number -->
          <div class="hit_counter">
            <xsl:value-of select="$hitCount" />
          </div>

<!-- relevance -->
          <xsl:variable name="score" select="float[@name='score']" />
          <xsl:if test="$score &gt; 0 and $maxScore &gt; 0">
            <xsl:variable name="relevance" select="($score div $maxScore) * 100" />
            <div class="hit_stars_5 hit_stars" title="{i18n:translate('mir.response.relevance')}: {$relevance}%">
              <xsl:if test="$relevance &gt; 0">
                <div class="hit_star_1 hit_star"></div>
              </xsl:if>
              <xsl:if test="$relevance &gt; 20">
                <div class="hit_star_2 hit_star"></div>
              </xsl:if>
              <xsl:if test="$relevance &gt; 40">
                <div class="hit_star_3 hit_star"></div>
              </xsl:if>
              <xsl:if test="$relevance &gt; 60">
                <div class="hit_star_4 hit_star"></div>
              </xsl:if>
              <xsl:if test="$relevance &gt; 80">
                <div class="hit_star_5 hit_star"></div>
              </xsl:if>
            </div>
          </xsl:if>

<!-- hit options -->
          <xsl:choose>
            <xsl:when test="acl:checkPermission($identifier,'writedb')">
              <div class="hit_options pull-right">
                <div class="btn-group">
                  <a data-toggle="dropdown" class="btn btn-default dropdown-toggle" href="#">
                    <i class="fa fa-cog"></i>
                    Aktionen
                    <span class="caret"></span>
                  </a>
                  <ul class="dropdown-menu dropdown-menu-right">
                    <li class="">
                      <xsl:call-template name="basketLink">
                        <xsl:with-param name="identifier" select="$identifier" />
                      </xsl:call-template>
                    </li>
                        <!-- direct link to editor -->
                    <xsl:if test="acl:checkPermission($identifier,'writedb')">
                      <li class="">
                        <xsl:variable name="editURL">
                          <xsl:call-template name="mods.getObjectEditURL">
                            <xsl:with-param name="id" select="$identifier" />
                            <xsl:with-param name="layout" select="'$'" />
                          </xsl:call-template>
                        </xsl:variable>
                        <a class="hit_option hit_edit">
                          <xsl:choose>
                            <xsl:when test="string-length($editURL) &gt; 0">
                              <xsl:attribute name="href">
                                    <xsl:value-of select="$editURL" />
                                  </xsl:attribute>
                              <span class="fa fa-pencil"></span>
                              <xsl:value-of select="i18n:translate('object.editObject')" />
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:attribute name="href">
                                    <xsl:value-of select="'#'" />
                                  </xsl:attribute>
                              <span class="fa fa-pencil"></span>
                              <xsl:value-of select="i18n:translate('object.locked')" />
                            </xsl:otherwise>
                          </xsl:choose>
                        </a>
                      </li>
                    </xsl:if>
                  </ul>
                </div>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <div class="single_hit_option pull-right">
                <xsl:call-template name="basketLink">
                  <xsl:with-param name="identifier" select="$identifier" />
                </xsl:call-template>
              </div>
            </xsl:otherwise>
          </xsl:choose>


        </div><!-- end col -->
      </div><!-- end row head -->


<!-- hit body -->
      <div class="row hit_item_body">
        <div class="col-xs-12">

<!-- document preview -->
          <div class="hit_download_box">
            <xsl:choose>

              <!-- we got a derivate -->
              <xsl:when test="string-length($derivid) &gt; 0">
                <xsl:choose>

                  <!-- show IView thumbnail as preview -->
                  <xsl:when test="$derivates/str[@name='iviewFile']">
                    <!-- xsl:call-template name="iViewLinkPrev">
                      <xsl:with-param name="mcrid" select="$identifier" />
                      <xsl:with-param name="derivate" select="$derivid" />
                      <xsl:with-param name="fileName" select="$derivates/str[@name='iviewFile'][1]" />
                    </xsl:call-template -->

                    <xsl:variable name="viewerLink" select="concat($WebApplicationBaseURL, 'rsc/viewer/', $derivid,'/', $derivates/str[@name='iviewFile'][1])" />
                    <xsl:choose>
                      <xsl:when test="acl:checkPermissionForReadingDerivate($derivid)">
                        <a class="hit_option hit_download" href="{$viewerLink}" title="{$mods-genre-i18n}">
                          <div class="hit_icon"
                            style="background-image: url('{$WebApplicationBaseURL}rsc/thumbnail/{$identifier}/100.jpg');"
                          >
                          </div>
                        </a>
                      </xsl:when>
                      <xsl:otherwise>
                        <div class="hit_icon"
                          style="background-image: url('{$WebApplicationBaseURL}rsc/thumbnail/{$identifier}/100.jpg');"
                        >
                        </div>
                      </xsl:otherwise>
                    </xsl:choose>

                  </xsl:when>

                  <!-- show PDF thumbnail as preview -->
                  <xsl:when test="translate(str:tokenize($derivates/str[@name='maindoc'][1],'.')[position()=last()],'PDF','pdf') = 'pdf'">
                    <xsl:variable name="filePath"
                      select="concat($derivates/str[@name='id'][1],'/',mcr:encodeURIPath($derivates/str[@name='maindoc'][1]),$HttpSession)" />
                    <xsl:variable name="viewerLink">
                      <xsl:choose>
                        <xsl:when test="mcrxsl:isMobileDevice($UserAgent)">
                          <xsl:value-of select="$derivifs" />
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="concat($WebApplicationBaseURL, 'rsc/viewer/', $filePath)" />
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="acl:checkPermissionForReadingDerivate($derivid)">
                        <a class="hit_option hit_download" href="{$viewerLink}" title="{$mods-genre-i18n}">
                          <div class="hit_icon" style="background-image: url('{$WebApplicationBaseURL}rsc/thumbnail/{$identifier}/100.jpg');">
                          </div>
                        </a>
                      </xsl:when>
                      <xsl:otherwise>
                        <div class="hit_icon" style="background-image: url('{$WebApplicationBaseURL}rsc/thumbnail/{$identifier}/100.jpg');">
                        </div>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>

                  <!-- show default icon with mime-type download icon -->
                  <xsl:otherwise>

                    <xsl:variable name="contentType" select="document(concat('ifs:/',$derivid))/mcr_directory/children/child[name=$maindoc]/contentType" />
                    <xsl:variable name="fileType" select="document('webapp:FileContentTypes.xml')/FileContentTypes/type[mime=$contentType]/@ID" />

                    <xsl:choose>
                      <xsl:when test="acl:checkPermissionForReadingDerivate($derivid)">
                        <a class="hit_option hit_download" href="{$hitHref}" title="">
                          <div class="hit_icon" style="background-image: url('{$WebApplicationBaseURL}images/icons/icon_common.png');" />
                          <xsl:choose>
                            <xsl:when
                              test="$fileType='pdf' or $fileType='msexcel' or $fileType='xlsx' or $fileType='msword97' or $fileType='docx' or $fileType='pptx' or $fileType='msppt' or $fileType='zip'"
                            >
                              <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/svg_icons/download_{$fileType}.svg" />
                            </xsl:when>
                            <xsl:when test="$fileType='png' or $fileType='jpeg' or $fileType='tiff' or $fileType='gif' or $fileType='bmp'">
                              <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/svg_icons/download_image.svg" />
                            </xsl:when>
                            <xsl:when test="$fileType='mp3' or $fileType='wav' or $fileType='m4a' or $fileType='m4b' or $fileType='wma'">
                              <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/svg_icons/download_audio.svg" />
                            </xsl:when>
                            <xsl:when test="$fileType='mpeg4' or $fileType='m4v' or $fileType='avi' or $fileType='wmv' or $fileType='asf'">
                              <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/svg_icons/download_video.svg" />
                            </xsl:when>
                            <xsl:otherwise>
                              <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/svg_icons/download_default.svg" />
                            </xsl:otherwise>
                          </xsl:choose>
                        </a>
                      </xsl:when>
                      <xsl:otherwise>
                        <div class="hit_icon" style="background-image: url('{$WebApplicationBaseURL}images/icons/icon_common.png');" />
                        <xsl:choose>
                          <xsl:when
                            test="$fileType='pdf' or $fileType='msexcel' or $fileType='xlsx' or $fileType='msword97' or $fileType='docx' or $fileType='pptx' or $fileType='msppt' or $fileType='zip'"
                          >
                            <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/svg_icons/download_{$fileType}.svg" />
                          </xsl:when>
                          <xsl:when test="$fileType='png'">
                            <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/svg_icons/download_image.svg" />
                          </xsl:when>
                          <xsl:when test="$fileType='mp3'">
                            <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/svg_icons/download_audio.svg" />
                          </xsl:when>
                          <xsl:when test="$fileType='mpg4'">
                            <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/svg_icons/download_video.svg" />
                          </xsl:when>
                          <xsl:otherwise>
                            <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/svg_icons/download_default.svg" />
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>

              </xsl:when>

              <!-- no derivate -->
              <xsl:otherwise>
                <!-- show default icon -->
                <img class="hit_icon" src="{$WebApplicationBaseURL}images/icons/icon_common_disabled.png" />
              </xsl:otherwise>
            </xsl:choose>
          </div>

<!-- hit type -->
          <div class="hit_tnd_container">
            <div class="hit_tnd_content">
              <div class="hit_oa" data-toggle="tooltip">
                <xsl:variable name="isOpenAccess" select="bool[@name='worldReadableComplete']='true'" />
              <xsl:choose>
                  <xsl:when test="$isOpenAccess">
                    <xsl:attribute name="title">
                      <xsl:value-of select="i18n:translate('mir.response.openAccess.true')" />
                    </xsl:attribute>
                    <span class="label label-success">
                      <i class="fa fa-unlock-alt" aria-hidden="true"></i>
                    </span>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="title">
                      <xsl:value-of select="i18n:translate('mir.response.openAccess.false')" />
                    </xsl:attribute>
                    <span class="label label-warning">
                      <i class="fa fa-lock" aria-hidden="true"></i>
                    </span>
                  </xsl:otherwise>
                </xsl:choose>
              </div>
              <xsl:choose>
                <xsl:when test="arr[@name='mods.genre']">
                  <xsl:for-each select="arr[@name='mods.genre']/str">
                    <div class="hit_type">
                      <span class="label label-info">
                        <xsl:value-of select="$mods-genre-i18n" />
                      </span>
                    </div>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <div class="hit_type">
                    <span class="label label-info">
                      <xsl:value-of select="mcrxsl:getDisplayName('mir_genres','article')" />
                    </span>
                  </div>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="arr[@name='category.top']/str[contains(text(), 'mir_licenses:')]">
                <div class="hit_license">
                  <span class="label label-primary">
                    <xsl:variable name="accessCondition">
                      <xsl:value-of select="substring-after(arr[@name='category.top']/str[contains(text(), 'mir_licenses:')][last()],':')" />
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="contains($accessCondition, 'rights_reserved')">
                        <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.rightsReserved')" />
                      </xsl:when>
                      <xsl:when test="contains($accessCondition, 'oa_nlz')">
                        <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.oa_nlz.short')" />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="mcrxsl:getDisplayName('mir_licenses',$accessCondition)" />
                      </xsl:otherwise>
                    </xsl:choose>
                  </span>
                </div>
              </xsl:if>
              <xsl:if test="str[@name='mods.dateIssued'] or str[@name='mods.dateIssued.host']">
                <div class="hit_date">
                  <xsl:variable name="date">
                    <xsl:choose>
                      <xsl:when test="str[@name='mods.dateIssued']">
                        <xsl:value-of select="str[@name='mods.dateIssued']" />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="str[@name='mods.dateIssued.host']" />
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <span class="label label-primary">
                    <xsl:value-of select="$date" />
                  </span>
                </div>
              </xsl:if>
              <!-- START: OA specific changes -->
              <xsl:if test="str[@name='mods.refereed']='yes'">
                <div class="hit_refereed">
                  <span class="label label-primary">
                    <xsl:value-of select="i18n:translate('oa.refereed')" />
                  </span>
                </div>
              </xsl:if>
              <!-- END: OA specific changes -->
              <xsl:if test="not (mcrxsl:isCurrentUserGuestUser())">
                <div class="hit_state">
                  <xsl:variable name="status-i18n">
                    <xsl:value-of select="i18n:translate(concat('mir.state.',str[@name='state']))" />
                  </xsl:variable>
                  <span class="label mir-{str[@name='state']}" title="{i18n:translate('component.mods.metaData.dictionary.status')}">
                    <xsl:value-of select="$status-i18n" />
                  </span>
                </div>
              </xsl:if>
              <xsl:if test="string-length($MCR.ORCID.OAuth.ClientSecret) &gt; 0">
                <script src="{$WebApplicationBaseURL}js/mir/mycore2orcid.js" />
                <div class="orcid-status" data-id="{$identifier}" />
              </xsl:if>
            </div>
          </div>

<!-- hit headline -->
          <h3 class="hit_title">
            <a href="{$hitHref}">
              <xsl:attribute name="title">
                    <xsl:value-of select="./str[@name='mods.title.main']" />
                    <xsl:if test="./str[@name='mods.title.subtitle']">
                      <xsl:value-of select="concat(' : ', ./str[@name='mods.title.subtitle'])" />
                    </xsl:if>
                  </xsl:attribute>
              <xsl:choose>
                <xsl:when test="./str[@name='search_result_link_text']">
                  <xsl:value-of select="./str[@name='search_result_link_text']" />
                  <xsl:if test="not(contains(./str[@name='search_result_link_text'], '...')) and ./str[@name='mods.title.subtitle']">
                    <xsl:variable name="mylength" select="75 - string-length(./str[@name='search_result_link_text'])" />
                    <xsl:if test="$mylength &gt; 7">
                      <span class="subtitle">
                        <xsl:value-of select="concat(' : ', substring(./str[@name='mods.title.subtitle'],1, $mylength))" />
                        <xsl:if test="string-length(./str[@name='mods.title.subtitle']) &gt; $mylength">
                          ...
                        </xsl:if>
                      </span>
                    </xsl:if>
                  </xsl:if>
                </xsl:when>
                <xsl:when test="./str[@name='fileName']">
                  <xsl:value-of select="./str[@name='fileName']" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$identifier" />
                </xsl:otherwise>
              </xsl:choose>
            </a>
          </h3>

<!-- hit author -->
          <xsl:if
            test="arr[@name='mods.nameByRole.personal.aut'] or arr[@name='mods.nameByRole.personal.edt'] or arr[@name='mods.nameByRole.corporate.pbl'] or arr[@name='mods.nameByRole.corporate.edt']"
          >
            <div class="hit_author">
              <xsl:variable name="nameList">
                <xsl:choose>
                  <xsl:when test="arr[@name='mods.nameByRole.personal.aut']">
                    <xsl:copy-of select="arr[@name='mods.nameByRole.personal.aut']/." />
                  </xsl:when>
                  <xsl:when test="arr[@name='mods.nameByRole.personal.edt']">
                    <xsl:copy-of select="arr[@name='mods.nameByRole.personal.edt']/." />
                  </xsl:when>
                  <xsl:when test="arr[@name='mods.nameByRole.corporate.pbl']">
                    <xsl:copy-of select="arr[@name='mods.nameByRole.corporate.pbl']/." />
                  </xsl:when>
                  <xsl:when test="arr[@name='mods.nameByRole.corporate.edt']">
                    <xsl:copy-of select="arr[@name='mods.nameByRole.corporate.edt']/." />
                  </xsl:when>
                </xsl:choose>
              </xsl:variable>
              <xsl:for-each select="exslt:node-set($nameList)/arr/str[position() &lt;= 3]">
                <xsl:if test="position()!=1">
                  <xsl:value-of select="' / '" />
                </xsl:if>
                <xsl:variable name="author_name">
                  <xsl:choose>
                    <xsl:when test="contains(., ':')">
                      <xsl:value-of select="substring-before(., ':')" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="." />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:variable name="nameIdentifierAndType" select="substring-after(., ':')" />
                <!-- if user is in role editor or admin, show all; other users only gets their own and published publications -->
                <xsl:variable name="owner">
                  <xsl:choose>
                    <xsl:when test="mcrxsl:isCurrentUserInRole('admin') or mcrxsl:isCurrentUserInRole('editor')"><!--
                      -->
                      *<!--
                    -->
                    </xsl:when>
                    <xsl:otherwise><!--
                      -->
                      <xsl:value-of select="$CurrentUser" /><!--
                    -->
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="string-length($nameIdentifierAndType) &gt; 0">
                    <xsl:variable name="nameIdentifier" select="substring-after($nameIdentifierAndType, ':')" />
                    <xsl:variable name="nameIdentifierType" select="substring-before($nameIdentifierAndType, ':')" />
                    <xsl:variable name="classi"
                      select="document(concat('classification:metadata:all:children:','nameIdentifier',':',$nameIdentifierType))/mycoreclass/categories/category[@ID=$nameIdentifierType]" />
                    <xsl:variable name="uri" select="$classi/label[@xml:lang='x-uri']/@text" />
                    <xsl:variable name="idType" select="$classi/label[@xml:lang='de']/@text" />
                    <a
                      href="{$ServletsBaseURL}solr/mods_nameIdentifier?q=mods.nameIdentifier:{$nameIdentifierType}%5C:{$nameIdentifier}&amp;owner=createdby:{$owner}"
                      title="Suche nach allen Publikationen"
                    >
                      <xsl:value-of select="$author_name" />
                    </a>
                    <xsl:text>&#160;</xsl:text><!-- add whitespace here -->
                    <a href="{$uri}{$nameIdentifier}" title="Link zu {$idType}">
                      <sup>
                        <xsl:value-of select="$idType" />
                      </sup>
                    </a>
                  </xsl:when>
                  <xsl:otherwise>
                    <a href="{$ServletsBaseURL}solr/mods_nameIdentifier?q=mods.name:&quot;{$author_name}&quot;&amp;owner=createdby:{$owner}" title="Suche nach allen Publikationen">
                      <xsl:value-of select="$author_name" />
                    </a>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
              <xsl:if test="count(exslt:node-set($nameList)/arr/str) &gt; 3">
                <xsl:value-of select="' / et.al.'" />
              </xsl:if>
            </div>
          </xsl:if>

<!-- hit parent -->
          <xsl:if test="./str[@name='parent']">
            <div class="hit_source">
              <span class="label_parent">aus: </span>
              <xsl:choose>
                <xsl:when test="./str[@name='parentLinkText']">
                  <xsl:variable name="linkTo" select="concat($WebApplicationBaseURL, 'receive/',./str[@name='parent'])" />
                  <a href="{$linkTo}">
                    <xsl:value-of select="./str[@name='parentLinkText']" />
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="objectLink">
                    <xsl:with-param select="./str[@name='parent']" name="obj_id" />
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </xsl:if>

<!-- hit abstract -->
          <xsl:variable name="description" select="str[@name='mods.abstract.result']" />
          <xsl:if test="$description">
            <div class="hit_abstract">
              <xsl:value-of select="$description" />
            </div>
          </xsl:if>

<!-- hit publisher -->
          <xsl:if test="arr[@name='mods.publisher']">
            <div class="hit_pub_name">
              <xsl:variable name="date">
                <xsl:choose>
                  <xsl:when test="str[@name='mods.dateIssued']">
                    <xsl:value-of select="str[@name='mods.dateIssued']" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="str[@name='mods.dateIssued.host']" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="place" select="arr[@name='mods.place']/str" />
              <span class="label_publisher">
                <xsl:choose>
                  <xsl:when test="string-length($place) &gt; 0">
                    <xsl:value-of select="concat($place,': ')" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.published'),': ')" />
                  </xsl:otherwise>
                </xsl:choose>
              </span>

              <xsl:for-each select="arr[@name='mods.publisher']/str">
                <xsl:if test="position()!=1">
                  <xsl:value-of select="'; '" />
                </xsl:if>
                <xsl:value-of select="." />
                <xsl:if test="position()=last() and string-length($date) &gt; 0">
                  <xsl:value-of select="concat(', ', $date)" />
                </xsl:if>
              </xsl:for-each>
            </div>
          </xsl:if>

          <xsl:if test="string-length($MCR.ORCID.OAuth.ClientSecret) &gt; 0">
            <div class="orcid-publish" data-id="{$identifier}" />
          </xsl:if>

        </div><!-- end hit col -->
      </div><!-- end hit body -->
    </div><!-- end hit item -->
  </xsl:template>

  <!-- copied from mods.xsl -> ToDo: refacture! -->
  <xsl:template name="mods.getObjectEditURL">
    <xsl:param name="id" />
    <xsl:param name="layout" select="'$'" />
    <xsl:param name="collection" select="''" />
    <xsl:choose>
      <xsl:when test="mcrxsl:resourceAvailable('actionmappings.xml')">
      <!-- URL mapping enabled -->
        <xsl:variable name="url">
          <xsl:choose>
            <xsl:when test="string-length($collection) &gt; 0">
              <xsl:choose>
                <xsl:when test="$layout = 'all'">
                  <xsl:value-of select="actionmapping:getURLforCollection('update-xml',$collection,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="actionmapping:getURLforCollection('update',$collection,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$layout = 'all'">
                  <xsl:value-of select="actionmapping:getURLforID('update-xml',$id,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="actionmapping:getURLforID('update',$id,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="string-length($url)=0" />
          <xsl:otherwise>
            <xsl:variable name="urlWithParam">
              <xsl:call-template name="UrlSetParam">
                <xsl:with-param name="url" select="$url" />
                <xsl:with-param name="par" select="'id'" />
                <xsl:with-param name="value" select="$id" />
              </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="UrlAddSession">
              <xsl:with-param name="url" select="$urlWithParam" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
      <!-- URL mapping disabled -->
        <xsl:choose>
          <xsl:when test="$layout != '$'">
            <xsl:value-of select="concat($WebApplicationBaseURL,'/editor/editor-dynamic.xed',$HttpSession,'?id=',$id,'&amp;genre=article&amp;host=standalone')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($WebApplicationBaseURL,'/editor/editor-admin.xed',$HttpSession,'?id=',$id)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="i18nCallback">
    <xsl:param name="value"/>
    <xsl:variable name="genre" select="substring-before($value,'.')"/>
    <xsl:variable name="parentGenre" select="substring-after($value,'.')"/>
    <xsl:variable name="linkText">
      <xsl:choose>
        <xsl:when test="$parentGenre">
          <xsl:value-of select="concat(mcrxsl:getDisplayName('mir_genres',$genre),' in ',mcrxsl:getDisplayName('mir_genres',$parentGenre) )"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="mcrxsl:getDisplayName('mir_genres',$genre)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$linkText" />
  </xsl:template>
  
  <xsl:template match="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
    <xsl:param name="facet_name" />
    <xsl:param name="classId" />
    <xsl:param name="i18nPrefix" />
    <xsl:param name="i18nCallback" />
    <xsl:apply-templates select="lst[@name=$facet_name]/int">
      <xsl:with-param name="facet_name" select="$facet_name"/>
      <xsl:with-param name="classId" select="$classId"/>
      <xsl:with-param name="i18nPrefix" select="$i18nPrefix"/>
      <xsl:with-param name="i18nCallback" select="$i18nCallback"/>
    </xsl:apply-templates>
    
  </xsl:template>
  
  <xsl:template match="/response/lst[@name='facet_counts']/lst[@name='facet_fields']/lst/int">
    <xsl:param name="facet_name" />
    <xsl:param name="classId" />
    <xsl:param name="i18nPrefix" />
    <xsl:param name="i18nCallback" />
    <!-- <xsl:for-each select="lst[@name=$facet_name]/int"> -->
      <xsl:variable name="fqFragment">
        <xsl:value-of select="concat('fq=',$facet_name,':',@name)" />
      </xsl:variable>
      <xsl:variable name="queryWithoutStart" select="mcrxsl:regexp($RequestURL, '(&amp;|%26)(start=)[0-9]*', '')" />
      <xsl:variable name="queryURL">
        <xsl:choose>
          <xsl:when test="contains($queryWithoutStart, $fqFragment)">
            <xsl:choose>
              <xsl:when test="not(substring-after($queryWithoutStart, $fqFragment))">
                <!-- last parameter -->
                <xsl:value-of select="substring($queryWithoutStart, 1, string-length($queryWithoutStart) - string-length($fqFragment) - 1)" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat(substring-before($queryWithoutStart, $fqFragment), substring-after($queryWithoutStart, concat($fqFragment,'&amp;')))" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="not(contains($queryWithoutStart, '?'))">
            <xsl:value-of select="concat($queryWithoutStart, '?', $fqFragment)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($queryWithoutStart, '&amp;', $fqFragment)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="fqValue" select="concat($facet_name,':',@name)" />
      <li data-fq="{$fqValue}">
        <div class="checkbox">
          <label>
            <input type="checkbox" onclick="location.href='{$queryURL}';">
              <xsl:if test="
              /response/lst[@name='responseHeader']/lst[@name='params']/str[@name='fq' and text() = $fqValue] |
              /response/lst[@name='responseHeader']/lst[@name='params']/arr[@name='fq']/str[text() = $fqValue]">
                <xsl:attribute name="checked">true</xsl:attribute>
              </xsl:if>
            </input>
          </label>
          <span class="title">
            <xsl:choose>
              <xsl:when test="string-length($classId) &gt; 0">
                <xsl:value-of select="mcrxsl:getDisplayName($classId, @name)" />
              </xsl:when>
              <xsl:when test="string-length($i18nCallback) &gt; 0">
                <xsl:call-template name="i18nCallback">
                  <xsl:with-param name="i18nPrefix" select="$i18nPrefix" />
                  <xsl:with-param name="value" select="@name"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:when test="string-length($i18nPrefix) &gt; 0">
                <xsl:value-of select="i18n:translate(concat($i18nPrefix,@name))" disable-output-escaping="yes" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@name" />
              </xsl:otherwise>
            </xsl:choose>
            
          </span>
          <span class="hits">
            <xsl:value-of select="." />
          </span>
        </div>
      </li>
    <!-- </xsl:for-each> -->
  </xsl:template>

  <xsl:template name="print.classiFilter">
    <xsl:param name="classId" />
    <xsl:param name="i18nKey" />
    <div class="panel panel-default">
      <xsl:variable name="classiDocument" select="document(concat('xslStyle:items2options:classification:editor:-1:children:',$classId))" />
      <div class="panel-heading" data-toggle="collapse-next">
        <h3 class="panel-title">
          <xsl:value-of select="i18n:translate($i18nKey)" />
        </h3>
      </div>
      <div class="panel-body collapse in">
        <xsl:if test="contains($RequestURL, concat('category.top%3A%22',$classId))">
          <div class="list-group">
            <xsl:apply-templates select="$classiDocument/select/option" mode="calculate_option_selected">
              <xsl:with-param name="classId" select="$classId" />
            </xsl:apply-templates>
          </div>
        </xsl:if>
        <div class="dropdown container-fluid row">
          <button class="btn btn-default dropdown-toggle col-md-12 col-xs-12" type="button" data-toggle="dropdown">
            <!--Filter-->
            <xsl:value-of select="i18n:translate('mir.response.button.filter')" />
            <span class="caret" />
          </button>
          <ul class="dropdown-menu dropdown-menu-right" role="menu" style="max-height: 500px; overflow-y: scroll;">
            <xsl:apply-templates select="$classiDocument/select/option" mode="calculate_option_notselected">
              <xsl:with-param name="classId" select="$classId" />
            </xsl:apply-templates>
          </ul>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="select/option" mode="calculate_option_notselected">
    <xsl:param name="classId" />
    <xsl:variable name="complete">
      <xsl:value-of select="concat('%2Bcategory.top%3A%22',$classId,'%5C%3A',@value,'%22')" />
    </xsl:variable>
    <xsl:if test="not(contains($RequestURL, $complete))">
      <xsl:variable name="filterHref">
        <xsl:choose>
          <xsl:when test="contains($RequestURL,'&amp;')">
            <xsl:value-of select="concat(substring-before($RequestURL, '&amp;'), $complete, substring-after($RequestURL, substring-before($RequestURL, '&amp;')))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($RequestURL,$complete)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <li>
        <xsl:call-template name="print.hyperLink">
          <xsl:with-param name="href" select="mcrxsl:regexp($filterHref,'(&amp;|%26)(start=)[0-9]*', '')" />
          <xsl:with-param name="text" select="@title" />
        </xsl:call-template>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="select/option" mode="calculate_option_selected">
    <xsl:param name="classId" />
    <xsl:variable name="complete">
      <xsl:value-of select="concat('%2Bcategory.top%3A%22',$classId,'%5C%3A',@value,'%22')" />
    </xsl:variable>
    <xsl:if test="contains($RequestURL, $complete)">
      <xsl:variable name="filterHref">
        <xsl:value-of
          select="mcrxsl:regexp(concat(substring-before($RequestURL, $complete), substring-after($RequestURL, $complete)), '(&amp;|%26)(start=)[0-9]*', '')" />
      </xsl:variable>
      <xsl:call-template name="print.hyperLink">
        <xsl:with-param name="href" select="$filterHref" />
        <xsl:with-param name="text" select="@title" />
        <xsl:with-param name="class" select="'list-group-item active'" />
        <xsl:with-param name="icon" select="'remove'" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="print.hyperLink">
    <xsl:param name="href" />
    <xsl:param name="text" />
    <xsl:param name="class" select="''" />
    <xsl:param name="icon" select="''" />
    <a class="{$class}" href="{$href}" title="{$text}">
      <xsl:if test="$icon != ''">
        <span aria-hidden="true" class="fa fa-{$icon}"></span>
      </xsl:if>
      <xsl:value-of select="$text" />
    </a>
  </xsl:template>

  <xsl:template name="print.dateFilter">
    <div class="panel panel-default mir-search-options-date">
      <div class="panel-heading" data-toggle="collapse-next">
        <h3 class="panel-title">
          <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.dateIssued')" />
        </h3>
      </div>
      <div class="panel-body collapse in">
        <xsl:if test="contains($RequestURL, 'fq=mods.dateIssued')">
          <xsl:variable name="dateFilterHelper">
            <xsl:value-of select="substring-before($RequestURL, '&amp;fq=mods.dateIssued')" />
          </xsl:variable>
          <xsl:variable name="dateFilter">
            <xsl:choose>
              <xsl:when test="contains(substring-after($RequestURL, '&amp;fq=mods.dateIssued'), '&amp;')">
                <xsl:value-of select="concat($dateFilterHelper, '&amp;', substring-after(substring-after($RequestURL, '&amp;fq=mods.dateIssued'), '&amp;'))"></xsl:value-of>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$dateFilterHelper"></xsl:value-of>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <div class="list-group">
            <a class="list-group-item active" href="{$dateFilter}">
              <span aria-hidden="true" class="fa fa-remove" />
            </a>
          </div>
        </xsl:if>
        <div class="dropdown container-fluid row">
          <button class="btn btn-default dropdown-toggle col-md-12 col-xs-12" type="button" data-toggle="dropdown">
            <!--Filter-->
            <xsl:value-of select="i18n:translate('mir.response.button.filter')" />
            <span class="caret" />
          </button>
          <div class="dropdown-menu dropdown-menu-right stopAutoclose col-md-12 mir-date-arrowTop" role="menu">
            <div class="container-fluid">
              <div class="col-md-12 form-group">
                <select class="form-control">
                  <option value="=">=</option>
                  <option value="&gt;">&gt;</option>
                  <option value="&gt;=">&gt;=</option>
                  <option value="&lt;">&lt;</option>
                  <option value="&lt;=">&lt;=</option>
                </select>
              </div>
              <div class="col-md-12 form-group dateContainer">
                <div class="col-md-4">
                  <input class="form-control" placeholder="DD" type="number" min="1" max="31" style="padding: 0.4em" />
                </div>
                <div class="col-md-4">
                  <input class="form-control" placeholder="MM" type="number" min="1" max="12" style="padding: 0.4em" />
                </div>
                <div class="col-md-4">
                  <input class="form-control" placeholder="YYYY" type="number" min="1000" max="2050" style="padding: 0.1em" />
                </div>
              </div>
              <div class="col-md-12 form-group">
                <input id="dateSearch" type="button" class="btn btn-default form-control" value="Go!" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="basketLink">
    <xsl:param name="identifier" />
    <xsl:choose>
      <xsl:when test="basket:contains('objects',$identifier)">
        <!-- remove from basket -->
        <a class="hit_option remove_from_basket" href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type=objects&amp;action=remove&amp;id={$identifier}&amp;redirect=referer"
          title=""
        >
          <span class="fa fa-bookmark"></span>
          <xsl:value-of select="i18n:translate('basket.remove')" />
        </a>
      </xsl:when>
      <xsl:otherwise>
        <!-- add to basket -->
        <a class="hit_option hit_to_basket"
          href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type=objects&amp;action=add&amp;id={$identifier}&amp;uri=mcrobject:{$identifier}&amp;redirect=referer"
          title=""
        >
          <span class="fa fa-bookmark"></span>
          <xsl:value-of select="i18n:translate('basket.add')" />
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="substring-after-last">
    <xsl:param name="string" />
    <xsl:param name="delimiter" />
    <xsl:choose>
      <xsl:when test="contains($string, $delimiter)">
        <xsl:call-template name="substring-after-last">
          <xsl:with-param name="string" select="substring-after($string, $delimiter)" />
          <xsl:with-param name="delimiter" select="$delimiter" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
