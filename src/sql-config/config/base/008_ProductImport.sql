#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier

-- local variables go here
supplierref int8;
-- end variables block with 
BEGIN
	
DELETE from product."ImportConfigurationDO";

FOREACH supplierref IN ARRAY array[suppliers_all]
LOOP	
	
	--BASICDATA
	INSERT INTO product."ImportConfigurationDO"(
	            "id", "availabilityStoredProcedure", "copyStoredProcedure", "csvDelimiter", --1
				"csvHeader", 
				"storedProcedureGroup", "supplierRef",  "tableNameGroup", --4
				"checkMissingInLastDatapack", "importDatapackFileTypeDefRef", "canDatapackBeEmpty", "parentImportConfigurationRef", "convertToCSV", "createContentAssignment", --5
	            "internalMediaPath", "splitCount", "variationProcedure", "identifyOnBakeryArticleRef", "supplementArticleParent", --6
				"assortmentSupplier", "updateArticleType", "createManufacturer", "createSupplierAssortmentSystem", "csvQuote") --7
	    		SELECT nextval('"ImportConfigurationDO_id_seq"'), '', '', '''|''', --1
					'supplierArticleNo|manufacturer|manufacturerArticleNo|ISBN|EAN|articleName|length|height|width|weight|assortmentName|assortmentIdentifier|deliveryForm|customsTariffNo|parentSupplierArticleNo|articleForm|immaterialUid|articleLanguage|supplierSalesCode|supplierArticleIdentifier|articleType|edition|packagingUnit|packagingUnitValue', 
					'import_standard_a_v10', supplierref, 'Import_Standard_Basic_V10', --4
					FALSE, 1, TRUE, NULL, FALSE, FALSE, --5
		            '', 6, NULL, FALSE, TRUE, --6
					supplierref, FALSE, TRUE, TRUE, E'\30'; --7

	-- SKU Mapping 		
	INSERT INTO "ImportConfigurationDO" (
				id,	"availabilityStoredProcedure", "copyStoredProcedure","csvDelimiter", --1
				"csvHeader", --2
				"storedProcedureGroup", --4
				"supplierRef", "tableNameGroup", "checkMissingInLastDatapack", --5
				"importDatapackFileTypeDefRef",	"canDatapackBeEmpty", "parentImportConfigurationRef", --6
				"convertToCSV", "createContentAssignment", "internalMediaPath", --7
				"splitCount", "variationProcedure",	"identifyOnBakeryArticleRef", --8
				"supplementArticleParent", "assortmentSupplier", "updateArticleType", --9
				"importBeanDefRef", "createSupplierAssortmentSystem","createManufacturer", "financeControllerRef", "csvQuote") --10
			SELECT nextval('"ImportConfigurationDO_id_seq"'), '', '', '''|''', --1
					'supplierArticleNo|bakeryArticleNo|shopArticleNo',	--2
					'import_standard_n_v4', --4
					supplierref, 'Import_Standard_ShopArticleNo_V4', false, --5
					39,	false, NULL, --6
					false,	false,	'', --7
					6,	NULL,	false, --8
					false,	NULL, false, --9
					NULL, false, FALSE, NULL, E'\30'; --10
					
	--AVAILABILITY, PRICES
	INSERT INTO product."ImportConfigurationDO"(
	            "id", "availabilityStoredProcedure", "copyStoredProcedure", "csvDelimiter", --1 
				"csvHeader", 
				"storedProcedureGroup", "supplierRef", --4 
				"tableNameGroup", "checkMissingInLastDatapack", "importDatapackFileTypeDefRef", "canDatapackBeEmpty", --5
	            "parentImportConfigurationRef", "convertToCSV", "createContentAssignment", "internalMediaPath", "splitCount", --6
				"variationProcedure", "identifyOnBakeryArticleRef", "supplementArticleParent", "assortmentSupplier", "updateArticleType", "csvQuote") --7
	    		SELECT nextval('"ImportConfigurationDO_id_seq"'), 'process_availability_mapping_do_nothing', '', '''|''', -- 1 
					'supplierArticleNo|currency|purchasePrice|listPrice|stockLevel|stockType|availabilityInDays|salesPrice|basicPrice|basicPriceUnitValue|basicPriceUnit|salesPriceOld|provisionType|provisionPercentage|taxType|isBestseller', 
					'import_standard_bcg_v3', supplierref, --4
					'Import_Standard_Dynamic_V7', FALSE, 13, TRUE, --5
		            NULL, FALSE, FALSE, '', 6, --6 
					NULL, FALSE, TRUE, supplierref, FALSE, E'\30'; --7





	--Manual product upload (sales support only)
	--BASICDATA (ABC)
	INSERT INTO product."ImportConfigurationDO"(
	            "id", "availabilityStoredProcedure", "copyStoredProcedure", "csvDelimiter", --1
				"csvHeader", 
				"storedProcedureGroup", "supplierRef",  "tableNameGroup", --4
				"checkMissingInLastDatapack", "importDatapackFileTypeDefRef", "canDatapackBeEmpty", "parentImportConfigurationRef", "convertToCSV", "createContentAssignment", --5
	            "internalMediaPath", "splitCount", "variationProcedure", "identifyOnBakeryArticleRef", "supplementArticleParent", --6
				"assortmentSupplier", "updateArticleType", "createManufacturer", "createSupplierAssortmentSystem", "csvQuote") --7
	    		SELECT nextval('"ImportConfigurationDO_id_seq"'), 'random_availability', '', '''|''', --1
					'supplierArticleNo|manufacturer|manufacturerArticleNo|ISBN|EAN|articleName|length|height|width|weight|assortmentName|assortmentIdentifier|deliveryForm|customsTariffNo|parentSupplierArticleNo|articleForm|immaterialUid|articleLanguage|supplierSalesCode|supplierArticleIdentifier|articleType|edition|packagingUnit|packagingUnitValue', 
					'import_standard_a_v10', supplierref, 'Import_Standard_Basic_V10', --4
					FALSE, 6, TRUE, NULL, FALSE, FALSE, --5
		            '', 6, NULL, FALSE, TRUE, --6
					supplierref, FALSE, TRUE, TRUE, E'\30'; --7




	
	INSERT INTO "SupplierClassificationSystemDO"("id", "isActive", "classificationSystemDefRef", "supplierClassificationSystemName", "supplierRef")
	    SELECT nextval('"SupplierClassificationSystemDO_id_seq"'), true, 1, 'Dummy Assortment System', supplierref
			WHERE NOT EXISTS 
			(
				SELECT NULL FROM  "SupplierClassificationSystemDO" WHERE "supplierRef" = supplierref AND "classificationSystemDefRef" = 1
				AND "supplierClassificationSystemName" = 'Dummy Assortment System' 
			)
	;
	
	INSERT INTO "SupplierClassificationElementDO"("id", "supplierClassificationElementIdentifier", "supplierClassificationElementName", "parentElementRef", "supplierClassificationSystemRef")
	    SELECT nextval('"SupplierClassificationElementDO_id_seq"'), 'Dummy', 'Dummy', null, 
		(
			SELECT id FROM "SupplierClassificationSystemDO" WHERE "supplierRef" = supplierref AND "classificationSystemDefRef" = 1
			AND "supplierClassificationSystemName" = 'Dummy Assortment System')
			WHERE NOT EXISTS 
		(
			SELECT NULL FROM "SupplierClassificationElementDO" WHERE "supplierClassificationElementIdentifier" = 'Dummy' AND "supplierClassificationElementName" = 'Dummy'
			AND "supplierClassificationSystemRef" =(SELECT id FROM "SupplierClassificationSystemDO" WHERE "supplierRef" = supplierref AND "classificationSystemDefRef" = 1
			AND "supplierClassificationSystemName" = 'Dummy Assortment System')
		)	
	;			
					
END LOOP;

	
END;
$do; 