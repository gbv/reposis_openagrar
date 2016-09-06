<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
    exclude-result-prefixes="mcrver">

  <xsl:import href="resource:xsl/layout/mir-common-layout.xsl" />
  <xsl:template name="mir.navigation">

    <div id="header_box" class="clearfix container">
      <div id="project_logo_box">
        <a href="http://www.bfr.bund.de/"><img id="logo_bfr" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_bfr.png" alt="" /></a>
        <a href="http://www.ti.bund.de/"><img id="logo_thuenen" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_thuenen.png" alt="" /></a>
        <a href="http://www.mri.bund.de/"><img id="logo_mri" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_mri.png" alt="" /></a>
        <a href="http://www.fli.bund.de/"><img id="logo_fli" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_fli.png" alt="" /></a>
        <a href="http://www.jki.bund.de/"><img id="logo_jki" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_jki.png" alt="" /></a>
        <a href="{$WebApplicationBaseURL}"><img id="logo_oa" class="head_logo" src="{$WebApplicationBaseURL}images/logos/logo_oa.png" alt="" /></a>
      </div>
      <div id="options_nav_box" class="mir-prop-nav">

        <div class="searchfield_box">
          <form action="{$WebApplicationBaseURL}servlets/solr/find?q={0}" class="navbar-form navbar-left pull-right" role="search">
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
          <ul class="nav navbar-nav pull-left">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='search']" />
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='browse']" />
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='register']/*" />
            <!--  xsl:apply-templates select="$loaded_navigation_xml/menu[@id='publish']" / -->
            <xsl:call-template name="mir.basketMenu" />
          </ul>
        </nav>

      </div><!-- /container -->
    </div>
  </xsl:template>

  <xsl:template name="mir.jumbotwo">
    <!-- do nothing special -->
  </xsl:template>

  <xsl:template name="mir.footer">
    <div class="container">
      <div class="row">
        <div class="col-md-4">
          <p>© 2016 OpenAgrar</p>
        </div>
        <div class="col-md-8">
          <ul class="internal_links nav navbar-nav">
            <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='below']/*" />
          </ul>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="mir.powered_by">
    <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
    <div class="container">
      <div class="row">
        <div class="col-md-6">
          <div id="powered_by">
            <a href="http://www.mycore.de">
              <img src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
            </a>
          </div>
        </div>
        <div class="col-md-6">
          <div id="sponsored_by">
            <a href="http://www.bmel.de/">
              <img src="{$WebApplicationBaseURL}images/logos/logo_bmelv.png" title="Forschung im Bereich des BMEL" alt="Forschung im Bereich des BMEL" />
            </a>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>