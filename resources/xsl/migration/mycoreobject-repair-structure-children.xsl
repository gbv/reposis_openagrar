<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:mcrdataurl="xalan://org.mycore.datamodel.common.MCRDataURL"
  xmlns:xlink="http://www.w3.org/1999/xlink" >
  
  <xsl:include href="copynodes.xsl" />
  
  
  <xsl:variable name="objId" select="/mycoreobject/@ID" />
  
  <!-- delete all children and overwrite with result of a search -->
  <!-- <xsl:template match="//structure/children[@class='MCRMetaLinkID']">  -->
  
  <xsl:template match="children"> 
    <children class="MCRMetaLinkID">
       <xsl:variable name="children" xmlns:encoder="xalan://java.net.URLEncoder"
          select="document(concat('solr:q=',encoder:encode(concat('parent:',  $objId,' AND objectType:mods&amp;rows=1000&amp;fl=id')) ))" />
      <xsl:for-each select="$children//result[@name='response']/doc/str[@name='id']">
        <child inherited="0" xlink:type="locator" >
          <xsl:attribute name="xlink:title">
            <xsl:value-of select="." />
          </xsl:attribute>
          <xsl:attribute name="xlink:href">
            <xsl:value-of select="." />
          </xsl:attribute>
       </child>   
      </xsl:for-each>
     
     <child inherited="0" xlink:type="locator" xlink:title="import_mods_00000724" xlink:href="import_mods_00000724"/>
    </children>
  </xsl:template>
  
  
</xsl:stylesheet>