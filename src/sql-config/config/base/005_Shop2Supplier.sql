#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier
$vars_carriers

-- PAUSE velocity parser
#[[
-- local variables go here
shopref int8;
supplierref int8;
-- end variables block with 
BEGIN

-- shop_intronics_b2c -> supplier_wh_texas
PERFORM create_or_update_shop2supplier(
	-- active, shopref, supplierref
	TRUE, shop_intronics_b2c, supplier_wh_texas,
	-- shopsuppliername, suppliershopname
	'inTRONICS Texas Warehouse', 'inTRONICS',
	-- returnCarrier,
	carrier_dhl,
	-- create article mapping (if true, creates automatically an N-file after A/ABC-file to be imported), shop article no prefix
	TRUE, ''
);

-- shop_intronics_b2b -> supplier_wh_texas
PERFORM create_or_update_shop2supplier(
	-- active, shopref, supplierref
	TRUE, shop_intronics_b2b, supplier_wh_texas,
	-- shopsuppliername, suppliershopname
	'inTRONICS Texas Warehouse', 'inTRONICS Business',
	-- returnCarrier,
	carrier_dhl,
	-- create article mapping (if true, creates automatically an N-file after A/ABC-file import to be imported), shop article no prefix
	TRUE, ''
);

-- shop_intronics_b2b -> supplier_wh_arizona
PERFORM create_or_update_shop2supplier(
	-- active, shopref, supplierref
	TRUE, shop_intronics_b2b, supplier_wh_arizona,
	-- shopsuppliername, suppliershopname
	'inTRONICS Arizona Warehouse', 'inTRONICS Business',
	-- returnCarrier,
	carrier_dhl,
	-- create article mapping (if true, creates automatically an N-file after A/ABC-file to be imported), shop article no prefix
	TRUE, ''
);

-- shop_intronics_b2b -> supplier_wh_losangeles
PERFORM create_or_update_shop2supplier(
	-- active, shopref, supplierref
	TRUE, shop_intronics_b2b, supplier_wh_losangeles,
	-- shopsuppliername, suppliershopname
	'inTRONICS Los Angeles Warehouse', 'inTRONICS Business',
	-- returnCarrier,
	carrier_dhl,
	-- create article mapping (if true, creates automatically an N-file after A/ABC-file to be imported), shop article no prefix
	TRUE, ''
);

-- shop_intronics_b2c -> supplier_wh_detroit
PERFORM create_or_update_shop2supplier(
	-- active, shopref, supplierref
	TRUE, shop_intronics_b2c, supplier_wh_detroit,
	-- shopsuppliername, suppliershopname
	'inTRONICS Detroit Warehouse', 'inTRONICS',
	-- returnCarrier,
	carrier_dhl,
	-- create article mapping (if true, creates automatically an N-file after A/ABC-file to be imported), shop article no prefix
	TRUE, ''
);

-- shop_intronics_b2c -> supplier_retailer_losangeles
PERFORM create_or_update_shop2supplier(
	-- active, shopref, supplierref
	TRUE, shop_intronics_b2c, supplier_retailer_losangeles,
	-- shopsuppliername, suppliershopname
	'inTRONICS Los Angeles Retailer', 'inTRONICS',
	-- returnCarrier,
	carrier_dhl,
	-- create article mapping (if true, creates automatically an N-file after A/ABC-file to be imported), shop article no prefix
	TRUE, ''
);


/* all shops must be mapped to the internal supplier */

-- shop_intronics_b2c -> internal supplier
PERFORM create_or_update_shop2supplier(
	-- active, shopref, supplierref
	TRUE, shop_intronics_b2c, supplier_int,
	-- shopsuppliername, suppliershopname
	NULL, NULL,
	-- returnCarrier,
	carrier_dhl,
	-- create article mapping (if true, creates automatically an N-file after A/ABC-file to be imported), shop article no prefix
	TRUE, ''
);


-- shop_intronics_b2b -> internal supplier
PERFORM create_or_update_shop2supplier(
	-- active, shopref, supplierref
	TRUE, shop_intronics_b2b, supplier_int,
	-- shopsuppliername, suppliershopname
	NULL, NULL,
	-- returnCarrier,
	carrier_dhl,
	-- create article mapping (if true, creates automatically an N-file after A/ABC-file to be imported), shop article no prefix
	TRUE, ''
);

-- enable cash on delivery (COD) for 3 suppliers only
UPDATE oms."Shop2SupplierDO"
	SET "supplierSupportsCOD" = FALSE
	WHERE "supplierRef" NOT IN (supplier_wh_texas, supplier_wh_arizona, supplier_wh_detroit);

UPDATE oms."Shop2SupplierDO"
	SET "supplierSupportsCOD" = TRUE
	WHERE "supplierRef" IN (supplier_wh_texas, supplier_wh_arizona, supplier_wh_detroit);

-- stockReduceModel: on delivery for all
UPDATE oms."Shop2SupplierDO"
	SET "stockReduceModel" = 50;
	
END;
]]#
-- dollar quoting
$do;
