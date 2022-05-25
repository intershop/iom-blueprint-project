<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xslt:stylesheet xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:date="http://exslt.org/dates-and-times" xmlns:str="http://exslt.org/strings"
	xmlns:xslt="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:xf="http://www.ecrion.com/xf/1.0" xmlns:xc="http://www.ecrion.com/2008/xc"
	xmlns:xfd="http://www.ecrion.com/xfd/1.0" xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:ns="documents.bind.logic.bakery"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	extension-element-prefixes="date str" xmlns:barcode="http://barcode4j.krysalis.org/ns"
	exclude-result-prefixes="barcode fo svg"
	xmlns:cstm="http://www.intershop.de/iom/custom_namespace">
	
	<xsl:variable name="INC_FOOTER_CONTACT">
		<fo:block xsl:use-attribute-sets="SmallText" text-align="after">
			<xsl:value-of select="cstm:localizeText('text_footer_cmpName')"/>
		</fo:block>
		<fo:block xsl:use-attribute-sets="SmallText" text-align="after">
			<xsl:value-of select="cstm:localizeText('text_footer_cmpAddress')"/>
		</fo:block>
		<fo:block xsl:use-attribute-sets="SmallText" text-align="after">
			<xsl:value-of select="cstm:localizeText('text_footer_cmpPhone')"/>
		</fo:block>
		<fo:block xsl:use-attribute-sets="SmallText" text-align="after">
			<xsl:value-of select="cstm:localizeText('text_footer_cmpEmail')"/>
		</fo:block>
		<fo:block xsl:use-attribute-sets="SmallText" text-align="after">
			<xsl:value-of select="cstm:localizeText('text_footer_cmpInternet')"/>
		</fo:block>
	</xsl:variable>
	
	<xsl:variable name="INC_FOOTER_TERMS_AND_CONDITIONS">
		<fo:block xsl:use-attribute-sets="SmallText" text-align="after">
			<xsl:value-of select="cstm:localizeText('text_footer_termsAndConditions')"/>
		</fo:block>
	</xsl:variable>
	
</xslt:stylesheet>
