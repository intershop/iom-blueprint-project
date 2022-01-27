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
	-- returnCarrier, create article mapping, shop article no prefix
	carrier_dhl, FALSE, NULL
);

-- shop_intronics_b2b -> supplier_wh_texas
PERFORM create_or_update_shop2supplier(
	-- active, shopref, supplierref
	TRUE, shop_intronics_b2b, supplier_wh_texas,
	-- shopsuppliername, suppliershopname
	'inTRONICS Texas Warehouse', 'inTRONICS Business',
	-- returnCarrier, create article mapping, shop article no prefix
	carrier_dhl, FALSE, NULL
);

-- shop_intronics_b2b -> supplier_wh_arizona
PERFORM create_or_update_shop2supplier(
	-- active, shopref, supplierref
	TRUE, shop_intronics_b2b, supplier_wh_arizona,
	-- shopsuppliername, suppliershopname
	'inTRONICS Arizona Warehouse', 'inTRONICS Business',
	-- returnCarrier, create article mapping, shop article no prefix
	carrier_dhl, FALSE, NULL
);

-- shop_intronics_b2b -> supplier_wh_losangeles
PERFORM create_or_update_shop2supplier(
	-- active, shopref, supplierref
	TRUE, shop_intronics_b2b, supplier_wh_losangeles,
	-- shopsuppliername, suppliershopname
	'inTRONICS Los Angeles Warehouse', 'inTRONICS Business',
	-- returnCarrier, create article mapping, shop article no prefix
	carrier_dhl, FALSE, NULL
);

-- shop_intronics_b2c -> supplier_wh_detroit
PERFORM create_or_update_shop2supplier(
	-- active, shopref, supplierref
	TRUE, shop_intronics_b2c, supplier_wh_detroit,
	-- shopsuppliername, suppliershopname
	'inTRONICS Detroit Warehouse', 'inTRONICS',
	-- returnCarrier, create article mapping, shop article no prefix
	carrier_dhl, FALSE, NULL
);

-- shop_intronics_b2c -> supplier_retailer_losangeles
PERFORM create_or_update_shop2supplier(
	-- active, shopref, supplierref
	TRUE, shop_intronics_b2c, supplier_retailer_losangeles,
	-- shopsuppliername, suppliershopname
	'inTRONICS Los Angeles Retailer', 'inTRONICS',
	-- returnCarrier, create article mapping, shop article no prefix
	carrier_dhl, FALSE, NULL
);

-- enable cash on delivery (COD) for all suppliers (except internal)
UPDATE oms."Shop2SupplierDO"
	SET "supplierSupportsCOD" = TRUE
	WHERE "supplierRef" >= 10000;

-- stockReduceModel: on delivery for all
UPDATE oms."Shop2SupplierDO"
	SET "stockReduceModel" = 50;
	
END;
]]#
-- dollar quoting
$do;
