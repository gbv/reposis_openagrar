<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink" 
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                version="1.0"
                
                >
  <xsl:include href="copynodes.xsl" />
 
  <xsl:variable name="zdbId" select="//mods:mods/mods:identifier[@type='zdbid']" />
  
  <xsl:template match="mods:originInfo[@eventType='publication'][not(mods:publisher)]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
	  <xsl:apply-templates select="*" />
	  <xsl:call-template name="getPublisherFromZDB">
      </xsl:call-template>
	</xsl:copy>
  </xsl:template>
   
  <xsl:template match="mods:mods[not(mods:originInfo[@eventType='publication'])]">
    <xsl:copy>
      
	  <xsl:apply-templates select="*" />
      
      <mods:originInfo eventType="publication">
        <xsl:call-template name="getPublisherFromZDB">
        </xsl:call-template>
      </mods:originInfo>
	  
    </xsl:copy>
  </xsl:template>

  <xsl:template name="getPublisherFromZDB">
    <xsl:variable name="rdf" select="document(concat('http://services.dnb.de/sru/zdb?version=1.1&amp;operation=searchRetrieve&amp;query=zdbid%3D',$zdbId,'&amp;recordSchema=RDFxml'))" />
    <xsl:if test="$rdf//rdf:Description/dc:publisher">
      <mods:publisher>
        <xsl:value-of select="$rdf//rdf:Description/dc:publisher" />
      </mods:publisher>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
