<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xslt:stylesheet xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:date="http://exslt.org/dates-and-times" xmlns:str="http://exslt.org/strings"
    xmlns:xslt="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xf="http://www.ecrion.com/xf/1.0" xmlns:xc="http://www.ecrion.com/2008/xc"
    xmlns:xfd="http://www.ecrion.com/xfd/1.0" xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:ns="documents.bind.logic.bakery"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    extension-element-prefixes="date str" xmlns:barcode="http://barcode4j.krysalis.org/ns"
    exclude-result-prefixes="barcode fo svg"
	xmlns:cstm="http://www.intershop.de/iom/custom_namespace">
		
	<!-- Get language from properties -->
    <xsl:variable name="language">
        <xsl:choose>
            <xsl:when test="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:Orders/ns:OrderProperties[@id='customer']/ns:Property[@key='correspondenceLanguage']/@value != ''">
                <xsl:value-of select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:Orders/ns:OrderProperties[@id='customer']/ns:Property[@key='correspondenceLanguage']/@value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'en'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
	
	<!-- Look up localization file for current language. -->
	<xsl:variable name="localeUrl">
		<xsl:choose>
			<xsl:when test="$language = 'de'">
				<xsl:text>./translations/localization_blueprint_de.xml</xsl:text>
			</xsl:when>					
            <!-- implicit default template for english -->
			<xsl:otherwise>
				<xsl:text>./translations/localization_blueprint_en.xml</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- Parse the XML from the language file  -->
	<xsl:variable name="localeXml" select="document($localeUrl)/*" />
	
	<xsl:function name="cstm:localizeText">
        <xsl:param name="key_name"/>
        <xsl:value-of select="$localeXml/key[@name=$key_name]/text()"/>
    </xsl:function>	
	
	<!-- Money related stuff. -->	
	<xsl:variable name="CURRENCY">
        <xsl:text>&#8364;</xsl:text>
    </xsl:variable>
    
    <xsl:variable name="SIGN">
        <xsl:choose>
            <xsl:when test="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@invoiceType = 'invoice' ">
                <xsl:text/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>-</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
	
	<xsl:function name="cstm:formatTotalTax">
        <xsl:param name="taxRate" />
		<xsl:param name="taxText" />
		
		<xsl:choose>
			<xsl:when test="$language = 'de'">
				<xsl:value-of select="concat($taxRate, '% ', $taxText)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($taxText, ' ', $taxRate, '%')"/>
			</xsl:otherwise>
		</xsl:choose>
    </xsl:function>		

	<!-- Time formatting -->
    <xsl:variable name="dateTimeFormat">
            <xsl:choose>
            <xsl:when test="$language = 'nl' or $language = 'be'">
                [D01]-[M01]-[Y0001]
            </xsl:when>
            <xsl:when test="$language = 'de'">
                [D01].[M01].[Y0001]
            </xsl:when>
            <xsl:otherwise>
                [D01]-[M01]-[Y0001]
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
	
</xslt:stylesheet>
	