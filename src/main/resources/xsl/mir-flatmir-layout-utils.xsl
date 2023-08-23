<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
    xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
    xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
    xmlns:basket="xalan://org.mycore.frontend.basket.MCRBasketManager"
    xmlns:calendar="xalan://java.util.GregorianCalendar"
    exclude-result-prefixes="i18n mcrver mcrxsl basket calendar">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />
  <xsl:param name="piwikID" select="'0'" />
  <xsl:template name="mir.navigation">

    <div id="header_box" class="clearfix container">
      <div id="project_logo_box">
        <a href="https://www.bfr.bund.de/"><img id="logo_bfr" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_bfr_23.svg" alt="" /></a>
        <a href="https://www.thuenen.de/"><img id="logo_thuenen" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_thuenen.svg" alt="" /></a>
        <a href="https://www.mri.bund.de/"><img id="logo_mri" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_mri.svg" alt="" /></a>
        <a href="https://www.fli.de/"><img id="logo_fli" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_fli.svg" alt="" /></a>
        <a href="https://www.julius-kuehn.de/"><img id="logo_jki" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_jki.svg" alt="" /></a>
        <a href="https://www.dbfz.de/"><img id="logo_dbfz" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_dbfz.svg" alt="" /></a>
        <a href="https://www.bvl.bund.de/"><img id="logo_bvl" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_bvl.png" alt="" /></a>
	<a href="{$WebApplicationBaseURL}"><img id="logo_oa" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_oa.svg" alt="" /></a>
      </div>
      <div id="options_nav_box" class="mir-prop-nav">

        <div class="searchfield_box" title="{i18n:translate('mir.navsearch.title')}">
          <form action="{$WebApplicationBaseURL}servlets/solr/find" class="navbar-form form-inline" role="search">
            <button type="submit" class="btn btn-primary"><i class="fa fa-search"></i></button>
              <input name="condQuery" placeholder="{i18n:translate('mir.navsearch.placeholder')}" class="form-control search-query" id="searchInput" type="text" />
              <xsl:choose>
                <xsl:when test="mcrxsl:isCurrentUserInRole('admin') or mcrxsl:isCurrentUserInRole('editor')">
                  <input name="owner" type="hidden" value="createdby:*" />
                </xsl:when>
                <xsl:when test="not(mcrxsl:isCurrentUserGuestUser())">
                  <input name="owner" type="hidden" value="createdby:{$CurrentUser}" />
                </xsl:when>
              </xsl:choose>
          </form>
        </div>

        <nav>
          <ul class="navbar-nav ml-auto flex-row">
            <xsl:call-template name="mir.loginMenu" />
            <xsl:call-template name="mir.languageMenu" />
          </ul>
        </nav>
      </div>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="navbar navbar-expand mir-main-nav">

    <div class="container">


        <div class="navbar-header">
          <button
                  class="navbar-toggler"
                  type="button"
                  data-toggle="collapse"
                  data-target="#mir-main-nav-collapse-box"
                  aria-controls="mir-main-nav-collapse-box"
                  aria-expanded="false"
                  aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
          </button>
        </div>

        <nav class="collapse navbar-collapse mir-main-nav-entries float-right">
          <ul class="nav navbar-nav pr-0 pt-2 pb-2 pl-0 ml-auto">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='search']" />
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='browse']" />
            <xsl:call-template name="oa.basketMenu" />
            <xsl:call-template name="project.generate_single_menu_entry">
              <xsl:with-param name="menuID" select="'register'"/>
            </xsl:call-template>
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='publish']" />
          </ul>
        </nav>

      </div><!-- /container -->
    </div>
  </xsl:template>

  <xsl:template name="mir.jumbotwo">
    <!-- do nothing special -->
  </xsl:template>

  <xsl:template name="project.generate_single_menu_entry">
    <xsl:param name="menuID" />
    <xsl:if test="$loaded_navigation_xml/menu[@id=$menuID]">
      <li class="nav-item">
        <xsl:variable name="activeClass">
          <xsl:choose>
            <xsl:when test="$loaded_navigation_xml/menu[@id=$menuID]/item[@href = $browserAddress ]">
            <xsl:text>active</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>not-active</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <a id="{$menuID}" href="{$WebApplicationBaseURL}{$loaded_navigation_xml/menu[@id=$menuID]/item/@href}" class="nav-link {$activeClass}" >
          <xsl:choose>
            <xsl:when test="$loaded_navigation_xml/menu[@id=$menuID]/item/label[lang($CurrentLang)] != ''">
              <xsl:value-of select="$loaded_navigation_xml/menu[@id=$menuID]/item/label[lang($CurrentLang)]" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$loaded_navigation_xml/menu[@id=$menuID]/item/label[lang($DefaultLang)]" />
            </xsl:otherwise>
          </xsl:choose>
        </a>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="mir.footer">
    <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
    <div class="container">
      <div class="row">
        <div class="col-9">
          <ul class="internal_links navbar-nav ml-auto flex-row">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='below']/*" />
          </ul>

          <xsl:variable name="tmp" select="calendar:new()"/>
          <p id="oa-copyright"><xsl:value-of select="concat('© ', calendar:get($tmp, 1), ' OpenAgrar')"/></p>
        </div>
        <div class="col-3 text-center">
          <div id="sponsored_by">
            <xsl:choose>
              <xsl:when test="$CurrentLang='en'">
                <a href="https://www.bmel.de/EN/">
                  <img src="{$WebApplicationBaseURL}images/logos/logo_bmelv_en.png" title="Research in the field of BMEL" alt="Research in the field of BMEL" />
                </a>
              </xsl:when>
              <xsl:otherwise>
                <a href="https://www.bmel.de/">
                  <img src="{$WebApplicationBaseURL}images/logos/logo_bmelv.png" title="Forschung im Bereich des BMEL" alt="Forschung im Bereich des BMEL" />
                </a>
              </xsl:otherwise>
            </xsl:choose>
          </div>
          <div id="powered_by">
            <a href="http://www.mycore.de">
              <img src="{$WebApplicationBaseURL}images/logos/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
            </a>
          </div>
        </div>
      </div>
    </div>

    <!-- Matomo/Piwik -->
    <xsl:if test="$piwikID &gt; 0">
      <script type="text/javascript">
            var _paq = _paq || [];
            _paq.push(['setDoNotTrack', true]);
            _paq.push(['trackPageView']);
            _paq.push(['enableLinkTracking']);
            (function() {
              var u="https://matomo.gbv.de/";
              var objectID = '<xsl:value-of select="//site/@ID" />';
              if(objectID != "") {
                _paq.push(["setCustomVariable",1, "object", objectID, "page"]);
              }
              _paq.push(['setTrackerUrl', u+'piwik.php']);
              _paq.push(['setSiteId', '<xsl:value-of select="$piwikID" />']);
              _paq.push(['setDownloadExtensions', '7z|aac|arc|arj|asf|asx|avi|bin|bz|bz2|csv|deb|dmg|doc|exe|flv|gif|gz|gzip|hqx|jar|jpg|jpeg|js|mp2|mp3|mp4|mpg|mpeg|mov|movie|msi|msp|odb|odf|odg|odp|ods|odt|ogg|ogv|pdf|phps|png|ppt|qt|qtm|ra|ram|rar|rpm|sea|sit|tar|tbz|tbz2|tgz|torrent|txt|wav|wma|wmv|wpd|z|zip']);
              var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
              g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
            })();
      </script>
      <noscript><p><img src="https://matomo.gbv.de/piwik.php?idsite={$piwikID}&amp;rec=1" style="border:0;" alt="" /></p></noscript>
    </xsl:if>
  </xsl:template>

  <xsl:template name="mir.powered_by">
    <!-- do nothing -->
  </xsl:template>

  <xsl:template name="oa.basketMenu">
    <xsl:variable name="basketType" select="'objects'" />
    <xsl:variable name="basket" select="document(concat('basket:',$basketType))/basket" />
    <xsl:variable name="entryCount" select="count($basket/entry)" />
    <xsl:variable name="basketTitle">
      <xsl:choose>
        <xsl:when test="$entryCount = 0">
          <xsl:value-of select="i18n:translate('basket.numEntries.none')" disable-output-escaping="yes" />
        </xsl:when>
        <xsl:when test="$entryCount = 1">
          <xsl:value-of select="i18n:translate('basket.numEntries.one')" disable-output-escaping="yes" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="i18n:translate('basket.numEntries.many',$entryCount)" disable-output-escaping="yes" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <li class="dropdown" id="basket-list-item">
      <a class="dropdown-toggle nav-link" data-toggle="dropdown" href="#" title="{$basketTitle}">
        <xsl:value-of select="i18n:translate('basket')" />
        <sup>
          <xsl:value-of select="$entryCount" />
        </sup>
      </a>
      <ul class="dropdown-menu" role="menu">
        <li>
          <a class="dropdown-item" href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type={$basket/@type}&amp;action=show">
            <xsl:value-of select="i18n:translate('basket.open')" />
          </a>
        </li>
      </ul>
    </li>
  </xsl:template>

</xsl:stylesheet>
