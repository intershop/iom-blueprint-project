<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:s0="http://types.theberlinbakery.com/v1_0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
	xmlns:ord="http://types.theberlinbakery.com/v1_0">

	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />

	<xsl:template match="soapenv:Envelope/soapenv:Body/*">
		<xsl:element name="s0:ShopEnvelope">
			<xsl:copy-of select="*"/>
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>
