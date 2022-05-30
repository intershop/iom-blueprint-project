#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier
$vars_carriers

-- PAUSE velocity parser
#[[

-- local variables go here
supplierRef int8;
carrierRef int8;

-- end variables block with 
BEGIN


carrierRef = carriers_all[1]; -- there's currently just one

IF (select count(*) from "BarCodeGenDO") < 1 THEN

	-- B2C Suppliers
	INSERT INTO oms."BarCodeGenDO"
	(
	  id, "barCodeCounter", "barCodeEnd", "barCodeStart", "interval",
	  "minEndDate", "modificationDate", "startDate", version, "carrierRef",
	  "shopRef", "supplierRef"
	)
	SELECT 
		nextval('oms."BarCodeGenDO_id_seq"'), '000000', '100000', '000000',	1,
		null, now(), '2022-06-01 00:00:00', 1, carrierRef,
		shop_intronics_b2c, supplier_retailer_losangeles;
		
	INSERT INTO oms."BarCodeGenDO"
	(
	  id, "barCodeCounter", "barCodeEnd", "barCodeStart", "interval",
	  "minEndDate", "modificationDate", "startDate", version, "carrierRef",
	  "shopRef", "supplierRef"
	)
	SELECT 
		nextval('oms."BarCodeGenDO_id_seq"'), '100001', '200000', '100001',	1,
		null, now(), '2022-06-01 00:00:00', 1, carrierRef,
		shop_intronics_b2c, supplier_wh_detroit;
		
	INSERT INTO oms."BarCodeGenDO"
	(
	  id, "barCodeCounter", "barCodeEnd", "barCodeStart", "interval",
	  "minEndDate", "modificationDate", "startDate", version, "carrierRef",
	  "shopRef", "supplierRef"
	)
	SELECT 
		nextval('oms."BarCodeGenDO_id_seq"'), '200001', '300000', '200001',	1,
		null, now(), '2022-06-01 00:00:00', 1, carrierRef,
		shop_intronics_b2c, supplier_wh_texas;

	
	
	-- B2B Suppliers
	INSERT INTO oms."BarCodeGenDO"
	(
	  id, "barCodeCounter", "barCodeEnd", "barCodeStart", "interval",
	  "minEndDate", "modificationDate", "startDate", version, "carrierRef",
	  "shopRef", "supplierRef"
	)
	SELECT 
		nextval('oms."BarCodeGenDO_id_seq"'), '300001', '400000', '300001',	1,
		null, now(), '2022-06-01 00:00:00', 1, carrierRef,
		shop_intronics_b2b, supplier_wh_losangeles;
		
	INSERT INTO oms."BarCodeGenDO"
	(
	  id, "barCodeCounter", "barCodeEnd", "barCodeStart", "interval",
	  "minEndDate", "modificationDate", "startDate", version, "carrierRef",
	  "shopRef", "supplierRef"
	)
	SELECT 
		nextval('oms."BarCodeGenDO_id_seq"'), '400001', '500000', '400001',	1,
		null, now(), '2022-06-01 00:00:00', 1, carrierRef,
		shop_intronics_b2b, supplier_wh_texas;
		
	INSERT INTO oms."BarCodeGenDO"
	(
	  id, "barCodeCounter", "barCodeEnd", "barCodeStart", "interval",
	  "minEndDate", "modificationDate", "startDate", version, "carrierRef",
	  "shopRef", "supplierRef"
	)
	SELECT 
		nextval('oms."BarCodeGenDO_id_seq"'), '500001', '600000', '500001',	1,
		null, now(), '2022-06-01 00:00:00', 1, carrierRef,
		shop_intronics_b2b, supplier_wh_arizona;

END IF;

END;
]]#
-- dollar quoting
$do;