<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" 
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  exclude-result-prefixes="acl mcrxsl mods"
  xmlns:ex="http://exslt.org/dates-and-times" 
  xmlns:exslt="http://exslt.org/common"
  extension-element-prefixes="ex exslt"
>
  <xsl:variable name="read" select="'read'" />
  <xsl:variable name="write" select="'writedb'" />
  <xsl:variable name="delete" select="'deletedb'" />
  <xsl:variable name="addurn" select="'addurn'" />
  
  <!-- checks for AccessKey enabled (default is enabled for 'mods')    -->
  <!-- to enable set # MIR.Strategy.AccessKey.ObjectTypes=mods,derivate-->
  <xsl:param name="MCR.Access.Strategy.Class" />
  <xsl:param name="MIR.Strategy.AccessKey.ObjectTypes" />
  <xsl:variable name="derivateAccKeyEnabled" select="contains($MCR.Access.Strategy.Class, 'MIRStrategy') and contains($MIR.Strategy.AccessKey.ObjectTypes, 'derivate')" />
  <xsl:variable name="modsAccKeyEnabled" select="contains($MCR.Access.Strategy.Class, 'MIRStrategy') and contains($MIR.Strategy.AccessKey.ObjectTypes, 'mods')" />
  
  <xsl:param name="MCR.PI.Registration.Services"  select="''" />
  
  <xsl:include href="coreFunctions.xsl"/>
  
  <xsl:template match="/mycoreobject">
    <xsl:copy>
      <xsl:copy-of select="@*|node()" />
      <xsl:variable name="parentReadable" select="acl:checkPermission(@ID, $read)" />
      <rights>
        <xsl:message>
          Adding rights section
        </xsl:message>
        <xsl:for-each select="@ID|structure/*/*/@xlink:href">
          <xsl:call-template name="check-rights">
            <xsl:with-param name="id" select="." />
            <xsl:with-param name="parentReadable" select="$parentReadable" />
          </xsl:call-template>
        </xsl:for-each>
      </rights>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="check-rights">
    <xsl:param name="id" />
    <xsl:param name="parentReadable" select="false()" />
    <right id="{$id}">
        <!-- any mycoreobject here -->
          <xsl:if test="$parentReadable and $id=/mycoreobject/@ID">
            <xsl:attribute name="view" />
          </xsl:if>
          <xsl:call-template name="check-default-rights">
            <xsl:with-param name="id" select="$id" />
          </xsl:call-template>
          <xsl:if test="$modsAccKeyEnabled">
            <xsl:call-template name="check-access-keys">
              <xsl:with-param name="id" select="$id" />
            </xsl:call-template>
          </xsl:if>
    </right>
  </xsl:template>

  <xsl:template name="check-default-rights">
    <xsl:param name="id" />
    <xsl:message>
      checking read permission
    </xsl:message>
    <xsl:if test="acl:checkPermission($id,$read)">
      <xsl:attribute name="read" />
      <xsl:message>
        checking write permission
      </xsl:message>
      <xsl:if test="acl:checkPermission($id,$write)">
        <xsl:attribute name="write" />
        <xsl:if test="acl:checkPermission($id,$addurn)">
          <xsl:attribute name="addurn" />
        </xsl:if>
        <xsl:if test="acl:checkPermission($id,$delete)">
          <xsl:attribute name="delete" />
        </xsl:if>
        <xsl:variable name="piServicesArray"> 
          <xsl:call-template name="Tokenizer"><!-- use split function from mycore-base/coreFunctions.xsl -->
            <xsl:with-param name="string" select="$MCR.PI.Registration.Services" />
            <xsl:with-param name="delimiter" select="','" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="exslt:node-set($piServicesArray)/token">
          <xsl:variable name="serviceName" select="concat('register-',.)" />
          <xsl:if test="acl:checkPermission($id,$serviceName)">
            <xsl:attribute name="{$serviceName}" />
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="check-access-keys">
    <xsl:param name="id" />
    <xsl:variable name="accKey" select="document(concat('accesskeys:', $id))/accesskeys" />
    <xsl:message>
      checking for access keys
    </xsl:message>
    <xsl:attribute name="accKeyEnabled" /> <!-- need this to show menu -->
    <xsl:if test="$accKey/@readkey">
      <xsl:attribute name="readKey" />
    </xsl:if>
    <xsl:if test="$accKey/@writekey">
      <xsl:attribute name="writeKey" />
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>