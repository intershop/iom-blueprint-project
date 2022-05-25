<?xml version="1.0" encoding="UTF-8"?>
<!-- Diese Datei soll Templates und Funktionen enthalten, die dann von allen 
	 Lieferschein-xslt gemeinsam gesourced und benutzt werden können. -->
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template name="padding">
		<xsl:param name="length" select="0" />
		<xsl:param name="chars" select="' '" />
		<xsl:choose>
			<xsl:when test="not($length) or not($chars)" />
			<xsl:otherwise>
				<xsl:variable name="string"
					select="concat($chars, $chars, $chars, $chars, $chars, $chars, $chars, $chars, $chars, $chars)" />
				<xsl:choose>
					<xsl:when test="string-length($string) &gt;= $length">
						<xsl:value-of select="substring($string, 1, $length)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="padding">
							<xsl:with-param name="length" select="$length" />
							<xsl:with-param name="chars" select="$string" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- einen Zeitstempel in YYYYMMDD wandeln -->
	<xsl:template name="timestamp2YYYYMMDD">
		<xsl:param name="timestamp" />
		<xsl:value-of select="substring($timestamp,1,4)" />
		<xsl:value-of select="substring($timestamp,6,2)" />
		<xsl:value-of select="substring($timestamp,9,2)" />
	</xsl:template>
	
	<!--YYYYMMDD zu einem Zeitstempel machen -->
	<xsl:template name="YYYYMMDD2timestamp">
		<xsl:param name="YYYYMMDD" />
		<xsl:param name="time" />
		<xsl:value-of select="substring($YYYYMMDD,1,4)" />
		<xsl:text>-</xsl:text>
		<xsl:value-of select="substring($YYYYMMDD,5,2)" />
		<xsl:text>-</xsl:text>
		<xsl:value-of select="substring($YYYYMMDD,7,2)" />
		<xsl:text>T</xsl:text>
		<xsl:value-of select="$time" />
	</xsl:template>
	
	<!-- Timestamp zu 01/01/2001 machen -->
	<xsl:template name="timestamp2ddmmYYYY">
		<xsl:param name="timestamp" />
		<xsl:value-of select="concat(substring($timestamp,9,2), '/', substring($timestamp,6,2), '/', substring($timestamp,1,4) )" />
	</xsl:template>
	
	<!-- Timestamp zu 01.01.2001 machen -->
	<xsl:template name="timestamp2dd.mm.YYYY">
		<xsl:param name="timestamp" />
		<xsl:value-of select="concat(substring($timestamp,9,2), '.', substring($timestamp,6,2), '.', substring($timestamp,1,4) )" />
	</xsl:template>

	<!-- String auf ? Zeichen kürzen -->
	<xsl:template name="trimString2length">
		<xsl:param name="string" />
		<xsl:param name="length" />
		<xsl:value-of select="substring($string,1,$length)" />
	</xsl:template>
	
	
</xsl:stylesheet>