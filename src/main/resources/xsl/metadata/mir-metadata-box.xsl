<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
                exclude-result-prefixes="i18n mods xlink xalan mcrxsl acl">
  <xsl:import href="xslImport:modsmeta:metadata/mir-metadata-box.xsl" />
  <xsl:include href="modsmetadata.xsl" />
  <xsl:include href="mir-mods-utils.xsl" />
  <!-- copied from http://www.loc.gov/standards/mods/v3/MODS3-4_HTML_XSLT1-0.xsl -->
  <!-- oa specific includes-->
  <xsl:include href="../date.statistic.xsl"/>
  <!--oa specific includes end -->

  <xsl:key use="@type" name="title-by-type" match="//mods:mods/mods:titleInfo" />

  <xsl:template match="/">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
    <!-- $mods-type contains genre -->
    <div id="mir-metadata">
      <xsl:apply-templates />
      <!--
      <dl>
        <dt>metaname</dt>
        <dd>metavalue</dd>
      </dl>
       -->
      <table class="mir-metadata">

        <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[@type and
                                  count(. | key('title-by-type',@type)[1])=1]">
          <tr>
            <td valign="top" class="metaname">
              <xsl:choose>
                <xsl:when test="@displayLabel">
                  <xsl:value-of select="@displayLabel" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="i18n:translate(concat('mir.title.type.', @type))" />
                </xsl:otherwise>
              </xsl:choose>
              <xsl:text>:</xsl:text>
            </td>
            <td class="metavalue">
              <xsl:for-each select="key('title-by-type',@type)">
                <xsl:if test="position()!=1">
                  <br />
                </xsl:if>
                <xsl:apply-templates select="//modsContainer/mods:mods" mode="mods.title">
                  <xsl:with-param name="type" select="@type" />
                  <xsl:with-param name="asHTML" select="true()" />
                  <xsl:with-param name="withSubtitle" select="true()" />
                  <xsl:with-param name="position" select="position()" />
                </xsl:apply-templates>
                <xsl:if test="@type='translated'">
                  <xsl:text> (</xsl:text>
                  <xsl:value-of select="mcrxsl:getDisplayName('rfc5646',@xml:lang)" />
                  <xsl:text>)</xsl:text>
                </xsl:if>
              </xsl:for-each>
            </td>
          </tr>
        </xsl:for-each>

        <xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:name[@type='conference']/mods:namePart[not(@type)]" />
          <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.conference.title')" />
        </xsl:call-template>


        <xsl:variable name="institutesURI" select="document('classification:metadata:-1:children:mir_institutes')/mycoreclass/label[@xml:lang='x-uri']/@text" />

        <!-- mods:name grouped by mods:role/mods:roleTerm excluding author-->
        <xsl:for-each
                select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:name[not(@ID) and
                      (@type='personal' or (@type='corporate' and not(@authorityURI = $institutesURI)))
                      and not(mods:role/mods:roleTerm='aut') and count(. | key('name-by-role',mods:role/mods:roleTerm)[1])=1]">
          <!-- for every role -->
          <xsl:choose>
            <!-- check if 'aut' and 'edt' show 'edt', otherwise 'edt' is already shown in abstract-box -->
            <xsl:when test="mods:role/mods:roleTerm='edt' and not(../mods:name/mods:role/mods:roleTerm='aut')">
              <!-- do nothing -->
            </xsl:when>
            <!-- check if role term is given -->
            <xsl:when test="not(mods:role/mods:roleTerm)">
              <!-- do nothing -->
            </xsl:when>
            <xsl:otherwise>
              <tr>
                <td valign="top" class="metaname">
                  <xsl:choose>
                    <xsl:when test="mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']">
                      <xsl:apply-templates select="mods:role/mods:roleTerm[@authority='marcrelator' and @type='code']"
                                           mode="printModsClassInfo" />
                      <xsl:value-of select="':'" />
                    </xsl:when>
                    <xsl:when test="mods:role/mods:roleTerm[@authority='marcrelator']">
                      <xsl:value-of
                              select="concat(i18n:translate(concat('component.mods.metaData.dictionary.',mods:role/mods:roleTerm[@authority='marcrelator'])),':')" />
                    </xsl:when>
                  </xsl:choose>
                </td>
                <td class="metavalue">
                  <xsl:for-each select="key('name-by-role',mods:role/mods:roleTerm)">
                    <xsl:if test="position()!=1">
                      <xsl:value-of select="'; '" />
                    </xsl:if>
                    <xsl:apply-templates select="." mode="mirNameLink" />
                  </xsl:for-each>
                  <xsl:if test="$mods/mods:name/mods:etal">
                    <em>et.al.</em>
                  </xsl:if>
                </td>
              </tr>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>

        <xsl:for-each select="mycoreobject">
          <xsl:if test="./structure/parents/parent/@xlink:href">
            <!-- START: OA specific changes -->
            <xsl:call-template name="printMetaDate.mods.relatedItem.oa">
              <xsl:with-param name="parentID" select="./structure/parents/parent/@xlink:href" />
              <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.confpubIn')" />
            </xsl:call-template>
            <!-- END: OA specific changes -->
          </xsl:if>
        </xsl:for-each>
            <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[not(@type='host' and @xlink:href)]">
              <xsl:variable name="relItemLabel">
          <xsl:choose>
                  <xsl:when test="@displayLabel">
                    <xsl:value-of select="@displayLabel"/>
                  </xsl:when>
                  <xsl:when test="@type">
                    <xsl:value-of select="i18n:translate(concat('mir.relatedItem.', @type))"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="i18n:translate('mir.relatedItem')"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:choose>
            <xsl:when test="@xlink:href">
              <xsl:call-template name="printMetaDate.mods.relatedItems">
                <xsl:with-param name="parentID" select="./@xlink:href" />
                    <xsl:with-param name="label" select="$relItemLabel" />
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                  <xsl:call-template name="printMetaDate.mods.relatedItems">
                    <xsl:with-param name="parentID" select="''" />
                    <xsl:with-param name="label" select="$relItemLabel" />
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
        <!-- START: OA specific changes -->
        <!-- xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume']/mods:number" />
          <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.volume.article')" />
        </xsl:call-template>
        <xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:number" />
          <xsl:with-param name="label" select="i18n:translate('mir.details.issue')" />
        </xsl:call-template -->
        <!-- END: OA specific changes -->
        <xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='volume']/mods:number" />
          <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.volume.article')" />
        </xsl:call-template>
        <xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@type='host']/mods:part/mods:detail[@type='issue']/mods:number" />
          <xsl:with-param name="label" select="i18n:translate('mir.details.issue')" />
        </xsl:call-template>
        <xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo/mods:edition" />
        </xsl:call-template>
        <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:dateCreated"
                             mode="present" />
        <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:dateOther[@type='submitted']"
                             mode="present">
          <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.dateSubmitted')" />
        </xsl:apply-templates>
        <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:dateOther[@type='accepted']"
                             mode="present">
          <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.dateAccepted')" />
        </xsl:apply-templates>
        <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='review']/mods:dateOther[@type='reviewed']"
                             mode="present">
          <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.dateReviewed')" />
        </xsl:apply-templates>
        <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='collection']/mods:dateCaptured"
                             mode="present" />
        <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']"
                             mode="present" />
        <!-- Begin: OA specific Date Types -->
        <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='publication_print']/mods:dateIssued[@encoding='w3cdtf']"
          mode="present" >
          <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.dateIssued.print')" />
        </xsl:apply-templates>
        <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='publication_online']/mods:dateIssued[@encoding='w3cdtf']"
          mode="present" >
          <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.dateIssued.online')" />
        </xsl:apply-templates>
        <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='digitalisation']/mods:dateIssued[@encoding='w3cdtf']"
          mode="present" >
          <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.dateIssued.digitalisation')" />
        </xsl:apply-templates>
        <!-- End: OA specific Date Types -->
        <xsl:apply-templates select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='update']/mods:dateModified"
                             mode="present" />
        <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type!='open-aire' and @type!='intern' and @type!='issn']" />
        <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='issn']">
          <tr>
            <td class="metaname" valign="top">
              <xsl:value-of select="i18n:translate('mir.identifier.issn')" />
            </td>
            <td class="metavalue">
              <xsl:value-of select="."/>
            </td>
          </tr>
        </xsl:for-each>
        <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:language" />
        <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:typeOfResource">
          <tr>
            <td class="metaname" valign="top">
              <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.typeOfResource')" />
              <text>:</text>
            </td>
            <td class="metavalue">
              <xsl:value-of select="document(concat('classification:metadata:0:children:typeOfResource:', translate(./text(),' ','_')))//category/label[@xml:lang=$CurrentLang]/@text"/>
            </td>
          </tr>
        </xsl:for-each>
        <xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes"
                          select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:physicalDescription/mods:extent" />
        </xsl:call-template>
        <xsl:apply-templates mode="openaire" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:identifier[@type='open-aire']" />
        <xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes"
                          select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[not(@authority='marccountry')]" />
        </xsl:call-template>
        <xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes"
                          select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:place/mods:placeTerm[not(@authority='marccountry')]" />
          <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.placeTerm.creation')" />
        </xsl:call-template>
        <xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher" />
        </xsl:call-template>
        <xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:originInfo[@eventType='creation']/mods:publisher" />
          <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.publisher.creation')" />
        </xsl:call-template>
        <!-- <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:subject">  -->
        <xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes" select="//mods:mods/mods:subject/mods:topic" />
          <xsl:with-param name="label" select="i18n:translate('component.mods.metaData.dictionary.subject')" />
          <xsl:with-param name="sep" select="'; '" />
          <xsl:with-param name="property" select="'keyword'" />
        </xsl:call-template>
        <!-- </xsl:for-each>  -->
        <xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:subject/mods:geographic" />
        </xsl:call-template>
        <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:subject/mods:cartographics/mods:coordinates">
          <tr>
            <td class="metaname" valign="top">
              <xsl:value-of select="i18n:translate('mir.cartographics.coordinates')" />
            </td>
            <td class="metavalue">
              <xsl:choose>
                <xsl:when test="contains(., ', ')">
                  <div id="displayCoords" data-fullcoords="{.}">
                    <xsl:value-of select="substring-before(., ', ')" />
                    <a id="flipCoords" role="button">...</a>
                  </div>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="." />
                </xsl:otherwise>
              </xsl:choose>
              <div>
                <button type="button" class="show_openstreetmap btn btn-secondary" data-coords="{.}" >
                  OpenStreetMap
                </button>
              </div>
              <div class="openstreetmap-container collapse">
                <div class="map"></div>
              </div>
            </td>
          </tr>
        </xsl:for-each>
            <!-- START: OA specific changes -->
            <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[not(@generator) and
                                                        not(@authorityURI='https://www.openagrar.de/classifications/annual_review')]" />
            <!-- END: OA specific changes -->
        <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:part/mods:extent" />
        <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:location/mods:url" />
        <xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:location/mods:physicalLocation[not(starts-with(@xlink:href, '#'))]" />
        </xsl:call-template>
        <xsl:call-template name="printMetaDate.mods">
          <xsl:with-param name="nodes" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:location/mods:shelfLocator" />
          <xsl:with-param name="label" select="i18n:translate('mir.shelfmark')" />
        </xsl:call-template>
            <!-- START: OA specific changes -->
            <!-- xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:name[@type='corporate'][@ID or @authorityURI=$institutesURI]" />
            <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:extension[@displayLabel='characteristics']" / -->
            <!-- END: OA specific changes -->
        <xsl:for-each select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:note">
          <xsl:variable name="myURI" select="concat('classification:metadata:0:children:noteTypes:',mcrxsl:regexp(@type,' ', '_'))" />
          <xsl:variable name="x-access">
            <xsl:value-of select="document($myURI)//label[@xml:lang='x-access']/@text"/>
          </xsl:variable>
          <xsl:variable name="noteLabel">
            <xsl:value-of select="document($myURI)//category/label[@xml:lang=$CurrentLang]/@text"/>
          </xsl:variable>
          <xsl:if test="contains($x-access, 'guest')">
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param select="." name="nodes" />
              <xsl:with-param select="$noteLabel" name="label"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>

            <!-- START: OA specific changes -->
            <xsl:if test="not(mcrxsl:isCurrentUserGuestUser())">
              <xsl:apply-templates mode="oa" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:extension[@displayLabel='characteristics']" />
              <xsl:apply-templates mode="oa" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem/mods:extension[@displayLabel='metrics']" />
              <xsl:apply-templates mode="oa" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:extension[@displayLabel='metrics']" />
              <xsl:apply-templates mode="present" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:classification[@authorityURI='https://www.openagrar.de/classifications/annual_review']" />
            </xsl:if>
            
            <xsl:apply-templates mode="oa" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:name[@type='corporate'][@ID or @authorityURI=$institutesURI]" />
            <!-- END: OA specific changes -->
      </table>

    </div>
    <xsl:apply-imports />
  </xsl:template>


  <!-- OA specific templates -->
  <xsl:template match="mods:name[@type='corporate' and @ID]" mode="oa">
    <xsl:variable name="id" select="concat('#', @ID)" />
    <tr>
      <td valign="top" class="metaname">
        <span class="oa-noteLocationCorp-meta"><xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.institution.label'),':')" /></span>
      </td>
      <td class="metavalue">
        <span class="oa-noteLocationCorp-meta"><xsl:apply-templates select="." mode="printName" /></span>
      </td>
    </tr>
    <xsl:if
      test="(not(mcrxsl:isCurrentUserGuestUser()) and ./../mods:note[@xlink:href=$id]) or (./../mods:location/mods:physicalLocation[@xlink:href=$id])">
      <tr>
        <td colspan="2">
          <table class="metaData">
            <xsl:if test="not(mcrxsl:isCurrentUserGuestUser())">
              <xsl:call-template name="printMetaDate.mods">
                <xsl:with-param name="nodes" select="./../mods:note[@xlink:href=$id]" />
              </xsl:call-template>
            </xsl:if>
            <xsl:call-template name="printMetaDate.mods">
              <xsl:with-param name="nodes" select="./../mods:location/mods:physicalLocation[@xlink:href=$id]" />
            </xsl:call-template>
          </table>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template name="printMetaDate.mods.relatedItem.oa">
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
            <xsl:if test="mods:part/mods:detail[@type='issue']/mods:number or mods:part/mods:detail[@type='article_number'] ">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:if>
          <!-- Issue -->
          <xsl:if test="mods:part/mods:detail[@type='issue']/mods:number">
            <xsl:value-of
                    select="concat('H. ',mods:part/mods:detail[@type='issue']/mods:number)" />
          </xsl:if>
          <xsl:if test="mods:part/mods:detail[@type='issue']/mods:number and (mods:part/mods:detail[@type='article_number'] or mods:part/mods:date or mods:originInfo[@eventType='publication']/mods:dateIssued)">
            <xsl:text> </xsl:text>
          </xsl:if> 
          <!-- Article number -->
          <xsl:if test="mods:part/mods:detail[@type='article_number']/mods:number">
            <xsl:value-of
              select="concat(i18n:translate('mir.articlenumber.short'),mods:part/mods:detail[@type='article_number']/mods:number)" />
          </xsl:if>
          <xsl:if test="mods:part/mods:detail[@type='article_number']/mods:number and (mods:part/mods:date or mods:originInfo[@eventType='publication']/mods:dateIssued)">
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

  <xsl:template match="mods:extension[@displayLabel='characteristics']" mode="oa">
    <xsl:if test="not(mcrxsl:isCurrentUserGuestUser())">
      <xsl:if test="chars/@refereed">
        <tr>
          <td valign="top" class="metaname">
            <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.characteristics'),':')" />
          </td>
          <td class="metavalue">
            <xsl:value-of select="i18n:translate(concat('component.mods.metaData.dictionary.refereed.',chars/@refereed))" />
          </td>
        </tr>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:extension[@displayLabel='metrics']" mode="oa">

    <xsl:if test="not(mcrxsl:isCurrentUserGuestUser())">
      <xsl:for-each select="articleMetrics/metric">
        <tr>
          <td valign="top" class="metaname">
            <xsl:value-of select="concat(@type,':')" />
          </td>
          <td class="metavalue">
            <xsl:value-of select="value"/>
          </td>
        </tr>
      </xsl:for-each>
      <xsl:if test="journalMetrics">
        <tr>
          <td valign="top" class="metaname">
            <xsl:value-of select="concat('Journal Metrics',':')" />
          </td>
          <td class="metavalue">
            <table class="table table-condensed">
              <tr>
                <th>
                  <xsl:value-of select="'Jahr'"/>
                </th>
                <xsl:for-each select="journalMetrics/metric">
                  <th>
                    <xsl:value-of select="@type"/>
                  </th>
                </xsl:for-each>
              </tr>
              <xsl:for-each select="//journalMetrics/metric/value[not(preceding::value/@year = @year)]">
                <xsl:sort select="@year" data-type="number"/>
                <xsl:variable name="year" select="@year"/>
                <tr>
                  <td>
                    <xsl:value-of select="$year"/>
                  </td>
                  <xsl:for-each select="//journalMetrics/metric">
                    <td>
                      <xsl:choose>
                        <xsl:when test="@type='JCR'">
                          <xsl:choose>
                            <xsl:when test="acl:checkPermission('crypt:cipher:jcr','decrypt')">
                              <xsl:variable name="decrypturi" select="concat('crypt:decrypt:jcr:',value[@year = $year])"/>
                              <xsl:value-of select="document($decrypturi)/value"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="'Cant decrypt JCR'"/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="value[@year = $year]"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </td>
                  </xsl:for-each>
                </tr>
              </xsl:for-each>
            </table>
          </td>
        </tr>
      </xsl:if>

    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:relatedItem[@type='host' or @type='series']/mods:extension[@displayLabel='metrics']" mode="oa">
    <xsl:variable name="dateIssued_statistics">
      <xsl:call-template name="getDateStatistic">
        <xsl:with-param name="mods" select="//mods:mods"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="yearIssued" select="substring($dateIssued_statistics,1,4)"/>
    <tr>
      <td valign="top" class="metaname">
        <xsl:value-of select="concat('Journal Metrics',':')" />
      </td>
      <td class="metavalue">
        <table class="table table-condensed">
          <xsl:for-each select="journalMetrics/metric[value/@year = $yearIssued]">
            <tr>
              <td>
                <xsl:value-of select="@type"/>
              </td>
              <td>
                <xsl:choose>
                  <xsl:when test="@type='JCR'">
                    <xsl:choose>
                      <xsl:when test="acl:checkPermission('crypt:cipher:jcr','decrypt')">
                        <xsl:variable name="decrypturi" select="concat('crypt:decrypt:jcr:',value[@year = $yearIssued])"/>
                        <xsl:value-of select="document($decrypturi)/value"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="'Cant decrypt JCR'"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="value[@year=$yearIssued]"/>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
            </tr>
          </xsl:for-each>
        </table>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
