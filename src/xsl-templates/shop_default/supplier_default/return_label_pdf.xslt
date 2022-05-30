<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:svg="http://www.w3.org/2000/svg" xmlns:rl="documents.bind.logic.bakery" xmlns:barcode="http://barcode4j.krysalis.org/ns" exclude-result-prefixes="barcode fo svg">

	<xsl:output method="xml" encoding="ISO-8859-1" indent="yes"/>
	  
	<xsl:attribute-set name="table.cell.border.black">
		<xsl:attribute name="border-style">solid</xsl:attribute>
		<xsl:attribute name="border-width">1pt</xsl:attribute>
		<xsl:attribute name="border-color">black</xsl:attribute>
		<xsl:attribute name="border-collapse">collapse</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="table.cell.border.black.dotted">
		<xsl:attribute name="border-style">dotted</xsl:attribute>
		<xsl:attribute name="border-width">1pt</xsl:attribute>
		<xsl:attribute name="border-color">black</xsl:attribute>
		<xsl:attribute name="border-collapse">collapse</xsl:attribute>
    </xsl:attribute-set>
  
	<xsl:template match="/">
	  
		<fo:root font-family="Helvetica">
		  <fo:layout-master-set>
			<!-- layout for the pages -->
			<fo:simple-page-master master-name="first" page-height="29.7cm" page-width="21cm" margin-top="25mm" margin-bottom="25mm" margin-left="20mm" margin-right="20mm">
			  <fo:region-body margin-top="95mm" margin-bottom="0mm" margin-left="0mm" margin-right="0mm"/>
			  <fo:region-before extent="90mm" overflow="auto"/>
			</fo:simple-page-master>
		  </fo:layout-master-set>
		  
		  <xsl:variable name="PICTURE" select="rl:Documents/@basePathImage"/>
		  
			<fo:page-sequence master-reference="first" initial-page-number="1" force-page-count="auto">
				
					<!--
						#######################################      XSL-REGION-BEFORE  #######################################
					-->
				<fo:static-content flow-name="xsl-region-before">
				  <fo:table width="170mm" font-size="10pt" table-layout="fixed">
					<fo:table-column column-width="170mm"/>
					<fo:table-body>
					  <fo:table-row>
								<fo:table-cell>
									 <fo:block font-weight="bold" font-size="14pt" margin-top="5mm" margin-bottom="5mm">Retourenetikett</fo:block>
								</fo:table-cell>
					  </fo:table-row>
					  <fo:table-row>
								<fo:table-cell>
									 <fo:block  margin-bottom="5mm">So einfach geht's.</fo:block>
								</fo:table-cell>
					  </fo:table-row>
					   <fo:table-row>
								<fo:table-cell>
									 <fo:block  margin-bottom="5mm">Drucken und schneiden Sie dieses Etikett aus und kleben es bitte gut sichtbar außen auf Ihr Rücksendepaket. Eine zusätzliche Frankierung ist nicht erforderlich.</fo:block>
								</fo:table-cell>
					  </fo:table-row>
					  <fo:table-row>
								<fo:table-cell>
									 <fo:block font-weight="bold"  margin-bottom="5mm">Dieses Rücksendeetikett ist ausschließlich für die auf dem Retourenschein aufgeführten Artikel bestimmt und darf nicht für die Rücksendung 
									 anderer Artikel verwendet werden (Rücksendeanschrift muss identisch sein).</fo:block>
								</fo:table-cell>
					  </fo:table-row>
					</fo:table-body>
				  </fo:table>
				</fo:static-content>
				
				 <!--
						#######################################      XSL-REGION-BODY    #######################################
					-->
			   <fo:flow flow-name="xsl-region-body">
			   <fo:table width="170mm" font-size="10pt" table-layout="fixed">
				   <fo:table-column column-width="170mm"/>
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell width="170mm">
								<fo:block font-size="10pt"><fo:external-graphic content-height="3mm" src="{$PICTURE}/cutter.jpg"/> Das Etikett bitte entlang dieser Linie ausschneiden und auf Ihre Rücksendung kleben.</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			   <fo:table width="170mm" font-size="10pt" table-layout="fixed" xsl:use-attribute-sets="table.cell.border.black.dotted">
				   <fo:table-column column-width="3mm" />
				   <fo:table-column column-width="164mm" />
				   <fo:table-column column-width="3mm" />
					<fo:table-body>
						<fo:table-row height="3mm">
							<fo:table-cell number-columns-spanned="3">
								<fo:block></fo:block>
							</fo:table-cell>
						</fo:table-row>
						<fo:table-row>
							<fo:table-cell width="3mm" >
								<fo:block></fo:block>
							</fo:table-cell>
							<fo:table-cell width="164mm">
								<fo:block>
								<!-- #######################################  ####################################### -->
									<fo:table width="164mm" xsl:use-attribute-sets="table.cell.border.black" table-layout="fixed">
										<fo:table-column column-width="10mm"/>
										<fo:table-column column-width="65mm"/>
										<fo:table-column column-width="7mm"/>
										<fo:table-column column-width="17mm"/>
										<fo:table-column column-width="55mm"/>
										<fo:table-column column-width="10mm"/>
										
										<fo:table-body>
										 <!-- #######################################	ROW 1	 ####################################### -->
										  <fo:table-row>
											
											<fo:table-cell number-rows-spanned="6">
												<fo:block></fo:block>
											</fo:table-cell>
											
											<fo:table-cell number-columns-spanned="4" height="5mm">
												<fo:block></fo:block>
											</fo:table-cell>
											
											<fo:table-cell number-rows-spanned="6">
												<fo:block></fo:block>
											</fo:table-cell>
											
										  </fo:table-row>
										  
										<!-- #######################################	ROW 2	 ####################################### -->
										  <fo:table-row space-before="3mm" space-after="3mm">
											
											<fo:table-cell number-columns-spanned="3">
												<fo:block></fo:block>
											</fo:table-cell>
											
											<fo:table-cell>
											  <fo:block text-align="left" font-size="10pt" font-weight="bold">
												<xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Supplier/rl:Carrier/rl:CargoCompany"/>
											  </fo:block>
											</fo:table-cell>

										  </fo:table-row>
											<!-- #######################################	ROW 3	 ####################################### -->
										  <fo:table-row space-before="3mm" space-after="3mm">

											<fo:table-cell>
											  <!-- #######################################	Absender	 ####################################### -->
												<fo:block text-align="left">
												  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Address/rl:AddressLine1"/>
												</fo:block>
												<fo:block text-align="left">
												  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Address/rl:AddressLine2"/>
												</fo:block>
												<fo:block text-align="left">
													  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Address/rl:AddressAddition1"/>
												</fo:block>
												<fo:block text-align="left">
													  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Address/rl:AddressAddition2"/>
												</fo:block>
												<fo:block text-align="left">
													  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Address/rl:AddressAddition3"/>
												</fo:block>
												<fo:block text-align="left">
												  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Address/rl:AddressLine3"/>
												</fo:block>
											   <fo:block text-align="left">
												  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Address/rl:AddressLine4"/>
												</fo:block>
											   <fo:block text-align="left" space-before="3mm">
												  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Address/rl:AddressLine5"/>
												</fo:block>
												<fo:block text-align="left">
												  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Address/rl:Country"/>
												</fo:block>
												<fo:block space-before="8mm">
													<xsl:text>RETOURE</xsl:text>
												</fo:block>
											</fo:table-cell>
											
											<fo:table-cell number-columns-spanned="2">
											  <fo:block/>
											</fo:table-cell>
											
											<!-- #######################################	Identcode = aus dem Nummernkreis gezogener Wert  ####################################### -->
											<fo:table-cell>  
												<xsl:choose>
												  <xsl:when test="rl:Documents/rl:ReturnLabel/rl:Supplier/rl:IdentCodeValue != '' ">
													<xsl:variable name="identCodeVal">
													  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Supplier/rl:IdentCodeValue"/>
													</xsl:variable>                                                          
													  <fo:block>
														<fo:instream-foreign-object>
														  <barcode:barcode message="{$identCodeVal}">
															<barcode:intl2of5>
															  <barcode:height>30mm</barcode:height>
															  <barcode:module-width>0.4mm</barcode:module-width>
															  <barcode:quiet-zone enabled="false"/>
															  <barcode:human-readable>
																  <barcode:placement>bottom</barcode:placement>
																  <barcode:font-name>Helvetica</barcode:font-name>
																  <barcode:font-size>10pt</barcode:font-size>
																  <barcode:pattern>__\.___   ___\.___   _</barcode:pattern>
																  <barcode:display-start-stop>false</barcode:display-start-stop>
																  <barcode:display-checksum>false</barcode:display-checksum>
															  </barcode:human-readable>
															</barcode:intl2of5>
														  </barcode:barcode>
														</fo:instream-foreign-object>
													  </fo:block>
												  </xsl:when>
												  <xsl:otherwise>
													<fo:block space-before="30mm" space-before.conditionality="retain"></fo:block>
												  </xsl:otherwise>
												</xsl:choose>                                              
											</fo:table-cell>

										  </fo:table-row>
										  <!-- #######################################	ROW 4	 ####################################### -->
										  <fo:table-row space-before="3mm" space-after="3mm">
											
											<fo:table-cell number-columns-spanned="4" height="10mm">
												<fo:block></fo:block>
											</fo:table-cell>

										  </fo:table-row>
										  <!-- #######################################	ROW 5	 ####################################### -->
										  <fo:table-row space-before="3mm" space-after="3mm">
											<!-- die Angabe des Paketzentrums entnehmen wir nicht der Carrierdefinition, denn sie gehört nicht dorthin. -->
											<fo:table-cell>
											  <fo:block text-align="left" font-size="10pt" font-weight="bold">
												<xsl:value-of select="'Paketzentrum 15'"/>
											  </fo:block>
											</fo:table-cell>
											
											<fo:table-cell number-columns-spanned="3">
												<fo:block></fo:block>
											</fo:table-cell>

										  </fo:table-row>
										  <!-- #######################################	ROW 6	 ####################################### -->
										  <fo:table-row space-before="3mm" space-after="3mm">
											<!-- #######################################	Leadcode - stammt aus der Supplierkonfig, an die noch eine Prüfziffer rangerechnet ist ####################################### -->
											<fo:table-cell>                
												<xsl:choose>
												  <xsl:when test="rl:Documents/rl:ReturnLabel/rl:Supplier/rl:LeadCodeValue != '' ">
													<xsl:variable name="leadCodeVal">
													  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Supplier/rl:LeadCodeValue"/>
													</xsl:variable>                    
													<fo:block>
													  <fo:instream-foreign-object>
														<barcode:barcode message="{$leadCodeVal}">
														  <barcode:intl2of5>
															<barcode:height>30mm</barcode:height>
															<barcode:module-width>0.4mm</barcode:module-width>
															<barcode:quiet-zone enabled="false"/>
															<barcode:human-readable>
																  <barcode:placement>bottom</barcode:placement>
																  <barcode:font-name>Helvetica</barcode:font-name>
																  <barcode:font-size>10pt</barcode:font-size>
																  <barcode:pattern>_____\.___\.___\.__   _</barcode:pattern>
																  <barcode:display-start-stop>false</barcode:display-start-stop>
																  <barcode:display-checksum>false</barcode:display-checksum>
														   </barcode:human-readable>
														  </barcode:intl2of5>
														</barcode:barcode>
													  </fo:instream-foreign-object>
													</fo:block>
												  </xsl:when>
												  <xsl:otherwise>
													<fo:block space-before="30mm" space-before.conditionality="retain"></fo:block>
												  </xsl:otherwise>
												</xsl:choose>
											</fo:table-cell>
											
											<fo:table-cell>
											  <fo:block/>
											</fo:table-cell>
											
											<fo:table-cell number-columns-spanned="2">
											  <!-- #######################################	Empfaenger	 ####################################### -->
												<fo:block text-align="left">
												  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Supplier/rl:Address/rl:AddressLine1"/>
												</fo:block>
												<fo:block text-align="left">
													  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Supplier/rl:Address/rl:AddressAddition1"/>
												</fo:block>
												<fo:block text-align="left">
													  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Supplier/rl:Address/rl:AddressAddition2"/>
												</fo:block>
												<fo:block text-align="left">
													  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Supplier/rl:Address/rl:AddressAddition3"/>
												</fo:block>
												<fo:block text-align="left">
												  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Supplier/rl:Address/rl:AddressLine2"/>
												</fo:block>
												<fo:block text-align="left">
												  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Supplier/rl:Address/rl:AddressLine3"/>
												</fo:block>
											   <fo:block text-align="left">
												  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Supplier/rl:Address/rl:AddressLine4"/>
												</fo:block>
											   <fo:block text-align="left" space-before="3mm">
												  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Supplier/rl:Address/rl:AddressLine5"/>
												</fo:block>
												<fo:block text-align="left">
												  <xsl:value-of select="rl:Documents/rl:ReturnLabel/rl:Supplier/rl:Address/rl:Country"/>
												</fo:block>
											</fo:table-cell>

										  </fo:table-row>
										  <!-- #######################################	ROW 7	 ####################################### -->
										  <fo:table-row space-before="3mm" space-after="3mm">
											
											<fo:table-cell number-columns-spanned="6" height="5mm">
												<fo:block></fo:block>
											</fo:table-cell>
											
										  </fo:table-row>
										  
										</fo:table-body>
									  </fo:table>
								
								</fo:block>
							</fo:table-cell>
							<fo:table-cell width="3mm" >
								<fo:block></fo:block>
							</fo:table-cell>
						</fo:table-row>
						<fo:table-row height="3mm">
							<fo:table-cell number-columns-spanned="3">
								<fo:block></fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
				  
			  </fo:flow>
			</fo:page-sequence>
		
	  </fo:root>
	</xsl:template>

</xsl:stylesheet>
