<?xml version="1.0" encoding="UTF-8"?> 
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://services.theberlinbakery.com/schemas/bmecat/1.2/bmecat_new_catalog"
	xmlns:str="http://whatever">
	
	<xsl:output method="text" encoding="UTF-8"/> 
	<xsl:output method="text" indent="yes" name="csv"/> 
	
	<!-- Funktionen -->
	
	<xsl:function name="str:paddingWithZeros" >
		<xsl:param name="number" />
		<xsl:choose>
			<xsl:when test="string-length($number)&lt;5">
				<xsl:sequence select = "str:paddingWithZeros(concat('0',$number))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select = "$number" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	
	<xsl:function name="str:textNormalize">
		<xsl:param name="text"/>
		<xsl:if test="string-length($text) &gt; 0">
			<xsl:analyze-string select="$text" regex="\n">
				<xsl:matching-substring>
					<xsl:text>\n</xsl:text>
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<xsl:value-of select="."/>
				</xsl:non-matching-substring>
			</xsl:analyze-string>	
		</xsl:if>
	</xsl:function>
	
	
	<xsl:function name="str:mediaType">
		<xsl:param name="type"/>
		<xsl:if test="string-length($type) &gt; 0">
			<xsl:choose>
				<!-- vorschaubild (klein) -->
				<xsl:when test="$type='image/jpeg'">
					<xsl:value-of select = "'image'"/>
				</xsl:when>
				<!-- normalbild -->
				<xsl:when test="$type='image/gif'">
					<xsl:value-of select = "'image'"/>
				</xsl:when>
				<!-- produktdatenblatt -->
				<xsl:when test="$type='application/pdf'">
					<xsl:value-of select = "'pdf'"/>
				</xsl:when>
				<xsl:otherwise >
					<xsl:value-of select = "''"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:function>
	
	
	
	<!-- dient der umrechnung der maße in mm -->
	<xsl:function name="str:umrechnen" >
		<xsl:param name="string" />
		<xsl:choose>
			<xsl:when test="$string = 'mm'">
				<xsl:sequence select = "1" />
			</xsl:when>
			<xsl:when test="$string = 'cm'">
				<xsl:sequence select = "10" />
			</xsl:when>
			<xsl:when test="$string = 'dm'">
				<xsl:sequence select = "100" />
			</xsl:when>
			<xsl:when test="$string = 'm'">
				<xsl:sequence select = "1000" />
			</xsl:when>
		</xsl:choose>
	</xsl:function>
	
	
	<!-- dient der umrechnung des gewichts in kg-->
	<xsl:function name="str:umrechnenGewicht" >
		<xsl:param name="string" />
		<xsl:choose>
			<xsl:when test="$string = 'g'">
				<xsl:sequence select = "1000" />
			</xsl:when>
			<xsl:when test="$string = 'kg'">
				<xsl:sequence select = "1" />
			</xsl:when>
		</xsl:choose>
	</xsl:function>
	
	<!-- Ende Funktionen --> 
	
	
	<xsl:param name="supplierRef"/>
	<xsl:param name="shopRef"/>
	<xsl:param name="fileDate"/>
	<xsl:param name="outPath"/>
	
	
	<xsl:variable name="language" select="BMECAT/HEADER/CATALOG/LANGUAGE"/> 
	
	<!-- wird fuer den downloadPath der medien gebraucht -->
	<xsl:variable name="url" select="BMECAT/HEADER/CATALOG/MIME_ROOT"/>
	
	<xsl:template match="/">
		
		<xsl:variable name="shopRef" select ="str:paddingWithZeros($shopRef)"/>
		<xsl:variable name="supplierRef" select ="str:paddingWithZeros($supplierRef)"/> 
		
		<xsl:variable name="filenameA" select="concat($shopRef,'_',$supplierRef,'_',$fileDate,'_AD','.csv')" />  
		<xsl:variable name="filenameB" select="concat($shopRef,'_',$supplierRef,'_',$fileDate,'_D2','.csv')" />
		<xsl:variable name="filenameC" select="concat($shopRef,'_',$supplierRef,'_',$fileDate,'_D3','.csv')" />
		<xsl:variable name="filenameD" select="concat($shopRef,'_',$supplierRef,'_',$fileDate,'_D4','.csv')" />
		<xsl:variable name="filenameF" select="concat($shopRef,'_',$supplierRef,'_',$fileDate,'_D5','.csv')" />
		<xsl:variable name="filenameE" select="concat($shopRef,'_',$supplierRef,'_',$fileDate,'_BC','.csv')" />
		<xsl:variable name="filenameG" select="concat($shopRef,'_',$supplierRef,'_',$fileDate,'_I','.csv')" />
		
		<xsl:for-each select="BMECAT/T_NEW_CATALOG">
			<xsl:value-of select="$filenameA"/>
			<xsl:text>,</xsl:text>
			<xsl:value-of select="$filenameB"/>
			<xsl:text>,</xsl:text>
			<xsl:value-of select="$filenameC"/>
			<xsl:text>,</xsl:text>
			<xsl:value-of select="$filenameG"/>
			<xsl:text>,</xsl:text>
			<xsl:value-of select="$filenameD"/>
			<xsl:text>,</xsl:text>
			<xsl:value-of select="$filenameF"/>
			<xsl:text>,</xsl:text>
			<xsl:value-of select="$filenameE"/>
			
			<!-- Datei1 -->
			<xsl:result-document href="{$outPath}/{$filenameA}" format="csv">supplierArticleNo|manufacturer|manufacturerArticleNo|ISBN|EAN|articleName|length|height|width|weight|listPrice|currency|assortmentName|assortmentIdentifier|deliveryForm|priceFixing|parentSupplierArticleNo<xsl:text></xsl:text>
				<xsl:for-each select="ARTICLE">
					
					<!-- variablen -->
					
					<xsl:variable name= "aid" select ="SUPPLIER_AID"/>
					<xsl:variable name= "manufacturer" select ="ARTICLE_DETAILS/MANUFACTURER_NAME"/>
					<xsl:variable name= "manufacturerArticleNo" select ="ARTICLE_DETAILS/MANUFACTURER_AID"/>
					<xsl:variable name= "EAN" select ="ARTICLE_DETAILS/EAN"/>
					
					<xsl:variable name= "assortment"> 
						<xsl:variable name="mapgroup" select="//ARTICLE_TO_CATALOGGROUP_MAP[ART_ID = $aid]/CATALOG_GROUP_ID" />
						<xsl:value-of select="//T_NEW_CATALOG/CATALOG_GROUP_SYSTEM/CATALOG_STRUCTURE[GROUP_ID = $mapgroup]/GROUP_NAME"/>
					</xsl:variable>
					
					<xsl:variable name= "assortmentIdentifier"> 
						<xsl:variable name="mapgroup" select="//ARTICLE_TO_CATALOGGROUP_MAP[ART_ID = $aid]/CATALOG_GROUP_ID" />
						<!-- <xsl:value-of select="//T_NEW_CATALOG/CATALOG_GROUP_SYSTEM/CATALOG_STRUCTURE[GROUP_ID = $mapgroup]/GROUP_ID"/>  -->
						<xsl:value-of select="//T_NEW_CATALOG/CATALOG_GROUP_SYSTEM/CATALOG_STRUCTURE[GROUP_ID = $mapgroup]/GROUP_NAME"/>
					</xsl:variable>
					
					
					<xsl:variable name= "listPrice" select="ARTICLE_PRICE_DETAILS/ARTICLE_PRICE[@price_type = 'nrp' and (LOWER_BOUND = 1 or not(LOWER_BOUND))]/PRICE_AMOUNT"/>     				    
					<xsl:variable name= "currency" select="ARTICLE_PRICE_DETAILS/ARTICLE_PRICE[@price_type = 'nrp' and (LOWER_BOUND = 1 or not(LOWER_BOUND))]/PRICE_CURRENCY"/>
					
					<!-- ende variablen -->
					
					<!-- supplierArticleNo -->
					<xsl:value-of select="$aid"/>
					<xsl:text>|</xsl:text>
					<!-- manufacturer -->
					<xsl:value-of select= "$manufacturer"/>
					<xsl:text>|</xsl:text>
					<!-- manufactureArticleNo -->
					<xsl:value-of select="$manufacturerArticleNo"/>
					<xsl:text>|</xsl:text>
					<!-- ISBN -->
					<xsl:text>|</xsl:text>
					<!-- EAN -->
					<xsl:value-of select="$EAN"/>
					<xsl:text>|</xsl:text>
					<!-- articleName -->
					<!-- Elementname DESCRIPTION_SHORT kann ein Artikelname oder eine Kurzbeschreibung sein -->
					<!-- oder MANUFACTURER_TYPE_DESCR als articlenamen -->
					<xsl:value-of select="str:textNormalize(ARTICLE_DETAILS/DESCRIPTION_SHORT)"/>
					<xsl:text>|</xsl:text>
					<!-- länge --> 
					<xsl:if test="string(number(replace((ARTICLE_FEATURES/FEATURE[FNAME = 'Länge']/FVALUE),',','.')))  != 'NaN'">
						<xsl:value-of select="number(replace((ARTICLE_FEATURES/FEATURE[FNAME = 'Länge']/FVALUE),',','.')) * number((str:umrechnen(ARTICLE_FEATURES/FEATURE[FNAME ='Länge']/FUNIT)))"/>
					</xsl:if>
					<xsl:text>|</xsl:text>
					<!-- hoehe -->
					<xsl:if test="string(number(replace((ARTICLE_FEATURES/FEATURE[FNAME = 'Höhe']/FVALUE),',','.')))  != 'NaN'">
						<xsl:value-of select="number(replace((ARTICLE_FEATURES/FEATURE[FNAME = 'Höhe']/FVALUE),',','.')) * number((str:umrechnen(ARTICLE_FEATURES/FEATURE[FNAME = 'Höhe']/FUNIT)))"/>
					</xsl:if>
					<xsl:text>|</xsl:text>
					<!-- breite -->
					<xsl:if test="string(number(replace((ARTICLE_FEATURES/FEATURE[FNAME = 'Breite']/FVALUE),',','.')))  != 'NaN'">
						<xsl:value-of select="number(replace((ARTICLE_FEATURES/FEATURE[FNAME = 'Breite']/FVALUE),',','.')) * number((str:umrechnen(ARTICLE_FEATURES/FEATURE[FNAME = 'Breite']/FUNIT)))"/>
					</xsl:if>
					<xsl:text>|</xsl:text>
					<!-- weight-->
					<xsl:if test="string(number(replace((ARTICLE_FEATURES/FEATURE[FNAME = 'Gewicht']/FVALUE),',','.')))  != 'NaN'">
						<xsl:value-of select="number(replace((ARTICLE_FEATURES/FEATURE[FNAME = 'Gewicht']/FVALUE),',','.')) * number((str:umrechnenGewicht(ARTICLE_FEATURES/FEATURE[FNAME = 'Gewicht']/FUNIT)))"/>
					</xsl:if>
					<xsl:text>|</xsl:text>
					<!-- listPrice --> 
					<xsl:value-of select="$listPrice"/>
					<xsl:text>|</xsl:text>
					<!-- currency --> 
					<xsl:value-of select="$currency"/>
					<xsl:text>|</xsl:text>
					<!-- assortmentName -->
					<xsl:value-of select="$assortment"/>
					<xsl:text>|</xsl:text>
					<!-- assortmentIdentifier -->
					<xsl:value-of select="$assortmentIdentifier"/>
					<xsl:text>|</xsl:text>
					<!-- deliveryForm -->
					<!--<xsl:value-of select="''"/>-->
					<xsl:text>|</xsl:text>
					<!-- priceFixing -->
					<!--<xsl:value-of select=""/>-->
					<xsl:text>|</xsl:text>
					<!-- parentSupplierArticleNo -->
					<xsl:value-of select="ARTICLE_FEATURES/FEATURE[FNAME = 'parentRef']/FVALUE"/>
					<xsl:text></xsl:text>       
				</xsl:for-each>
			</xsl:result-document>
			
			
			<!-- Datei2 -->
			<xsl:result-document href="{$outPath}/{$filenameB}" format="csv">supplierArticleNo|articleName|articleBillingName|articleShortDescription|articleLongDescription|language<xsl:text>
