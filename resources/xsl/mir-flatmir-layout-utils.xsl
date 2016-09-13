<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
    xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
    xmlns:basket="xalan://org.mycore.frontend.basket.MCRBasketManager"
    exclude-result-prefixes="mcrver i18n basket">
  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />
  <xsl:param name="piwikID" select="'2'" />

  <xsl:template name="mir.navigation">

    <div id="header_box" class="clearfix container">
      <div id="project_logo_box">
        <a href="http://www.bfr.bund.de/"><img id="logo_bfr" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_bfr.png" alt="" /></a>
        <a href="http://www.thuenen.de/"><img id="logo_thuenen" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_thuenen.png" alt="" /></a>
        <a href="https://www.mri.bund.de/"><img id="logo_mri" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_mri.png" alt="" /></a>
        <a href="https://www.fli.de/"><img id="logo_fli" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_fli.png" alt="" /></a>
        <a href="http://www.jki.bund.de/"><img id="logo_jki" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_jki.png" alt="" /></a>
        <a href="https://www.dbfz.de/"><img id="logo_dbfz" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_dbfz.png" alt="" /></a>
        <a href="{$WebApplicationBaseURL}"><img id="logo_oa" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_oa.png" alt="" /></a>
      </div>
      <div id="options_nav_box" class="mir-prop-nav">

        <div class="searchfield_box">
          <form action="{$WebApplicationBaseURL}servlets/solr/find?q={0}" class="navbar-form navbar-left" role="search">
            <button type="submit" class="btn btn-primary"><i class="fa fa-search"></i></button>
            <div class="form-group">
              <input name="q" placeholder="Schnellsuche" class="form-control search-query" id="searchInput" type="text" />
            </div>
          </form>
        </div>

        <nav>
          <ul class="nav navbar-nav pull-right">
            <xsl:call-template name="mir.loginMenu" />
          </ul>
        </nav>
      </div>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="navbar navbar-default mir-main-nav">
      <div class="container">

        <div class="navbar-header">
          <button class="navbar-toggle" type="button" data-toggle="collapse" data-target=".mir-main-nav-entries">
            <span class="sr-only"> Toggle navigation </span>
            <span class="icon-bar">
            </span>
            <span class="icon-bar">
            </span>
            <span class="icon-bar">
            </span>
          </button>
        </div>

        <nav class="collapse navbar-collapse mir-main-nav-entries">
          <ul class="nav navbar-nav pull-right">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='search']" />
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='browse']" />
            <xsl:call-template name="oa.basketMenu" />
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='register']/*" />
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='publish']" />
          </ul>
        </nav>

      </div><!-- /container -->
    </div>
  </xsl:template>

  <xsl:template name="mir.jumbotwo">
    <!-- do nothing special -->
  </xsl:template>

  <xsl:template name="mir.footer">
    <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
    <div class="container">
      <div class="row">
        <div class="col-md-9">
          <ul class="internal_links nav navbar-nav">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='below']/*" />
          </ul>
          <p id="oa-copyright">© 2016 OpenAgrar</p>
        </div>
        <div class="col-md-3 text-center">
          <div id="sponsored_by">
            <a href="http://www.bmel.de/">
              <img src="{$WebApplicationBaseURL}images/logos/logo_bmelv.png" title="Forschung im Bereich des BMEL" alt="Forschung im Bereich des BMEL" />
            </a>
          </div>
          <div id="powered_by">
            <a href="http://www.mycore.de">
              <img src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
            </a>
          </div>
        </div>
      </div>
    </div>

    <!-- Piwik -->
    <script type="text/javascript">
      var _paq = _paq || [];
      _paq.push(["setDomains", ["*.openagrar.bmel-forschung.de","*.esx-179.gbv.de","*.www.openagrar.de"]]);
      _paq.push(["setDoNotTrack", true]);
      _paq.push(["trackPageView"]);
      _paq.push(["enableLinkTracking"]);

      (function() {
        var u="//openagrar.bmel-forschung.de/piwik/piwik/";
        var objectID = '<xsl:value-of select="/mycoreobject/@ID" />';
        if(objectID != "") {
          _paq.push(["setCustomVariable",1, "object", objectID, "page"]);
        }
        _paq.push(["setTrackerUrl", u+"piwik.php"]);
        _paq.push(["setSiteId", "<xsl:value-of select="$piwikID" />"]);
        _paq.push(["setDownloadExtensions", "7z|aac|arc|arj|asf|asx|avi|bin|bz|bz2|csv|deb|dmg|doc|exe|flv|gif|gz|gzip|hqx|jar|jpg|jpeg|js|mp2|mp3|mp4|mpg|mpeg|mov|movie|msi|msp|odb|odf|odg|odp|ods|odt|ogg|ogv|pdf|phps|png|ppt|qt|qtm|ra|ram|rar|rpm|sea|sit|tar|tbz|tbz2|tgz|torrent|txt|wav|wma|wmv|wpd|z|zip"]);
        var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
        g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
      })();
    </script>
    <noscript>
      <!-- Piwik Image Tracker -->
      <img src="//openagrar.bmel-forschung.de/piwik/piwik/piwik.php?idsite={$piwikID}&amp;rec=1" style="border:0" alt="" />
      <!-- End Piwik -->
    </noscript>
    <!-- End Piwik Code -->
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
      <a class="dropdown-toggle" data-toggle="dropdown" href="#" title="{$basketTitle}">
        Merkliste
        <sup>
          <xsl:value-of select="$entryCount" />
        </sup>
      </a>
      <ul class="dropdown-menu" role="menu">
        <li>
          <a href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type={$basket/@type}&amp;action=show">
            <xsl:value-of select="i18n:translate('basket.open')" />
          </a>
        </li>
      </ul>
    </li>
  </xsl:template>

</xsl:stylesheet>