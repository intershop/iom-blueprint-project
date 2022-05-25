<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xslt:stylesheet xmlns:fn="http://www.w3.org/2005/xpath-functions"
																	xmlns:date="http://exslt.org/dates-and-times" xmlns:str="http://exslt.org/strings"
																	xmlns:xslt="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
																	xmlns:xf="http://www.ecrion.com/xf/1.0" xmlns:xc="http://www.ecrion.com/2008/xc"
																	xmlns:xfd="http://www.ecrion.com/xfd/1.0" xmlns:svg="http://www.w3.org/2000/svg"
																	xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:ns="documents.bind.logic.bakery"
																	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" extension-element-prefixes="date str"
																	xmlns:barcode="http://barcode4j.krysalis.org/ns" exclude-result-prefixes="barcode fo svg"
																	xmlns:cstm="http://www.intershop.de/iom/custom_namespace">
	
	<!-- localization helper -->
	<xslt:include href="localized_inc_blueprint.xslt"/>
	<xslt:include href="../../localization/localization_blueprint.xslt"/>
	
	<!-- Timestamp zu 01.01.2001 machen -->
	<xsl:template name="timestamp2YYYYmmdd">
		<xsl:param name="timestamp" />
		<xsl:value-of select="concat(substring($timestamp,9,2), '.', substring($timestamp,6,2), '.', substring($timestamp,1,4) )" />
	</xsl:template>
	
	<!--- die 0en nach dem Komma abschneiden -->
	<xsl:template name="trimStringTax">
		<xsl:param name="taxrate"/>
		<xsl:choose>
			<xsl:when test="substring-after($taxrate,'.') = '00' ">
				<xsl:value-of select="substring-before($taxrate,'.')" />
			</xsl:when>
			<xsl:when test="substring-after($taxrate,',') = '00' ">
				<xsl:value-of select="substring-before($taxrate,',')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$taxrate" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- DEPRECATED -->
	<xsl:template match="text()" name="split">
		<xsl:param name="ceo"/>
		<xsl:for-each select="tokenize($ceo,'[,/]')">
			<fo:block><xsl:value-of select="."/></fo:block>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:variable name="comma2point" select="',.'" />
	<xsl:variable name="point2comma" select="'.,'" />
	
	<!-- ========================= ATTRIBUTE  =========================== -->
	<xsl:attribute-set name="PricingText">
		<xsl:attribute name="font-family">Helvetica</xsl:attribute>
		<xsl:attribute name="font-style">normal</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="font-size">11.5pt</xsl:attribute>
		<xsl:attribute name="space-before.conditionality">discard</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="RegularText">
		<xsl:attribute name="font-family">Helvetica</xsl:attribute>
		<xsl:attribute name="font-style">normal</xsl:attribute>
		<xsl:attribute name="font-size">10.5pt</xsl:attribute>
		<xsl:attribute name="space-before.conditionality">discard</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="RegularTextBold">
		<xsl:attribute name="font-family">Helvetica</xsl:attribute>
		<xsl:attribute name="font-style">normal</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="font-size">10.5pt</xsl:attribute>
		<xsl:attribute name="space-before.conditionality">discard</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="SmallText">
		<xsl:attribute name="font-family">Helvetica</xsl:attribute>
		<xsl:attribute name="font-style">normal</xsl:attribute>
		<xsl:attribute name="font-size">8.5pt</xsl:attribute>
		<xsl:attribute name="space-before.conditionality">discard</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="TinyText">
		<xsl:attribute name="font-family">Helvetica</xsl:attribute>
		<xsl:attribute name="font-style">normal</xsl:attribute>
		<xsl:attribute name="font-size">7.5pt</xsl:attribute>
		<xsl:attribute name="space-before.conditionality">discard</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="MediumOverviewText">
		<xsl:attribute name="font-family">Helvetica</xsl:attribute>
		<xsl:attribute name="font-style">normal</xsl:attribute>
		<xsl:attribute name="font-size">10pt</xsl:attribute>
		<xsl:attribute name="space-before.conditionality">discard</xsl:attribute>
		<xsl:attribute name="text-align">left</xsl:attribute>
		<xsl:attribute name="padding-bottom">1mm</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="MediumTextOverviewBold">
		<xsl:attribute name="font-family">Helvetica</xsl:attribute>
		<xsl:attribute name="font-style">normal</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="font-size">10pt</xsl:attribute>
		<xsl:attribute name="space-before.conditionality">discard</xsl:attribute>
		<xsl:attribute name="text-align">left</xsl:attribute>
		<xsl:attribute name="padding-bottom">1mm</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="table.cell.border.black.thin">
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-width">0.5pt</xsl:attribute>
		<xsl:attribute name="border-color">black</xsl:attribute>
		<xsl:attribute name="border-collapse">collapse</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="table.cell.border.black.dotted">
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-width">0.2pt</xsl:attribute>
		<xsl:attribute name="border-color">black</xsl:attribute>
		<xsl:attribute name="border-collapse">collapse</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="table.cell.border.black.thick">
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-width">1pt</xsl:attribute>
		<xsl:attribute name="border-color">black</xsl:attribute>
		<xsl:attribute name="border-collapse">collapse</xsl:attribute>
	</xsl:attribute-set>
	<xsl:attribute-set name="table.cell.border.grey.thin">
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-width">1pt</xsl:attribute>
		<xsl:attribute name="border-color">#ddd</xsl:attribute>
		<xsl:attribute name="border-collapse">collapse</xsl:attribute>
	</xsl:attribute-set>
	
	<xslt:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<!-- ========================= BEGIN ROOT TEMPLATE =========================== -->
	<xsl:template match="/">
		<fo:root>
			<!-- die benutzen Grafiken  -->
			<xsl:variable name="PICTURE" select="ns:Documents/@basePathImage" />
			<xsl:variable name ="SHOP-NAME" select="/ns:Documents/ns:OrderDocuments/ns:ShopData/@name" />
			<xsl:variable name="LOGO">
				<xsl:choose>
					<xsl:when test="$SHOP-NAME = 'inTRONICS Business'">
						<xsl:value-of select="'logo-inTRONICS-business.png'" />
					</xsl:when>
					<xsl:when test="$SHOP-NAME = 'inTRONICS'">
						<xsl:value-of select="'logo-inTRONICS.png'" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'logo.jpg'" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="CAPITAL">
				<xsl:choose>
					<xsl:when test="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@invoiceType = 'invoice' ">
						<xsl:value-of select="cstm:localizeText('text_capital_invoice')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="cstm:localizeText('text_capital_credit')"/>
					</xsl:otherwise>
				</xsl:choose>			
			</xsl:variable>
			
			<xsl:variable name="VORZEICHEN">
				<xsl:choose>
					<xsl:when test="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@invoiceType = 'invoice' ">
						<xsl:text></xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>-</xsl:text>
					</xsl:otherwise>
				</xsl:choose>			
			</xsl:variable>
			
			<xsl:variable name="VORZEICHENPROMOTIONAMOUNT">
				<xsl:choose>
					<xsl:when test="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@invoiceType = 'invoice' ">
						<xsl:text>-</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text></xsl:text>
					</xsl:otherwise>
				</xsl:choose>			
			</xsl:variable>
			
			<xsl:variable name="FOOTER">
				<xsl:if test="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@invoiceType = 'invoice' ">
					<xsl:if test="/ns:Documents/ns:OrderDocuments/@paymentId = '3' "><xsl:value-of select="cstm:localizeText('text_2_pm')"/></xsl:if>
					<xsl:if test="/ns:Documents/ns:OrderDocuments/@paymentId = '5' or /ns:Documents/ns:OrderDocuments/@paymentId = '2' "><xsl:value-of select="cstm:localizeText('text_2_pm')"/></xsl:if>
					<xsl:if test="/ns:Documents/ns:OrderDocuments/@paymentId = '10' "><xsl:value-of select="cstm:localizeText('text_10_pm')"/></xsl:if>
				</xsl:if>
				<xsl:if test="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@invoiceType = 'creditnote' ">
					<xsl:if test="/ns:Documents/ns:OrderDocuments/@paymentId = '3' "><xsl:value-of select="cstm:localizeText('text_3_pm_credit')"/></xsl:if>
					<xsl:if test="/ns:Documents/ns:OrderDocuments/@paymentId = '4' "><xsl:value-of select="cstm:localizeText('text_4_pm_credit')"/></xsl:if>
					<xsl:if test="/ns:Documents/ns:OrderDocuments/@paymentId = '5' or /ns:Documents/ns:OrderDocuments/@paymentId = '2' "><xsl:value-of select="cstm:localizeText('text_5_pm_credit')"/></xsl:if>
					<xsl:if test="/ns:Documents/ns:OrderDocuments/@paymentId = '9' "><xsl:value-of select="cstm:localizeText('text_9_pm_credit')"/></xsl:if>
					<xsl:if test="/ns:Documents/ns:OrderDocuments/@paymentId = '10' "><xsl:value-of select="cstm:localizeText('text_10_pm_credit')"/></xsl:if>
					<xsl:if test="/ns:Documents/ns:OrderDocuments/@paymentId = '21' "><xsl:value-of select="cstm:localizeText('text_21_pm_credit')"/></xsl:if>
				</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="COUNT">
				<xsl:for-each select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:SalesPrices/ns:TaxPrices[@hasPosition='true']">
					<xsl:if test="position()=last()">
						<xsl:value-of select="position()"></xsl:value-of>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			
			<xsl:variable name="INVOICENUMBER">
				<xsl:value-of
					select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@invoiceNo" />
			</xsl:variable>
			
			<xsl:variable name="ISAGGREGATED">
				<xsl:value-of
					select="count(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:Orders) > 1" />
			</xsl:variable>
			
			<xsl:variable name="ISB2B">
				<xsl:value-of
					select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@shopB2B = 'true'" />
			</xsl:variable>
			
			
			<!-- ========================= BEGIN MASTER-SET =========================== -->
			<fo:layout-master-set>
				<fo:simple-page-master master-name="erste" page-width="210mm" page-height="297mm" margin-left="15mm" margin-right="10mm" margin-top="10mm" margin-bottom="3mm">
					<fo:region-body region-name="xsl-region-body" margin-left="0mm" margin-right="0mm" margin-top="90mm" margin-bottom="30mm" />
					<fo:region-before region-name="kopfersteseite" extent="90mm"/>
					<fo:region-after region-name="footer" extent="18mm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="rest" page-width="210mm" page-height="297mm" margin-left="15mm" margin-right="10mm" margin-top="10mm" margin-bottom="3mm">
					<fo:region-body region-name="xsl-region-body" margin-left="0mm" margin-right="0mm" margin-top="50mm" margin-bottom="30mm"  />
					<fo:region-before region-name="kopfrestseiten" extent="50mm"/>
					<fo:region-after region-name="footer" extent="18mm"/>
				</fo:simple-page-master>
				
				<fo:page-sequence-master master-name="document">
					<fo:single-page-master-reference master-reference="erste"/>
					<fo:repeatable-page-master-reference master-reference="rest"/>
				</fo:page-sequence-master>
			</fo:layout-master-set>
			<!-- ========================= END MASTER-SET =========================== -->
			
			<!-- ========================= BEGIN PAGE-SEQUENCE INVOICE-CREDIT-NOTE-SEQUENCE =========================== -->
			<fo:page-sequence master-reference="document" initial-page-number="1" force-page-count="auto">
				<!-- ========================= BODY =========================== -->
				<fo:static-content flow-name="kopfersteseite">
					<fo:block>
						<fo:block-container border-width="1px">
							<fo:table table-layout="fixed" width="180mm">
								<fo:table-column column-width="135mm"></fo:table-column>
								<fo:table-column column-width="45mm" ></fo:table-column>
								<fo:table-body>
									<fo:table-row>
										<fo:table-cell>
											<!-- ========================= BARCODE =========================== -->
											<fo:block>
												<fo:instream-foreign-object>
													<barcode:barcode message="{$INVOICENUMBER}">
														<barcode:code128>
															<barcode:height>15mm</barcode:height>
															<barcode:module-width>0.4mm</barcode:module-width>
															<barcode:quiet-zone enabled="false"/>
															<barcode:human-readable>
																<barcode:placement>bottom</barcode:placement>
																<barcode:font-name>Helvetica</barcode:font-name>
																<barcode:font-size>7.5pt</barcode:font-size>
																<barcode:pattern>____ ____ ___</barcode:pattern>
																<barcode:display-start-stop>false</barcode:display-start-stop>
																<barcode:display-checksum>false</barcode:display-checksum>
															</barcode:human-readable>
														</barcode:code128>
													</barcode:barcode>
												</fo:instream-foreign-object>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<!-- ========================= LOGO =========================== -->
											<fo:block>
												<fo:external-graphic src="url({$PICTURE}{$LOGO})" content-height="100%" content-width="scale-to-fit" width="100%" scaling="uniform"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
							<fo:block padding-top="20mm">
								<xsl:call-template name="HEADER_1"/>
							</fo:block>
						</fo:block-container>
					</fo:block>
				</fo:static-content>
				
				<fo:static-content flow-name="kopfrestseiten">
					<fo:block>
						<fo:block-container border-width="1px">
							<fo:table table-layout="fixed" width="180mm">
								<fo:table-column column-width="108mm"></fo:table-column>
								<fo:table-column column-width="60mm" ></fo:table-column>
								<fo:table-body>
									<fo:table-row>
										<fo:table-cell>
											<fo:block></fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<!-- ========================= LOGO =========================== -->
											<fo:block>
												<fo:external-graphic src="url({$PICTURE}{$LOGO})" content-height="100%" content-width="scale-to-fit" width="100%" scaling="uniform"/>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
							<!--	
												<fo:block padding-top="20mm">
												<xsl:call-template name="HEADER_2"/>
												</fo:block>
							-->
						</fo:block-container>	
					</fo:block>
				</fo:static-content>
				
				<!-- Fusszeile enthaelt Impressum -->
				<fo:static-content flow-name="footer">
					<fo:block-container>
						<fo:table table-layout="fixed" width="180mm">
							<fo:table-column column-width="50mm"/>
							<fo:table-column column-width="90mm" />
							<fo:table-body>
								<fo:table-row>
									<fo:table-cell xsl:use-attribute-sets="TinyText" display-align="after">
										<fo:block-container>
											<xsl:copy-of select="$INC_FOOTER_CONTACT"/>
										</fo:block-container>
									</fo:table-cell>
									
									<fo:table-cell xsl:use-attribute-sets="TinyText" display-align="after">
										<fo:block-container>
											<xsl:copy-of select="$INC_FOOTER_TERMS_AND_CONDITIONS"/>
										</fo:block-container>
									</fo:table-cell>     
									
								</fo:table-row>
							</fo:table-body>
						</fo:table> 
					</fo:block-container>
				</fo:static-content>
				
				<!-- ========================= TABELLE =========================== -->
				<fo:flow flow-name="xsl-region-body">
					<!-- ========================= ARTIKEL UND PREISE =========================== -->
					<fo:table table-layout="fixed" width="180mm" border-width="0px" border-style="solid">
						<fo:table-column column-width="10mm" text-align="left"></fo:table-column> 	<!-- quantity: 12mm = 6 numbers -->
						<fo:table-column column-width="43mm" text-align="left"></fo:table-column>	<!-- product name -->
						<fo:table-column column-width="20mm" text-align="right"></fo:table-column>		<!-- item price -->
						<fo:table-column column-width="13mm" text-align="right"></fo:table-column>	<!-- discount amount -->
						<fo:table-column column-width="52mm" text-align="left" margin-left="3mm"></fo:table-column>	<!-- discount name -->
						<fo:table-column column-width="13mm" text-align="right"></fo:table-column>	<!-- TAX -->
						<fo:table-column column-width="13mm" text-align="left"></fo:table-column>	<!-- VAT -->
						<fo:table-column column-width="16mm" text-align="right"></fo:table-column>	<!-- position price -->
						<fo:table-header>
							<fo:table-row>
								<fo:table-cell number-columns-spanned="5">
									<fo:block xsl:use-attribute-sets="PricingText">
										<xsl:copy-of select="$CAPITAL" />												
									</fo:block>
									<xsl:if test="$ISAGGREGATED = 'true'" >
										<fo:block padding-top="5mm" xsl:use-attribute-sets="TinyText">
											<xsl:text>Concerning Orders: </xsl:text>
											<xsl:for-each select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:Orders/@shopOrderNo">
												<xsl:if test="position() > 1 ">, </xsl:if>
												<xsl:value-of select="."/>
											</xsl:for-each>
										</fo:block>
									</xsl:if>
									<!-- ========================= NUR BEI GUTSCHRIFT Referenzen auf Rechnungen =========================== -->
									<xsl:if test="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@invoiceType = 'creditnote'" >
										<xsl:for-each select="distinct-values(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:Orders/ns:InvoicePos/@referenceInvoiceNo)">
											<xsl:if test="position() = 1 ">
												<fo:block padding-top="5mm" xsl:use-attribute-sets="TinyText">
													<xsl:text>Credit for: </xsl:text>
												</fo:block>
											</xsl:if>
											<fo:block xsl:use-attribute-sets="TinyText">
												<xsl:value-of select="concat('Invoice number ', .)" />
											</fo:block>
										</xsl:for-each>
									</xsl:if>
									
								</fo:table-cell>
								<fo:table-cell number-columns-spanned="3" text-align="right">
									<fo:block xsl:use-attribute-sets="TinyText">
										<xsl:value-of select="cstm:localizeText('text_page')"/>
										<fo:page-number/>
										<xsl:value-of select="cstm:localizeText('text_of')"/>
										<fo:page-number-citation ref-id="last-page"/> 											
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<fo:table-row height="12mm">
								<fo:table-cell number-columns-spanned="8"><fo:block></fo:block></fo:table-cell>
							</fo:table-row>
							<!-- ========================= TABELLENÜBERSCHRIFT =========================== -->
							<fo:table-row>
								<fo:table-cell>
									<fo:block xsl:use-attribute-sets="SmallText"><xsl:value-of select="cstm:localizeText('text_qty')"/></fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block xsl:use-attribute-sets="SmallText"><xsl:value-of select="cstm:localizeText('text_product')"/></fo:block>
								</fo:table-cell>
								<fo:table-cell>								
									<fo:block xsl:use-attribute-sets="SmallText" text-align="right">
										Price<xsl:choose>
											<xsl:when test="$ISB2B = 'true'" > (<xsl:value-of select="cstm:localizeText('text_net')"/>)</xsl:when>
											<xsl:otherwise> (<xsl:value-of select="cstm:localizeText('text_gross')"/>)</xsl:otherwise>
										</xsl:choose>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block xsl:use-attribute-sets="SmallText" text-align="right"><xsl:value-of select="cstm:localizeText('text_discount')"/></fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block xsl:use-attribute-sets="SmallText" text-align="left" margin-left="3mm"><xsl:value-of select="cstm:localizeText('text_description')"/></fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block xsl:use-attribute-sets="SmallText" text-align="right"><xsl:value-of select="cstm:localizeText('text_Tax')"/></fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block xsl:use-attribute-sets="SmallText" text-align="left" margin-left="1mm"><xsl:value-of select="cstm:localizeText('text_VAT')"/></fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block xsl:use-attribute-sets="SmallText" text-align="right" linefeed-treatment="preserve"><xsl:value-of select="cstm:localizeText('text_totalPriceItem')"/></fo:block>
								</fo:table-cell>
							</fo:table-row>
							<fo:table-row>
								<fo:table-cell number-columns-spanned="8">
									<fo:block space-before="5mm"> </fo:block>
								</fo:table-cell>
							</fo:table-row>
							<fo:table-row>
								<fo:table-cell number-columns-spanned="8">
									<fo:block xsl:use-attribute-sets="table.cell.border.black.thin"></fo:block>
								</fo:table-cell>
							</fo:table-row>
							<fo:table-row>
								<fo:table-cell number-columns-spanned="8">
									<fo:block space-before="2mm"> </fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-header>
						<fo:table-body>
							<xsl:for-each select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:Orders">
								<xsl:if test="$ISAGGREGATED = 'true'" >
									<fo:table-row space-before="3mm" keep-with-next="always">
										<fo:table-cell number-columns-spanned="8">
											<fo:block padding-top="3mm"></fo:block>
											<xsl:if test="position() > 1" >
												<fo:block xsl:use-attribute-sets="table.cell.border.black.dotted"></fo:block>
												<fo:block space-before="1mm"> </fo:block>																					
											</xsl:if>
											<fo:block xsl:use-attribute-sets="TinyText">
												<fo:inline>
													<xsl:value-of select="concat(' Order ', ./@shopOrderNo, ' placed on ')" />
													<xslt:call-template name="timestamp2YYYYmmdd">
														<xslt:with-param name="timestamp">
															<xslt:value-of select="./@orderDate" />
														</xslt:with-param>
													</xslt:call-template>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:if>
								
								<xsl:for-each select="ns:InvoicePos">								
									<!-- ========================= TABELLENINHALT =========================== -->
									<!-- ========================= AUFZÄHLUNG ARTIKEL =========================== -->
									<xsl:if test="position() = 1" >
										<fo:table-row space-before="1mm" keep-with-next="always">
											<fo:table-cell number-columns-spanned="8">
												<fo:block space-before="1mm"> </fo:block>
											</fo:table-cell>
										</fo:table-row>
									</xsl:if>
									<fo:table-row space-before="5mm" keep-together.within-column="always">
										<fo:table-cell>																				
											<fo:block xsl:use-attribute-sets="SmallText">
												<fo:inline>
													<xsl:value-of select="./@quantity" />
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText">
												<fo:inline>
													<xslt:value-of select="./ns:Article/@name" />
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" text-align="right">
												<fo:inline>
													<xsl:copy-of select="$VORZEICHEN" />
													<xsl:choose>
														<xsl:when test="$ISB2B = 'true'" ><xsl:value-of select="format-number(./ns:SalesPricesPos/@salesItemNet, '###,##0.00;-###,##0.00')" /></xsl:when>
														<xsl:otherwise><xsl:value-of select="format-number(./ns:SalesPricesPos/@salesItemGross, '###,##0.00;-###,##0.00')" /></xsl:otherwise>
													</xsl:choose>	
													<xsl:text> €</xsl:text>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" text-align="right">
												<xsl:for-each select="ns:SalesPricesPos/ns:Promotions">
													<fo:inline>
														<xsl:copy-of select="$VORZEICHENPROMOTIONAMOUNT" />
														<xsl:choose>
															<xsl:when test="$ISB2B = 'true'" ><xsl:value-of select="format-number(./@salesSumNet, '###,##0.00;-###,##0.00')" /></xsl:when>
															<xsl:otherwise><xsl:value-of select="format-number(./@salesSumNet, '###,##0.00;-###,##0.00')" /></xsl:otherwise>
														</xsl:choose>											
														<xsl:text> €</xsl:text>
													</fo:inline>
												</xsl:for-each>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" margin-left="3mm">
												<xsl:for-each select="ns:SalesPricesPos/ns:Promotions">
													<fo:inline>
														<xsl:value-of select="./@name" />
													</fo:inline>
												</xsl:for-each>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" text-align="right">
												<fo:inline>
													<xsl:copy-of select="$VORZEICHEN" />
													<xsl:value-of select="format-number(./ns:SalesPricesPos/@salesSumTaxSubDiscounted, '###,##0.00;-###,##0.00')" />
													<xsl:text> €</xsl:text>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" text-align="left" margin-left="1mm">
												<fo:inline>
													<xsl:text>(</xsl:text>
													<xslt:call-template name="trimStringTax">
														<xslt:with-param name="taxrate">
															<xsl:value-of select="./ns:SalesPricesPos/@taxRate" />
														</xslt:with-param>
													</xslt:call-template>
													<xsl:text>%)</xsl:text>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" text-align="right">
												<fo:inline>
													<xsl:copy-of select="$VORZEICHEN" />
													<xsl:choose>
														<xsl:when test="$ISB2B = 'true'" ><xsl:value-of select="format-number(./ns:SalesPricesPos/@salesSumNetSubDiscounted, '###,##0.00;-###,##0.00')" /></xsl:when>
														<xsl:otherwise><xsl:value-of select="format-number(./ns:SalesPricesPos/@salesSumGrossSubDiscounted, '###,##0.00;-###,##0.00')" /></xsl:otherwise>
													</xsl:choose>													
													<xsl:text> €</xsl:text>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:for-each>
								<!-- ========================= List order discounts and charges here  =========================== -->
								<!-- Schleife ueber die Versandkosten -->
								<xsl:for-each select="ns:ChargePrices">
									<fo:table-row keep-together.within-column="always">
										<!-- Quantity hardcodiert immer 1 oder -1 -->
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" keep-together.within-column="always">
												<fo:inline>
													<xsl:value-of select="1" />
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<!-- Name -->
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText">
												<fo:inline>
													<xsl:choose>
														<xsl:when test="@type = 'tb.chargetype.deliverycharge'">
															Delivery charge
														</xsl:when>
														<xsl:when test="@type = 'tb.chargetype.handlingcharge'">
															Handling charge
														</xsl:when>
														<xsl:when test="@type = 'tb.chargetype.paymentcharge'">
															Payment charge
														</xsl:when>
														<xsl:when test="@type = 'tb.chargetype.codcharge'">
															COD charge
														</xsl:when>
														<xsl:otherwise>
															Charge
														</xsl:otherwise>
													</xsl:choose>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" text-align="right">
												<fo:inline>
													<xsl:copy-of select="$VORZEICHEN" />
													<xsl:value-of select="format-number(./@salesSumGross, '###,##0.00;-###,##0.00')" />
													<xsl:text> €</xsl:text>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block text-align="right" xsl:use-attribute-sets="SmallText">
												<xsl:for-each select="ns:Promotions">
													<fo:inline>
														<xsl:copy-of select="$VORZEICHENPROMOTIONAMOUNT" />
														<xsl:value-of select="format-number(./@salesSumGross, '###,##0.00;-###,##0.00')" />
														<xsl:text> €</xsl:text>
													</fo:inline>
												</xsl:for-each>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" margin-left="3mm">
												<xsl:for-each select="ns:Promotions">
													<fo:inline>
														<xsl:value-of select="./@name" />
													</fo:inline>
												</xsl:for-each>
											</fo:block>
										</fo:table-cell>
										<!-- Steuern -->
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" text-align="right">
												<fo:inline>
													<xsl:copy-of select="$VORZEICHEN" />
													<xsl:value-of select="format-number(./@salesSumTaxDiscounted, '###,##0.00;-###,##0.00')" />
													<xsl:text> €</xsl:text>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" text-align="left" margin-left="1mm">
												<fo:inline>
													<xsl:text>(</xsl:text>
													<xslt:call-template name="trimStringTax">
														<xslt:with-param name="taxrate">
															<xsl:value-of select="./@taxRate" />
														</xslt:with-param>
													</xslt:call-template>
													<xsl:text>%)</xsl:text>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<!-- Gesamtpreis -->
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" text-align="right">
												<fo:inline>
													<xsl:copy-of select="$VORZEICHEN" />
													<xsl:value-of select="format-number(./@salesSumGrossDiscounted, '###,##0.00;-###,##0.00')" />
													<xsl:text> €</xsl:text>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:for-each>
								<xsl:for-each select="ns:Promotions">
									<fo:table-row keep-together.within-column="always">
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText">
												<fo:inline>
													<xsl:value-of select="1" />
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<!-- Name -->
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText">
												<fo:inline>
													<xsl:text>Order level Promotion</xsl:text>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText"  text-align="right">
												<fo:inline>
													<xsl:text>0.00 €</xsl:text>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" text-align="right">
												<fo:inline>
													<xsl:copy-of select="$VORZEICHENPROMOTIONAMOUNT" />
													<xsl:value-of select="format-number(./@salesSumGross, '###,##0.00;-###,##0.00')" />
													<xsl:text> €</xsl:text>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" margin-left="3mm">
												<fo:inline>
													<xsl:value-of select="./@name" />
												</fo:inline>
											</fo:block>
										</fo:table-cell>
										<!-- Steuern -->
										<fo:table-cell><fo:block xsl:use-attribute-sets="SmallText" margin-left="3mm"></fo:block></fo:table-cell>
										<fo:table-cell><fo:block xsl:use-attribute-sets="SmallText" margin-left="3mm"></fo:block></fo:table-cell>
										<!-- Gesamtpreis -->
										<fo:table-cell>
											<fo:block xsl:use-attribute-sets="SmallText" text-align="right">
												<fo:inline>
													<xsl:copy-of select="$VORZEICHENPROMOTIONAMOUNT" /><xsl:value-of select="format-number(./@salesSumGross, '###,##0.00;-###,##0.00')" />
													<xsl:text> €</xsl:text>
												</fo:inline>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</xsl:for-each>
							</xsl:for-each>
							<!-- ========================= TABELLENINHALT ENDE =========================== -->
							
							<!-- ========================= GESAMTBETRAG =========================== -->
							<fo:table-row keep-with-previous="always">
								<fo:table-cell>
									<fo:block>
										<fo:table table-layout="fixed" width="180mm" keep-together="always">
											<fo:table-column column-width="35mm" ></fo:table-column>
											<fo:table-column column-width="29mm" ></fo:table-column>
											<fo:table-column column-width="1mm" ></fo:table-column>
											<fo:table-column column-width="25mm"></fo:table-column>
											<fo:table-column column-width="28mm" ></fo:table-column>
											<fo:table-column column-width="1mm" ></fo:table-column>
											<fo:table-column column-width="1mm" ></fo:table-column>
											<fo:table-column column-width="60mm" ></fo:table-column>
											<fo:table-body>
												<fo:table-row>
													<fo:table-cell number-columns-spanned="8" >
														<fo:block space-before="30mm"> </fo:block>
													</fo:table-cell>
												</fo:table-row>
												<fo:table-row>
													<fo:table-cell number-columns-spanned="8">
														<fo:block xsl:use-attribute-sets="table.cell.border.black.thin"></fo:block>
													</fo:table-cell>
												</fo:table-row>
												<fo:table-row>
													<fo:table-cell number-columns-spanned="8">
														<fo:block  space-before="15mm"> </fo:block>
													</fo:table-cell>
												</fo:table-row>
												<!-- ========================= totals  =========================== -->
												<xsl:for-each select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:SalesPrices">																						
													<xsl:for-each select="./ns:ChargePrices">
														<fo:table-row>
															<fo:table-cell>
															</fo:table-cell>
															<fo:table-cell margin-right="5">
															</fo:table-cell>
															<fo:table-cell>
															</fo:table-cell>
															<fo:table-cell margin-left="5">
															</fo:table-cell>
															<fo:table-cell margin-left="5">
															</fo:table-cell> 
															<fo:table-cell margin-right="5">
															</fo:table-cell>
															<fo:table-cell>
																<fo:block xsl:use-attribute-sets="SmallText" text-align="right">
																	<fo:inline>
																		<xsl:choose>
																			<xsl:when test="@type = 'tb.chargetype.deliverycharge'">
																				Delivery charge
																			</xsl:when>
																			<xsl:when test="@type = 'tb.chargetype.handlingcharge'">
																				Handling charge
																			</xsl:when>
																			<xsl:when test="@type = 'tb.chargetype.paymentcharge'">
																				Payment charge
																			</xsl:when>
																			<xsl:when test="@type = 'tb.chargetype.codcharge'">
																				COD charge
																			</xsl:when>
																			<xsl:otherwise>
																				Charge
																			</xsl:otherwise>
																		</xsl:choose>
																		incl.
																	</fo:inline>
																</fo:block>
															</fo:table-cell>
															<fo:table-cell>
																<fo:block xsl:use-attribute-sets="SmallText" text-align="right">
																	<fo:inline>
																		<xsl:copy-of select="$VORZEICHEN" />
																		<xsl:value-of select="format-number(@salesSumGrossDiscounted, '###,##0.00;-###,##0.00')" /> €
																	</fo:inline>
																</fo:block>
															</fo:table-cell>
														</fo:table-row>
													</xsl:for-each>													
													<xsl:if test="$ISB2B = 'true'" >												
														<fo:table-row>
															<fo:table-cell>
															</fo:table-cell>
															<fo:table-cell margin-right="5">
															</fo:table-cell>
															<fo:table-cell>
															</fo:table-cell>
															<fo:table-cell margin-left="5">
															</fo:table-cell>
															<fo:table-cell margin-left="5">
															</fo:table-cell> 
															<fo:table-cell margin-right="5">
															</fo:table-cell>
															<fo:table-cell>
																<fo:block xsl:use-attribute-sets="PricingText" text-align="right">
																	<fo:inline>Total (net)
																	</fo:inline>
																</fo:block>
															</fo:table-cell>
															<fo:table-cell>
																<fo:block xsl:use-attribute-sets="PricingText" text-align="right">
																	<fo:inline>
																		<xsl:copy-of select="$VORZEICHEN" />
																		<xsl:value-of select="format-number(@salesSumNet, '###,##0.00;-###,##0.00')" /> €
																	</fo:inline>
																</fo:block>
															</fo:table-cell>
														</fo:table-row>
														<fo:table-row>
															<fo:table-cell number-columns-spanned="8">
																<fo:block xsl:use-attribute-sets="PricingText"> </fo:block>
															</fo:table-cell>
														</fo:table-row>
													</xsl:if>												
													<xsl:for-each select="./ns:TaxPrices">
														<fo:table-row>
															<fo:table-cell>
															</fo:table-cell>
															<fo:table-cell margin-right="5">
															</fo:table-cell>
															<fo:table-cell>
															</fo:table-cell>
															<fo:table-cell margin-left="5">
															</fo:table-cell>
															<fo:table-cell margin-left="5">
															</fo:table-cell> 
															<fo:table-cell margin-right="5">
															</fo:table-cell>
															<fo:table-cell>
																<fo:block xsl:use-attribute-sets="SmallText" text-align="right">
																	<fo:inline>TAX <xsl:if test="$ISB2B != 'true'" >
																			incl. 
																		</xsl:if>(
																		<xslt:call-template name="trimStringTax">
																			<xslt:with-param name="taxrate">
																				<xsl:value-of select="@taxRate" />
																			</xslt:with-param>
																		</xslt:call-template>%)
																	</fo:inline>
																</fo:block>
															</fo:table-cell>
															<fo:table-cell>
																<fo:block xsl:use-attribute-sets="SmallText" text-align="right">
																	<fo:inline>
																		<xsl:copy-of select="$VORZEICHEN" />
																		<xsl:value-of select="format-number(@salesSumSubTax, '###,##0.00;-###,##0.00')" /> €
																	</fo:inline>
																</fo:block>
															</fo:table-cell>
														</fo:table-row>
													</xsl:for-each>
													<fo:table-row>
														<fo:table-cell>
														</fo:table-cell>
														<fo:table-cell margin-right="5">
														</fo:table-cell>
														<fo:table-cell>
														</fo:table-cell>
														<fo:table-cell margin-left="5">
														</fo:table-cell> 
														<fo:table-cell margin-left="5">
														</fo:table-cell> 
														<fo:table-cell margin-right="5">
														</fo:table-cell>
														<fo:table-cell>
															<fo:block xsl:use-attribute-sets="PricingText" text-align="right">
																<fo:inline>
																	Total <xsl:if test="$ISB2B != 'true'" >(gross)</xsl:if>
																</fo:inline>
															</fo:block>
														</fo:table-cell>
														<fo:table-cell>
															<fo:block xsl:use-attribute-sets="PricingText" text-align="right">
																<fo:inline>
																	<xsl:copy-of select="$VORZEICHEN" />
																	<xsl:value-of select="format-number(@salesSumGross, '###,##0.00;-###,##0.00')" /> €
																</fo:inline>
															</fo:block>
														</fo:table-cell>
													</fo:table-row>
												</xsl:for-each>
												<!-- ========================= FOOTER  =========================== -->
												<fo:table-row>
													<fo:table-cell number-columns-spanned="8">
														<fo:block xsl:use-attribute-sets="PricingText"> </fo:block>
													</fo:table-cell>
												</fo:table-row>
												<fo:table-row>
													<fo:table-cell number-columns-spanned="8">
														<fo:block xsl:use-attribute-sets="PricingText"> </fo:block>
													</fo:table-cell>
												</fo:table-row>
												<fo:table-row>
													<fo:table-cell number-columns-spanned="8">
														<fo:block xsl:use-attribute-sets="PricingText"> </fo:block>
													</fo:table-cell>
												</fo:table-row>
												<fo:table-row>
													<fo:table-cell number-columns-spanned="8">
														<fo:block xsl:use-attribute-sets="RegularText">
															<fo:inline>
																<xsl:copy-of select="$FOOTER" />
															</fo:inline>
														</fo:block>
													</fo:table-cell>
												</fo:table-row>
											</fo:table-body>
										</fo:table>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
					<fo:block id="last-page"/>
				</fo:flow>	
			</fo:page-sequence>
		</fo:root>
	</xsl:template>
	
	<xsl:template name="HEADER_1">
		<fo:table table-layout="fixed"  width="100%">
			<fo:table-column column-width="110mm"></fo:table-column>
			<fo:table-column column-width="40mm" ></fo:table-column>
			<fo:table-column column-width="30mm" ></fo:table-column>
			<fo:table-body>
				<fo:table-row>
					<!-- ========================= Anschrift =========================== -->
					<fo:table-cell >
						<fo:block xsl:use-attribute-sets="RegularText">
							<xsl:if
								test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Name/@salutation)">
								<xsl:value-of
									select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Name/@salutation" />
							</xsl:if>
						</fo:block>
						<fo:block xsl:use-attribute-sets="RegularText">
							<xsl:if
								test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Name/@title)">
								<xsl:value-of
									select="concat(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Name/@title, '  ')" />
							</xsl:if>
							<xsl:if
								test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Name/@firstName)">
								<xsl:value-of
									select="concat(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Name/@firstName, '  ')" />
							</xsl:if>
							<xsl:if
								test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Name/@lastName)">
								<xsl:value-of
									select="concat(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Name/@lastName, '  ')" />
							</xsl:if>
						</fo:block>
						<fo:block xsl:use-attribute-sets="RegularText">
							<xsl:if
								test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Name/@companyName)">
								<xsl:value-of
									select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Name/@companyName" />
							</xsl:if>
						</fo:block>
						<fo:block xsl:use-attribute-sets="RegularText">
							<xsl:for-each select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Addition">
								<xsl:value-of select="concat(., '  ')" />
							</xsl:for-each>
						</fo:block>
						<fo:block xsl:use-attribute-sets="RegularText">
							<xsl:if
								test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Street)">
								<xsl:value-of
									select="concat(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Street, '  ')" />
							</xsl:if>
						</fo:block>
						<fo:block space-before="5mm" xsl:use-attribute-sets="RegularText">
							<xsl:if
								test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:PostCode)">
								<xsl:value-of
									select="concat(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:PostCode, '  ')" />
							</xsl:if>
							<xsl:if
								test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:City)">
								<xsl:value-of
									select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:City" />
							</xsl:if>
						</fo:block>
						<!--
											<fo:block xsl:use-attribute-sets="RegularText">
											<xsl:if
											test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Country)">
											<xsl:value-of
											select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:InvoiceAddress/ns:Country" />
											</xsl:if>
											</fo:block>
						-->
					</fo:table-cell>
					<xsl:call-template name="HEADER_RIGHT"/>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	
	<xsl:template name="HEADER_2">
		<fo:table table-layout="fixed"  width="100%" >
			<fo:table-column column-width="110mm"></fo:table-column>
			<fo:table-column column-width="40mm" ></fo:table-column>
			<fo:table-column column-width="30mm" ></fo:table-column>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell >
						<fo:block xsl:use-attribute-sets="RegularText"></fo:block>
					</fo:table-cell>
					<xsl:call-template name="HEADER_RIGHT"/>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	
	<xsl:template name="HEADER_RIGHT">
		<fo:table-cell >
			<fo:block xsl:use-attribute-sets="PricingText">
				<xsl:choose>
					<xsl:when test="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@invoiceType = 'invoice' ">
						<xsl:value-of select="cstm:localizeText('text_invoiceNumber')"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="cstm:localizeText('text_creditNumber')"/></xsl:otherwise>
				</xsl:choose>
			</fo:block>
			<fo:block xsl:use-attribute-sets="RegularText">
				<xsl:value-of select="cstm:localizeText('text_customerNumber')"/>
			</fo:block>
			<fo:block xsl:use-attribute-sets="RegularText">
				<xsl:value-of select="cstm:localizeText('text_orderNumber')"/>
			</fo:block>
			<fo:block xsl:use-attribute-sets="RegularText">
				<xsl:choose>
					<xsl:when test="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@invoiceType = 'invoice' ">
						<xsl:value-of select="cstm:localizeText('text_dateOfInvoice')"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="cstm:localizeText('text_dateOfCreditNote')"/></xsl:otherwise>
				</xsl:choose>
			</fo:block>
			<fo:block xsl:use-attribute-sets="RegularText">
				<xsl:if test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@termOfPayment)"><xsl:value-of select="cstm:localizeText('text_paymentTerm')"/></xsl:if>
			</fo:block>
		</fo:table-cell>
		<fo:table-cell>
			<fo:block xsl:use-attribute-sets="PricingText">
				<xsl:value-of select="concat(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@invoiceNo,'&#160;')" />
			</fo:block>
			<fo:block xsl:use-attribute-sets="RegularText">
				<xsl:value-of select="concat(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@debitorNo,'&#160;')" />
			</fo:block>
			<fo:block xsl:use-attribute-sets="RegularText">
				<xsl:choose>
					<xsl:when test="count(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/ns:Orders) > 1"><xsl:value-of select="cstm:localizeText('text_aggregated')"/></xsl:when>
					<xsl:otherwise><xslt:value-of select="/ns:Documents/ns:OrderDocuments/ns:ShopData/@orderNo"/></xsl:otherwise>
				</xsl:choose>
			</fo:block>
			<fo:block xsl:use-attribute-sets="RegularText">
				<xsl:if
					test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@invoiceDate)">
					<fo:inline>
						<xslt:call-template name="timestamp2YYYYmmdd">
							<xslt:with-param name="timestamp">
								<xslt:value-of
									select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@invoiceDate" />
							</xslt:with-param>
						</xslt:call-template>
					</fo:inline>
				</xsl:if>
			</fo:block>
			<!-- ZAHLUNGSZIEL -->
			<fo:block xsl:use-attribute-sets="RegularText">
				<xsl:if
					test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@termOfPayment)">
					<fo:inline>
						<xslt:call-template name="timestamp2YYYYmmdd">
							<xslt:with-param name="timestamp">
								<xslt:value-of
									select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:InvoiceCreditNote/@termOfPayment" />
							</xslt:with-param>
						</xslt:call-template>
					</fo:inline>
				</xsl:if>
			</fo:block>
		</fo:table-cell>
	</xsl:template>
</xslt:stylesheet>