</xsl:text>
				<xsl:for-each select="ARTICLE">
					<!-- supplierArticleNo -->
					<xsl:value-of select= "SUPPLIER_AID"/>
					<xsl:text>|</xsl:text>
					<!-- articleName -->
					<!-- Elementname DESCRIPTION_SHORT kann ein Artikelname oder eine Kurzbeschreibung sein -->
					<!-- oder MANUFACTURER_TYPE_DESCR als articlenamen -->
					<xsl:value-of select="str:textNormalize(ARTICLE_DETAILS/DESCRIPTION_SHORT)"/>
					<xsl:text>|</xsl:text>
					<!-- articleBillingName -->
					<xsl:text>|</xsl:text>
					<!-- articleShortDescription -->
					<xsl:value-of select="str:textNormalize(ARTICLE_DETAILS/DESCRIPTION_SHORT)"/>
					<xsl:text>|</xsl:text>
					<!-- articleLongDescription -->
					<xsl:value-of select="str:textNormalize(ARTICLE_DETAILS/DESCRIPTION_LONG)"/>				
					<xsl:text>|</xsl:text>
					<!-- language -->
					<xsl:value-of select="$language"/>
					<xsl:text>
</xsl:text>
				</xsl:for-each>
			</xsl:result-document>
			
			
			<!-- Datei für keywords -->
			<xsl:result-document href="{$outPath}/{$filenameF}" format="csv">supplierArticleNo|articleKeyword|language<xsl:text>
