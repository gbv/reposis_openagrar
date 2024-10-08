<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mods="http://www.loc.gov/mods/v3" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                version="1.0"
                exclude-result-prefixes="i18n mods xlink mcrxsl">
  <!-- copied from http://www.loc.gov/standards/mods/v3/MODS3-4_HTML_XSLT1-0.xsl -->
  <xsl:include href="layout-utils.xsl" />


  <xsl:template match="/">
    <div id="system_box" class="detailbox">
      <h4 id="system_switch" class="block_switch">
        <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.systembox')"/>
      </h4>
      <div id="system_content" class="block_content">
        <table class="metaData">
          <!--*** publication status ************************************* -->
          <tr>
            <td class="metaname">
              <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.status'),':')"/>
            </td>
            <td class="metavalue">
              <xsl:call-template name="printClass">
                <xsl:with-param select="mycoreobject/service/servstates/servstate" name="nodes"/>
              </xsl:call-template>
            </td>
          </tr>
          <xsl:call-template name="printMetaDate">
            <xsl:with-param select="mycoreobject/service/servdates/servdate[@type='createdate']" name="nodes"/>
            <xsl:with-param select="i18n:translate('metaData.createdAt')" name="label"/>
          </xsl:call-template>
          <xsl:call-template name="printMetaDate">
            <xsl:with-param select="mycoreobject/service/servflags/servflag[@type='createdby']" name="nodes"/>
            <xsl:with-param select="i18n:translate('metaData.createdby')" name="label"/>
          </xsl:call-template>
          <!--*** Last Modified ************************************* -->
          <xsl:call-template name="printMetaDate">
            <xsl:with-param select="mycoreobject/service/servdates/servdate[@type='modifydate']" name="nodes"/>
            <xsl:with-param select="i18n:translate('metaData.lastChanged')" name="label"/>
          </xsl:call-template>
          <xsl:call-template name="printMetaDate">
            <xsl:with-param select="mycoreobject/service/servflags/servflag[@type='modifiedby']" name="nodes"/>
            <xsl:with-param select="i18n:translate('metaData.modifiedBy')" name="label"/>
          </xsl:call-template>
          <!--*** MyCoRe-ID and intern ID *************************** -->
          <tr>
            <td class="metaname">
              <xsl:value-of select="concat(i18n:translate('metaData.ID'),':')"/>
            </td>
            <td class="metavalue">
              <xsl:value-of select="mycoreobject/@ID"/>
            </td>
          </tr>
          <xsl:call-template name="printMetaDate">
            <xsl:with-param
                select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='intern']"
                name="nodes"/>
            <xsl:with-param select="i18n:translate('component.mods.metaData.dictionary.identifier.intern')"
                            name="label"/>
          </xsl:call-template>
          <!-- tr>
            <td class="metaname">
              <xsl:value-of select="concat(i18n:translate('metaData.versions'),' :')" />
            </td>
            <td class="metavalue">
              <xsl:apply-templates select="." mode="versioninfo" />
            </td>
          </tr -->
          <tr>
            <td class="metaname">
              <xsl:value-of select="i18n:translate('metadata.versionInfo.version')"/>
              <xsl:text>:</xsl:text>
            </td>
            <td class="metavalue">
              <xsl:variable name="verinfo" select="document(concat('versioninfo:',mycoreobject/@ID))"/>
              <xsl:variable name="revision">
                <xsl:call-template name="UrlGetParam">
                  <xsl:with-param name="url" select="$RequestURL"/>
                  <xsl:with-param name="par" select="'r'"/>
                </xsl:call-template>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="not($revision = '')">
                  <xsl:for-each select="$verinfo/versions/version">
                    <xsl:sort order="descending" select="position()" data-type="number"/>
                    <xsl:if test="$revision = @r">
                      <xsl:number/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="count($verinfo/versions/version)"/>
                </xsl:otherwise>
              </xsl:choose>
              <br/>
              <a id="historyStarter" style="cursor: pointer">
                <xsl:value-of select="i18n:translate('metadata.versionInfo.startLabel')"/>
              </a>
            </td>
          </tr>
        </table>
      </div>
    </div>
  </xsl:template>
</xsl:stylesheet>
