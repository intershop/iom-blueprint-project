#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier
$vars_country_codes

-- PAUSE velocity parser
#[[
-- local variables go here
supplierref bigint;
suppliermap varchar[][];
complexsupplier varchar[];
-- end variables block with 
BEGIN

-- Warehouse Texas
IF NOT EXISTS (SELECT NULL FROM "SupplierDO" WHERE id = supplier_wh_texas) THEN
	PERFORM admin.createsupplier
	(
		supplier_wh_texas,          						-- new SupplierDO.id              int8,  (will use the table serial when NULL)
	    'inSPIRED',		         							-- parent_org_name                varchar
	    TRUE,                       						-- active                         boolean
	    FALSE,                      						-- contentsupplier                boolean
	    1,                          						-- countrycodedefref              integer
	    cc_us,                          					-- countrydefref                  integer (for the US)
	    '',                         						-- cutofftime                     varchar
	    TRUE,                       						-- deliveringsupplier             boolean
	    TRUE,                       						-- legal                          boolean
    	'inTRONICS Texas Warehouse',						-- name                           varchar
	    'inTRONICS Texas Warehouse',						-- suppliername                   varchar
	    FALSE,                      						-- supportsreservation            boolean
	    TRUE,                       						-- supportsresponse               boolean
	    FALSE,                       						-- singlepositionarticle          boolean
	    'inTRONICS Texas Warehouse',						-- internalsuppliername           varchar
	    NULL,                       						-- parentsupplierref              bigint,
	    FALSE,                      						-- cleanparentonimport            boolean
	    FALSE,                      						-- ignoreadditionalpositions      boolean
	    NULL,                       						-- businessobjectprocessingdelay  varchar
	    2                           						-- suppliertypedefref             integer (meaning Warehouse)
	);
ELSE
    -- update stuff
    --UPDATE "SupplierDO" SET "countryDefRef" = cc_us WHERE id = supplier_wh_texas;
END IF;

-- Warehouse Arizona
IF NOT EXISTS (SELECT NULL FROM "SupplierDO" WHERE id = supplier_wh_arizona) THEN
	PERFORM admin.createsupplier
	(
		supplier_wh_arizona,          						-- new SupplierDO.id              int8,  (will use the table serial when NULL)
	    'inSPIRED',		         							-- parent_org_name                varchar
	    TRUE,                       						-- active                         boolean
	    FALSE,                      						-- contentsupplier                boolean
	    1,                          						-- countrycodedefref              integer
	    cc_us,                          					-- countrydefref                  integer (for the US)
	    '',                         						-- cutofftime                     varchar
	    TRUE,                       						-- deliveringsupplier             boolean
	    TRUE,                       						-- legal                          boolean
    	'inTRONICS Arizona Warehouse',						-- name                           varchar
	    'inTRONICS Arizona Warehouse',						-- suppliername                   varchar
	    FALSE,                      						-- supportsreservation            boolean
	    TRUE,                       						-- supportsresponse               boolean
	    FALSE,                       						-- singlepositionarticle          boolean
	    'inTRONICS Arizona Warehouse',						-- internalsuppliername           varchar
	    NULL,                       						-- parentsupplierref              bigint,
	    FALSE,                      						-- cleanparentonimport            boolean
	    FALSE,                      						-- ignoreadditionalpositions      boolean
	    NULL,                       						-- businessobjectprocessingdelay  varchar
	    2                           						-- suppliertypedefref             integer (meaning Warehouse)
	);
ELSE
    -- update stuff
    --UPDATE "SupplierDO" SET "countryDefRef" = cc_us WHERE id = supplier_wh_arizona;
END IF;

-- Warehouse Los Angeles
IF NOT EXISTS (SELECT NULL FROM "SupplierDO" WHERE id = supplier_wh_losangeles) THEN
	PERFORM admin.createsupplier
	(
		supplier_wh_losangeles,          						-- new SupplierDO.id              int8,  (will use the table serial when NULL)
	    'inSPIRED',		         							-- parent_org_name                varchar
	    TRUE,                       						-- active                         boolean
	    FALSE,                      						-- contentsupplier                boolean
	    1,                          						-- countrycodedefref              integer
	    cc_us,                          					-- countrydefref                  integer (for the US)
	    '',                         						-- cutofftime                     varchar
	    TRUE,                       						-- deliveringsupplier             boolean
	    TRUE,                       						-- legal                          boolean
    	'inTRONICS Los Angeles Warehouse',					-- name                           varchar
	    'inTRONICS Los Angeles Warehouse',					-- suppliername                   varchar
	    FALSE,                      						-- supportsreservation            boolean
	    TRUE,                       						-- supportsresponse               boolean
	    FALSE,                       						-- singlepositionarticle          boolean
	    'inTRONICS Los Angeles Warehouse',					-- internalsuppliername           varchar
	    NULL,                       						-- parentsupplierref              bigint,
	    FALSE,                      						-- cleanparentonimport            boolean
	    FALSE,                      						-- ignoreadditionalpositions      boolean
	    NULL,                       						-- businessobjectprocessingdelay  varchar
	    2                           						-- suppliertypedefref             integer (meaning Warehouse)
	);