</xsl:text>
				<xsl:for-each select="ARTICLE">
					<xsl:variable name="supplierArticleNo" select="SUPPLIER_AID"/>
					<xsl:for-each select="ARTICLE_DETAILS/KEYWORD">
						<!-- supplierArticleNo -->
						<xsl:value-of select= "$supplierArticleNo"/>
						<xsl:text>|</xsl:text>
						<!-- keyword -->
						<xsl:value-of select="."/>
						<xsl:text>|</xsl:text>
						<!-- language -->
						<xsl:value-of select="$language"/>
						<xsl:text>
</xsl:text>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:result-document>			
			
			<!-- Datei3 -->
			<xsl:result-document href="{$outPath}/{$filenameC}" format="csv">supplierArticleNo|factGroup|factIdentifier|factName|factValue|language<xsl:text>
</xsl:text>
				<xsl:for-each select="ARTICLE">
					<!-- variable fuer supplierArticleNo -->
					<xsl:variable name="supplierArticleNo" select="SUPPLIER_AID"/>
					<xsl:variable name="factGroup" select="ARTICLE_FEATURES/REFERENCE_FEATURE_GROUP_NAME"/> 
					<xsl:for-each select="ARTICLE_FEATURES/FEATURE">	
						<xsl:variable name="factName" select="FNAME"/>
						<xsl:variable name="factUnit" select="FUNIT"/>
						<xsl:if test="exists(FVALUE)">	
							<xsl:for-each select="FVALUE">
								<xsl:variable name="factValue" select="."/>
								<!-- supplierArticleNo -->
								<xsl:value-of select="$supplierArticleNo"/>
								<xsl:text>|</xsl:text>
								<!-- factGroup -->
								<xsl:value-of select="$factGroup"/>
								<xsl:text>|</xsl:text>
								<!-- factIdentifier -->
								<xsl:value-of select="$factName"/>
								<xsl:text>|</xsl:text>
								<!-- factName -->
								<xsl:value-of select="$factName"/>
								<xsl:text>|</xsl:text>
								<!-- factValue -->
								<!-- if( (contains($factName,'Breite')) or (contains($factName,'Höhe')) or (contains($factName,'Länge')) ) then ($factValue * str:umrechnen($factUnit)) else  -->
								<xsl:value-of select="$factValue"/>
								<xsl:text>|</xsl:text>
								<!-- language -->
								<xsl:value-of select="$language"/>
								<xsl:text>
