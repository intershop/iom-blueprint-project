<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xslt:stylesheet xmlns:fn="http://www.w3.org/2005/xpath-functions"
 	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:date="http://exslt.org/dates-and-times" xmlns:str="http://exslt.org/strings"
	xmlns:xslt="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
	
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:ns="documents.bind.logic.omsy"
	xmlns:barcode="http://barcode4j.krysalis.org/ns" version="2.0" extension-element-prefixes="date str">
		   
	<!--
			der Lieferschein muss mit der PDF-Druck-Einstellung "fit to paper" gedruckt werden,
			sonst sieht er etwas komisch aus.
	 -->

	<!-- am 17.1. fiel auf, dass die Ausführungsumgebung der Generierung des Lieferscheins
		 das Standalone-verzeichnis des JBOSS ist. Leider muss man daher hier einen absoluten Pfadnamen
		 angeben, da die relaitve Variante vollkommen unverständlich ist.  
		 Sollte es mal wieder Probleme beim Lesen der utilities.xml geben, dann ist der 
		 Ausführungspfad wahrscheinlich wieder nicht mehr der, den wir hier relativ annehmen.
		 
		 ACHTUNG: durch das Sourcing dieser Datei ist der Lieferschein nicht mehr lokal erstellbar, 
		 wenn man den Pfad zur Datei nicht anpasst - nach dem Testen nicht vergessen, den 
		 Pfad wieder zurückzusetzen! 
		 -->

	<!--
		fuer nicht lokale Ausführung 
	<xslt:import href="concat(system-property('xsl:OMS_VAR'),/xslt/utils/utilities.xslt)" />
	 -->

	<!-- fuer lokale Tests 
	
		<xslt:import href="../../utils/utilities.xslt" />
	
	-->
	<!-- Timestamp zu 01.01.2001 machen -->
	<xslt:template name="timestamp2dd.mm.YYYY">
		<xslt:param name="timestamp" />
		<xslt:value-of select="concat(substring($timestamp,9,2), '.', substring($timestamp,6,2), '.', substring($timestamp,1,4) )" />
	</xslt:template>
	
	<!-- DEPRECATED -->
	<xslt:template match="text()" name="split">
		<xslt:param name="ceo"/>
	  	<xslt:for-each select="tokenize($ceo,'[,/]')">
	   		<fo:block><xslt:value-of select="."/></fo:block>
	  	</xslt:for-each>
	 </xslt:template>

	<!--Maximum Positionsanzahl pro Seite speichern. 7 passen zur Zeit ganz gut. -->
	
	<xslt:variable name="posperpage" select="7" />
	<xslt:variable name="break" select="'&#xA;'" />	
		
	<xslt:output indent="yes" encoding="utf-8" />
	
	<!-- This stylesheet was generated for a 'en_US' Translation ID. The Translation 
		ID applies to both the whole text in a document and the locale-long and locale-short 
		date formats. -->
	<!-- ============================ RAW XSL =============================== -->
	<!-- =========================== SCRIPTS ================================ -->
	<!-- ========================= ROOT TEMPLATE =========================== -->
	<xslt:template match="/">
		<fo:root>

			<fo:layout-master-set>
				<fo:simple-page-master master-name="delivery-note"
					page-width="210.82mm" page-height="297.180mm">
					<fo:region-body region-name="xsl-region-body"
						column-gap="0.25in" margin="14mm 20mm 21mm 20mm" />
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="delivery-note-sequence">
					<fo:repeatable-page-master-reference
						master-reference="delivery-note" />
				</fo:page-sequence-master>
			</fo:layout-master-set>
			<xslt:for-each
				select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryNotePos">
				<xslt:variable name="position" select="position()" />
				<!-- die Sequence bekommt eine id, damit wir diese zur Zählung der Gesamtseitenzahl nutzen können. -->
				<xslt:if test="$position = 1 or ($position - 1 ) mod $posperpage = 0">
					<fo:page-sequence master-reference="delivery-note-sequence" id="seq1">
						<fo:flow flow-name="xsl-region-body" font-size="12pt"
							relative-position="relative">
							<fo:block>
								<fo:block-container z-index="1" position="absolute"
									left="0mm" top="0mm" width="64mm" height="12mm" overflow="hidden">
									<fo:block text-decoration="no-underline no-line-through"
										font-size="26pt" font-weight="bold" font-style="normal"
										color="rgb(128,128,128)">Lieferschein</fo:block>
								</fo:block-container>
								 
							</fo:block>
							<fo:block>
								<fo:block-container border-width="1px"
									border-style="solid" padding-top="2mm" padding-bottom="2mm"
									padding-left="2mm" border-collapse="collapse" font-size="7pt"
									border-color="rgb(0,0,0)" z-index="-7" position="absolute"
									left="2.5mm" top="3.453cm" width="2.735in" height="2.5cm"
									overflow="hidden">
									<fo:block>
										<xslt:if
											test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Name/@salutation)">
											<fo:inline border-right-style="none"
												border-bottom-style="none" font-size="10pt">
												<xslt:value-of
													select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Name/@salutation" />
											</fo:inline>
										</xslt:if>
									</fo:block>
									<fo:block>
										<xslt:if
											test="string(/Documents/OrderDocuments/DocumentsList/DeliveryNote/DeliveryAddress/Name/@title)">
											<fo:inline font-size="10pt">
												<xslt:value-of
													select="/Documents/OrderDocuments/DocumentsList/DeliveryNote/DeliveryAddress/Name/@title" />
											</fo:inline>
										</xslt:if>
										<xslt:if
											test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Name/@firstName)">
											<fo:inline font-size="10pt">
												<xslt:value-of
													select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Name/@firstName" />
											</fo:inline>
										</xslt:if>
										 
										<xslt:if
											test="string(/Documents/OrderDocuments/DocumentsList/DeliveryNote/DeliveryAddress/Name/@lastName)">
											<fo:inline font-size="10pt">
												<xslt:value-of
													select="/Documents/OrderDocuments/DocumentsList/DeliveryNote/DeliveryAddress/Name/@lastName" />
											</fo:inline>
										</xslt:if>
										<xslt:if
											test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Name/@lastName)">
											<fo:inline font-size="10pt">
												<xslt:value-of
													select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Name/@lastName" />
											</fo:inline>
										</xslt:if>
									</fo:block>
									<fo:block>
										<xslt:if
											test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Name/@companyName)">
											<fo:inline font-size="10pt">
												<xslt:value-of
													select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Name/@companyName" />
											</fo:inline>
										</xslt:if>
									</fo:block>
									<!-- Namenszusatz - wir erwarten erstmal nur einen! -->
									<fo:block>
										<xslt:if
											test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Location/ns:Addition[1])">
											<fo:inline font-size="10pt">
												<xslt:value-of
													select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Location/ns:Addition[1]" />
											</fo:inline>
										</xslt:if>
									</fo:block>
									<fo:block>
										<xslt:if
											test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Location/ns:Street)">
											<fo:inline font-size="10pt">
												<xslt:value-of
													select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Location/ns:Street" />
											</fo:inline>
										</xslt:if>
									</fo:block>
									<fo:block> </fo:block>
									<fo:block>
										<xslt:if
											test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Location/ns:PostCode)">
											<fo:inline font-size="10pt">
												<xslt:value-of
													select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Location/ns:PostCode" />
											</fo:inline>
										</xslt:if>
										 
										<xslt:if
											test="string(/Documents/OrderDocuments/DocumentsList/DeliveryNote/DeliveryAddress/Location/City)">
											<fo:inline font-size="10pt" width="0.195in">
												<xslt:value-of
													select="/Documents/OrderDocuments/DocumentsList/DeliveryNote/DeliveryAddress/Location/City" />
											</fo:inline>
										</xslt:if>
										<xslt:if
											test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Location/ns:City)">
											<fo:inline width="0.461in" font-size="10pt">
												<xslt:value-of
													select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryAddress/ns:Location/ns:City" />
											</fo:inline>
										</xslt:if>
									</fo:block>
								</fo:block-container>
						
							</fo:block>
							<fo:block>
								<fo:block-container border-style="solid"
									padding-top="2mm" padding-bottom="2mm" padding-left="2mm"
									font-size="7pt" border-width="1px" border-color="rgb(0,0,0)"
									z-index="6" position="absolute" right="0mm" width="2.735in"
									height="2.5cm" overflow="hidden" top="3.453cm" left="10.159cm">
									<fo:table width="100%" border-collapse="collapse"
										font-size="6pt" table-layout="fixed">
										<!-- 6pt = 2.1 mm -->
										<fo:table-column column-width="proportional-column-width(51.015)"
											column-number="1" />
										<fo:table-column column-width="proportional-column-width(48.985)"
											column-number="2" />
										<fo:table-body>
											<!-- 0.047 in = 1.19 mm = 3.38 pt -->
											<fo:table-row height="3.6mm" overflow="hidden">
												<fo:table-cell>
													<fo:block font-size="10pt">Kundennummer:</fo:block>
												</fo:table-cell>
												<fo:table-cell>
													<fo:block>
														<xslt:if
															test="string(/ns:Documents/ns:OrderDocuments/ns:ShopData/@customerNo)">
															<fo:inline font-size="10pt">
																<xslt:value-of
																	select="/ns:Documents/ns:OrderDocuments/ns:ShopData/@customerNo" />
															</fo:inline>
														</xslt:if>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row height="3.6mm">
												<fo:table-cell>
													<fo:block font-size="10pt">Auftragsnummer:</fo:block>
												</fo:table-cell>
												<fo:table-cell>
													<fo:block>
														<xslt:if
															test="string(/ns:Documents/ns:OrderDocuments/ns:ShopData/@orderNo)">
															<fo:inline font-size="10pt">
																<xslt:value-of
																	select="/ns:Documents/ns:OrderDocuments/ns:ShopData/@orderNo" />
															</fo:inline>
														</xslt:if>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row height="3.6mm">
												<fo:table-cell>
													<fo:block font-size="10pt">Auftragsdatum:</fo:block>
												</fo:table-cell>
												<fo:table-cell>
													<fo:block>
														<xslt:if test="string(/ns:Documents/ns:OrderDocuments/ns:ShopData/@orderCreationDate)">
															<fo:inline font-size="10pt">
																<xslt:call-template name="timestamp2dd.mm.YYYY">
																	<xslt:with-param name="timestamp">
																		<xslt:value-of
																			select="/ns:Documents/ns:OrderDocuments/ns:ShopData/@orderCreationDate" />
																	</xslt:with-param>
																</xslt:call-template>
															</fo:inline>
														</xslt:if>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row height="3.6mm">
												<fo:table-cell>
													<fo:block font-size="10pt">Lieferscheindatum:</fo:block>
												</fo:table-cell>
												<fo:table-cell>
													<fo:block>
														<xslt:if
															test="string(/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/@creationDate)">
															<fo:inline font-size="10pt">
																<xslt:call-template name="timestamp2dd.mm.YYYY">
																	<xslt:with-param name="timestamp">
																		<xslt:value-of
																			select="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/@creationDate" />
																	</xslt:with-param>
																</xslt:call-template>
															</fo:inline>
														</xslt:if>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
											<fo:table-row height="3.6mm" overflow="hidden">
												<fo:table-cell>
													<fo:block font-size="10pt">Seite</fo:block>
												</fo:table-cell>
												<!-- niemand garantiert, dass die Angabe der max. Seitenzahl immer richtig funktioniert...  -->
												<fo:table-cell>
													<fo:block font-size="10pt">
														<fo:page-number format="1" />
														von
														<fo:page-number-citation-last ref-id="seq1"/>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
										</fo:table-body>
									</fo:table>
								</fo:block-container>
							</fo:block>
							<!--Container über der Tabelle -->
							<fo:block-container z-index="11" position="absolute"
								left="0in" top="8.4857cm" width="100%" height="5in" overflow="hidden">
								<fo:block>
									<!-- -0.472in margin top -->
									<xslt:if
										test="/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryNotePos">
										<fo:table margin-top="0in" 
											border-width="1px" border-color="rgb(0,0,0)"
											text-decoration="no-underline no-line-through" table-layout="fixed"
											width="100%" border-collapse="collapse" font-size="10pt"
											font-weight="normal" font-style="normal" relative-position="relative">
											<fo:table-column column-width="33%"
												column-number="1" />
											<fo:table-column column-width="45%"
												column-number="2" />
											<fo:table-column 
												column-number="3" />
											<fo:table-header 
												background-color="rgb(230,230,230)" border-style="solid"
												border-width="1px">
												<fo:table-row>

													<fo:table-cell padding-left="2px">
														<fo:block font-size="10pt">Artikelnummer
														</fo:block>
													</fo:table-cell>
													<fo:table-cell>
														<fo:block font-size="10pt">Artikelbezeichnung</fo:block>
													</fo:table-cell>
													<fo:table-cell>
														<fo:block font-size="10pt">Menge</fo:block>
													</fo:table-cell>
												</fo:table-row>
											</fo:table-header>
											<fo:table-body>
												<xslt:variable name="subseq"
													select="fn:subsequence((/ns:Documents/ns:OrderDocuments/ns:DocumentsList/ns:DeliveryNote/ns:DeliveryNotePos), $position, $posperpage)" />
												<xslt:for-each select="$subseq">
													<fo:table-row 
														border-width="0px" border-style="none" id="5E891626">
														<xslt:attribute name="id">
                                            <xslt:value-of
															select="concat('5E891626_', position())" />
                                          </xslt:attribute>
														<fo:table-cell padding-top="5px"
															padding-left="2px">
															<fo:block>
																<xslt:if test="string(./ns:Article/@shopArticleNo)">
																	<fo:inline font-size="10pt">
																		<xslt:value-of select="./ns:Article/@shopArticleNo" />
																	</fo:inline>
																</xslt:if>
															</fo:block>

														</fo:table-cell>
														<fo:table-cell padding-top="5px">
															<fo:block>
																<xslt:if test="string(./ns:Article/@name)">
																	<fo:inline font-size="10pt">
																		<xslt:value-of select="./ns:Article/@name" />
																	</fo:inline>
																</xslt:if>
															</fo:block>
														</fo:table-cell>
														<fo:table-cell padding-top="5px">
															<fo:block>
																<xslt:if test="string(./ns:Quantities/@ordered)">
																	<fo:inline width="0.76in" font-size="10pt">
																		<xslt:value-of select="./ns:Quantities/@dispatched" />
																	</fo:inline>
																</xslt:if>
															</fo:block>
														</fo:table-cell>
													</fo:table-row>
												</xslt:for-each>
											</fo:table-body>
										</fo:table>
									</xslt:if>
								</fo:block>
							</fo:block-container>
							<fo:block>
								<fo:block-container padding-top="1pt"
									z-index="1" position="absolute" left="0.00in" top="10.179in"
									width="100%" font-size="5pt" height="0.114in">
									<fo:block>
										<fo:table margin-top="0in" 	border-width="1px" border-color="rgb(0,0,0)"
												text-decoration="no-underline no-line-through" table-layout="fixed"
												width="100%" border-collapse="collapse" font-size="7.5pt"
												font-weight="normal" font-style="normal" relative-position="relative">
											<fo:table-column column-width="33%" column-number="1" />
											<fo:table-column column-width="45%"	column-number="2" />
											<fo:table-column column-number="3" />
											<fo:table-body>
												<fo:table-row>
													<fo:table-cell>
														<fo:block>
															<fo:block-container>
																<fo:block>
																	<fo:inline font-weight="bold">
																		Firmenname
																	</fo:inline>
																</fo:block>
																<fo:block>
																	...															
																</fo:block>
																<fo:block>
																	Straße															
																</fo:block>
																<fo:block>
																	12345 Stadt
																</fo:block>
																<fo:block>
																	Email
																</fo:block>
																
															</fo:block-container>
														</fo:block>
													</fo:table-cell> 
													<fo:table-cell>
														<fo:block>
															<fo:block-container>
																<fo:block>
																	<fo:inline font-weight="bold">
																		Geschäftsleitung
																	</fo:inline>
																</fo:block>
																<!-- DEPRECATED -->
																<xslt:call-template name="split">
																	<xslt:with-param name="ceo">
																		<xslt:value-of select="/ns:Documents/ns:OrderDocuments/ns:ShopData/@ceo" />
																	</xslt:with-param>
																</xslt:call-template>
															</fo:block-container>
														</fo:block>
													</fo:table-cell>		
													<fo:table-cell>
														<fo:block font-weight="bold">Handelsregister</fo:block>
														<fo:block>HRB ..., Amtsgericht ...</fo:block>
														<fo:block font-weight="bold">Steuernummer</fo:block>
														<fo:block>USt.ID Nr. DE ...</fo:block>
													</fo:table-cell>
												</fo:table-row> 
											</fo:table-body>											
										
											</fo:table>
									</fo:block>
								</fo:block-container>
							</fo:block>
						</fo:flow>
					</fo:page-sequence>
				</xslt:if>
			</xslt:for-each>
		</fo:root>
	</xslt:template>
	
</xslt:stylesheet>