ELSE
    -- update stuff
    --UPDATE "SupplierDO" SET "countryDefRef" = cc_us WHERE id = supplier_wh_losangeles;
END IF;

-- Warehouse Detroit
IF NOT EXISTS (SELECT NULL FROM "SupplierDO" WHERE id = supplier_wh_detroit) THEN
	PERFORM admin.createsupplier
	(
		supplier_wh_detroit,          						-- new SupplierDO.id              int8,  (will use the table serial when NULL)
	    'inSPIRED',		         							-- parent_org_name                varchar
	    TRUE,                       						-- active                         boolean
	    FALSE,                      						-- contentsupplier                boolean
	    1,                          						-- countrycodedefref              integer
	    cc_us,                          					-- countrydefref                  integer (for the US)
	    '',                         						-- cutofftime                     varchar
	    TRUE,                       						-- deliveringsupplier             boolean
	    TRUE,                       						-- legal                          boolean
    	'inTRONICS Detroit Warehouse',						-- name                           varchar
	    'inTRONICS Detroit Warehouse',						-- suppliername                   varchar
	    FALSE,                      						-- supportsreservation            boolean
	    TRUE,                       						-- supportsresponse               boolean
	    FALSE,                       						-- singlepositionarticle          boolean
	    'inTRONICS Detroit Warehouse',						-- internalsuppliername           varchar
	    NULL,                       						-- parentsupplierref              bigint,
	    FALSE,                      						-- cleanparentonimport            boolean
	    FALSE,                      						-- ignoreadditionalpositions      boolean
	    NULL,                       						-- businessobjectprocessingdelay  varchar
	    2                           						-- suppliertypedefref             integer (meaning Warehouse)
	);
ELSE
    -- update stuff
    --UPDATE "SupplierDO" SET "countryDefRef" = cc_us WHERE id = supplier_wh_detroit;
END IF;

-- Retailer Los Angeles 
IF NOT EXISTS (SELECT NULL FROM "SupplierDO" WHERE id = supplier_retailer_losangeles) THEN
	PERFORM admin.createsupplier
	(
		supplier_retailer_losangeles,          						-- new SupplierDO.id              int8,  (will use the table serial when NULL)
	    'inSPIRED',		         							-- parent_org_name                varchar
	    TRUE,                       						-- active                         boolean
	    FALSE,                      						-- contentsupplier                boolean
	    1,                          						-- countrycodedefref              integer
	    cc_us,                          					-- countrydefref                  integer (for the US)
	    '',                         						-- cutofftime                     varchar
	    TRUE,                       						-- deliveringsupplier             boolean
	    TRUE,                       						-- legal                          boolean
    	'inTRONICS Los Angeles Retailer',					-- name                           varchar
	    'inTRONICS Los Angeles Retailer',					-- suppliername                   varchar
	    FALSE,                      						-- supportsreservation            boolean
	    TRUE,                       						-- supportsresponse               boolean
	    FALSE,                       						-- singlepositionarticle          boolean
	    'inTRONICS Los Angeles Retailer',					-- internalsuppliername           varchar
	    NULL,                       						-- parentsupplierref              bigint,
	    FALSE,                      						-- cleanparentonimport            boolean
	    FALSE,                      						-- ignoreadditionalpositions      boolean
	    NULL,                       						-- businessobjectprocessingdelay  varchar
	    1                           						-- suppliertypedefref             integer (meaning Retailer)
	);
ELSE
    -- update stuff
    --UPDATE "SupplierDO" SET "countryDefRef" = cc_us WHERE id = supplier_retailer_losangeles;
END IF;


-- refetch this stuff to prevent chicken-egg problems on initial installation
suppliers_all = array(select id from oms."SupplierDO" where id > 1);
FOREACH supplierref IN ARRAY suppliers_all LOOP

	IF NOT EXISTS (SELECT NULL FROM "PartnerReferrerDO" WHERE "supplierRef" = supplierref) THEN
	    INSERT INTO oms."PartnerReferrerDO" ("id", "version", "supplierRef")
        SELECT nextval('oms."PartnerReferrerDO_id_seq"'), 0, supplierref
        ON CONFLICT("supplierRef") DO NOTHING;
	END IF;
END LOOP;


END;
]]#
-- dollar quoting
$do;