</xsl:text>	
							</xsl:for-each>
						</xsl:if>
						<xsl:if test="exists(VARIANTS)">
							<xsl:for-each select="VARIANTS/VARIANT">
								<!-- supplierArticleNo -->
								<xsl:value-of select="$supplierArticleNo"/>
								<xsl:text>|</xsl:text>
								<!-- factGroup -->
								<xsl:value-of select="$factGroup"/>
								<xsl:text>|</xsl:text>
								<!-- factIdentifier -->
								<xsl:value-of select="$factName"/>
								<xsl:text>|</xsl:text>
								<!-- factName -->
								<xsl:value-of select="$factName"/>
								<xsl:text>|</xsl:text>
								<!-- factValue -->
								<xsl:value-of select="FVALUE"/>
								<xsl:text>|</xsl:text>
								<!-- language -->
								<xsl:value-of select="$language"/>
								<xsl:text>
</xsl:text>	
							</xsl:for-each>
						</xsl:if>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:result-document>
			
			
			<!-- Datei4: mediadata -->
			<xsl:result-document href="{$outPath}/{$filenameD}" format="csv">supplierArticleNo|mediaName|mediaType|downloadPath|mediaDescription|language|mediaClassification<xsl:text>
</xsl:text>
				<xsl:for-each select="ARTICLE">
					<xsl:variable name="supplierArticleNo" select="SUPPLIER_AID"/>
					<xsl:for-each select="MIME_INFO">
						<xsl:for-each select="MIME">
							<xsl:variable name="mediaType" select="str:mediaType(MIME_TYPE)"/>
							<xsl:if test="string-length($mediaType) &gt; 0">
								<!-- supplierArticleNo -->
								<xsl:value-of select= "$supplierArticleNo"/>
								<xsl:text>|</xsl:text>				
								<!-- mediaName -->
								<xsl:value-of select="MIME_SOURCE"/>
								<xsl:text>|</xsl:text>
								<!-- mediatype -->
								<xsl:value-of select="$mediaType"/>
								<xsl:text>|</xsl:text>							
								<!-- downlaodPath -->
								<xsl:choose>
									<xsl:when test="$url=''">
										<xsl:value-of select="MIME_SOURCE"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat($url,'/',MIME_SOURCE)"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>|</xsl:text>							
								<!-- mediaDescription -->
								<xsl:value-of select="str:textNormalize(MIME_DESCR)"/>		
								<xsl:text>|</xsl:text>
								<!-- language -->
								<xsl:value-of select="$language"/>
								<xsl:text>|</xsl:text>
								<!-- mediaClassification -->
								<xsl:choose>
									<xsl:when test="$mediaType='image'">
										<xsl:value-of select = "if(MIME_ORDER = 1) then 'FrontPicture' else 'GaleryPicture'"/>
									</xsl:when>
									<xsl:when test="$mediaType='pdf'">
										<xsl:value-of select = "'Manualpdf'"/>
									</xsl:when>
									<xsl:otherwise >
										<xsl:value-of select = "''"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>
