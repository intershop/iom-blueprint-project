#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier

-- PAUSE velocity parser
#[[

-- local variables go here
shopref bigint;
supplierref bigint;
shop2supplierref bigint;
shop2supplier2reducereasonref bigint;
-- end variables block with 
BEGIN

-- lazy upsert - delete everything
DELETE FROM "ReductionValueDO";
ALTER SEQUENCE "ReductionValueDO_id_seq" RESTART WITH 10000;

FOREACH shopref IN ARRAY shops_all
LOOP
	FOREACH supplierref IN ARRAY suppliers_all || supplier_int
	LOOP
		-- make sure we only iterate over existing Shop2SupplierDOs
		shop2supplierref = (SELECT id FROM oms."Shop2SupplierDO" WHERE "shopRef" = shopref and "supplierRef" = supplierref);
		CONTINUE WHEN shop2supplierref IS NULL;
				
		shop2supplier2reducereasonref = upsert_shop2supplier2reducereason('AK-100', 'default', shop2supplierref, true);

		INSERT INTO oms."ReductionValueDO"(
				id, "reductionInPercent", "validFrom", "validUntil", "shop2Supplier2ReduceReasonRef")
		SELECT nextval('oms."ReductionValueDO_id_seq"'), '100.0000', '2000-01-01 00:00:00', '2999-01-01 00:00:00', shop2supplier2reducereasonref;

		shop2supplier2reducereasonref = upsert_shop2supplier2reducereason('AK-0', 'AK-0', shop2supplierref, false);

		INSERT INTO oms."ReductionValueDO"(
				id, "reductionInPercent", "validFrom", "validUntil", "shop2Supplier2ReduceReasonRef")
		SELECT nextval('oms."ReductionValueDO_id_seq"'), '0.0000', '2000-01-01 00:00:00', '2999-01-01 00:00:00', shop2supplier2reducereasonref;
	END LOOP;
END LOOP;


END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;