</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:result-document>
			
			
			<!-- Datei5: dynamicdata -->			
			<xsl:result-document href="{$outPath}/{$filenameE}" format="csv">supplierArticleNo|currency|purchasePrice|listPrice|stockLevel|availabilityInDays|salesPrice|salesPriceOld|provisionType|provisionPercentage<xsl:text>
</xsl:text>
				<xsl:for-each select="ARTICLE">
					<!-- supplierArticleNo --> 
					<xsl:value-of  select="SUPPLIER_AID"/>
					<xsl:text>|</xsl:text>
					<!-- currency --> 
					<xsl:for-each select="ARTICLE_PRICE_DETAILS/ARTICLE_PRICE">
						<xsl:if test="@price_type='net_list'">
							<xsl:if test="LOWER_BOUND=1 or not(LOWER_BOUND)">
								<xsl:value-of select="PRICE_CURRENCY"/>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>					
					<xsl:text>|</xsl:text>
					<!-- purchasePrice 
										einkaufspreis ohne umsatzsteuer,
										mit umsatzsteuer: bei @price_type gros_list anstatt net_list eintragen  --> 
					<xsl:for-each select="ARTICLE_PRICE_DETAILS/ARTICLE_PRICE">
						<xsl:if test="@price_type='net_list'">
							<xsl:if test="LOWER_BOUND=1 or not(LOWER_BOUND)">
								<xsl:value-of select="PRICE_AMOUNT"/>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>				
					<xsl:text>|</xsl:text>
					<!-- listPrice --> 
					<xsl:for-each select="ARTICLE_PRICE_DETAILS/ARTICLE_PRICE">
						<xsl:if test="@price_type='nrp'">
							<xsl:if test="LOWER_BOUND=1 or not(LOWER_BOUND)">
								<xsl:value-of select="PRICE_AMOUNT"/>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>
					<xsl:text>|</xsl:text>									
					<!-- stockLevel --> 
					<xsl:text>|</xsl:text>
					<!-- availabilityInDays --> 
					<xsl:value-of select="ARTICLE_DETAILS/DELIVERY_TIME"/>
					<xsl:text>|</xsl:text>						
					<!-- salesPrice 
										kundenspezifischer endpreis ohne umsatzsteuer --> 
					<xsl:for-each select="ARTICLE_PRICE_DETAILS/ARTICLE_PRICE">
						<xsl:if test="@price_type='net_customer'">
							<xsl:if test="LOWER_BOUND=1 or not(LOWER_BOUND)">
								<xsl:value-of select="PRICE_AMOUNT"/>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>
					<!-- salesPriceOld --> 
					<xsl:text>|</xsl:text>
					<!-- provisionType --> 
					<xsl:text>|</xsl:text>
					<!-- provisionPercentage --> 
					<xsl:text>|</xsl:text>
					<xsl:text>
</xsl:text>		
				</xsl:for-each>				
			</xsl:result-document>
			
			<!-- Datei für keywords -->
			<xsl:result-document href="{$outPath}/{$filenameG}" format="csv">supplierArticleNo|classificationIdentifier|classificationName|classificationSystemName|classificationSystemType<xsl:text>
</xsl:text>
				<xsl:for-each select="ARTICLE">
					<xsl:variable name="supplierArticleNo" select="SUPPLIER_AID"/>
					<xsl:for-each select="ARTICLE_FEATURES/FEATURE">
						<xsl:if test="FNAME='Farbe' or FNAME='Größe' or FNAME='Konfektionsgröße'">
							<!-- supplierArticleNo --> 
							<xsl:value-of  select="$supplierArticleNo"/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="FVALUE"/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="FVALUE"/>
							<xsl:text>|</xsl:text>
							<xsl:value-of select="FNAME"/>
							<xsl:text>|</xsl:text>
							<xsl:text>VARIATION</xsl:text>
							<xsl:text>
</xsl:text>
						</xsl:if>
					</xsl:for-each>
					
				</xsl:for-each>
				
			</xsl:result-document>	
			
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>