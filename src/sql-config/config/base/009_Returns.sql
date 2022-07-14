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



-- Shop return types
FOREACH shopref in array shops_all LOOP

	-- RETURN
	IF NOT EXISTS (SELECT NULL FROM "Shop2ReturnTypeDefDO" WHERE "shopRef" = shopref AND "returnTypeDefRef" = 4) THEN
		INSERT INTO "Shop2ReturnTypeDefDO"
		SELECT nextval('"Shop2ReturnTypeDefDO_id_seq"'), 4, 'RET', shopref;
	END IF;

	-- DEFECT
	IF NOT EXISTS (SELECT NULL FROM "Shop2ReturnTypeDefDO" WHERE "shopRef" = shopref AND "returnTypeDefRef" = 5) THEN
		INSERT INTO "Shop2ReturnTypeDefDO"
		SELECT nextval('"Shop2ReturnTypeDefDO_id_seq"'), 5, 'DEF', shopref;
	END IF;
END LOOP;



-- Shop return reasons
FOREACH shopref IN ARRAY shops_all
LOOP
	INSERT INTO "Shop2ReturnReasonDefDO" (id, "returnReasonDefRef", "shopReturnReasonName", "shopRef")
		
		SELECT nextval('"Shop2ReturnReasonDefDO_id_seq"'), 301, 'RET020', shopref UNION ALL
		SELECT nextval('"Shop2ReturnReasonDefDO_id_seq"'), 313, 'RET045', shopref UNION ALL
		SELECT nextval('"Shop2ReturnReasonDefDO_id_seq"'), 304, 'RET050', shopref UNION ALL
		SELECT nextval('"Shop2ReturnReasonDefDO_id_seq"'), 305, 'RET060', shopref UNION ALL
		SELECT nextval('"Shop2ReturnReasonDefDO_id_seq"'), 308, 'RET090', shopref UNION ALL
		SELECT nextval('"Shop2ReturnReasonDefDO_id_seq"'), 323, 'RET190', shopref UNION ALL
		SELECT nextval('"Shop2ReturnReasonDefDO_id_seq"'), 312, 'RET990', shopref

		/* in preparation */
		--SELECT nextval('"Shop2ReturnReasonDefDO_id_seq"'), 1, 'CAN010', shopref UNION ALL
		--SELECT nextval('"Shop2ReturnReasonDefDO_id_seq"'), 114, 'RCL045', shopref

	ON CONFLICT ("returnReasonDefRef", "shopRef") DO UPDATE SET "shopReturnReasonName" = EXCLUDED."shopReturnReasonName"
	;
	
	/* in preparation */
	-- approval reason mapping Shop2ReturnReason2ApprovalStateCodeReasonDefDO
	/*
	INSERT INTO "Shop2ReturnReason2ApprovalStateCodeReasonDefDO"(id, "approvalStateCodeReasonDefRef", "shop2ReturnReasonDefRef")
    	SELECT nextval('"Shop2ReturnReason2ApprovalStateCodeReasonDefDO_id_seq"'), 4100, (select id from "Shop2ReturnReasonDefDO" where "returnReasonDefRef" = 114 and "shopRef" = shopref)
    ON CONFLICT ("approvalStateCodeReasonDefRef", "shop2ReturnReasonDefRef") DO NOTHING;
	*/

END LOOP;



-- Supplier return types
FOREACH supplierref IN ARRAY suppliers_all
LOOP
	INSERT INTO "Supplier2ReturnTypeDefDO"(id, "returnTypeDefRef", "supplierReturnTypeName", "supplierRef", "rmaNo", preselected)
		
		SELECT nextval('"Supplier2ReturnTypeDefDO_id_seq"'), 1, 'CAN', supplierref, '', false UNION ALL
		SELECT nextval('"Supplier2ReturnTypeDefDO_id_seq"'), 2, 'RCL', supplierref, '', false UNION ALL
		SELECT nextval('"Supplier2ReturnTypeDefDO_id_seq"'), 3, 'INV', supplierref, '', false UNION ALL
		SELECT nextval('"Supplier2ReturnTypeDefDO_id_seq"'), 4, 'RET', supplierref, '', true  UNION ALL
		SELECT nextval('"Supplier2ReturnTypeDefDO_id_seq"'), 5, 'DEF', supplierref, '', false
		ON CONFLICT DO NOTHING
		;

END LOOP;



-- Supplier return reasons
FOREACH supplierref IN ARRAY suppliers_all
LOOP
	INSERT INTO "Supplier2ReturnReasonDefDO" (id, "returnReasonDefRef", "supplierReturnReasonName", "supplierRef", "preselected")

		SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 301, 'RET020', supplierref, false UNION ALL
		SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 313, 'RET045', supplierref, false UNION ALL
		SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 304, 'RET050', supplierref, false UNION ALL
		SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 305, 'RET060', supplierref, false UNION ALL
		SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 308, 'RET090', supplierref, false UNION ALL
		SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 323, 'RET190', supplierref, false UNION ALL
		SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 312, 'RET990', supplierref, false

		/* in preparation */
		--SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 1, 'CAN010', supplierref, false UNION ALL
		--SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 2, 'CAN020', supplierref, false UNION ALL
		--SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 12, 'CAN990', supplierref, false UNION ALL

		--SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 100, 'RCL010', supplierref, false UNION ALL
		--SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 101, 'RCL015', supplierref, false UNION ALL
		--SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 102, 'RCL020', supplierref, false UNION ALL
		--SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 109, 'RCL990', supplierref, false UNION ALL

		--SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), 204, 'INV990', supplierref, false UNION ALL
		;
END LOOP;



-- Supplier return addresses (based on entries in Shop2SupplierDO and Supplier2ReturnTypeDefDO)
DELETE FROM oms."SupplierReturnAddressDO";

FOREACH shopref IN ARRAY shops_all
LOOP
	FOREACH supplierref IN ARRAY suppliers_all
	LOOP
		IF EXISTS (SELECT id FROM "Shop2SupplierDO" WHERE "shopRef" = shopref and "supplierRef" = supplierref) THEN
			WITH RES AS (SELECT 'RCL' as reason_name UNION ALL
			             SELECT 'INV' as reason_name UNION ALL
			             SELECT 'RET' as reason_name UNION ALL
			             SELECT 'DEF' as reason_name
			            )
			INSERT INTO "SupplierReturnAddressDO"(
						"id", "addressLine1", "addressLine2", "addressLine3", "addressLine4", "addressLine5", "supplier2ReturnTypeDefRef", "shop2SupplierRef")

				SELECT nextval('"SupplierReturnAddressDO_id_seq"'), 'inTRONICS Return Center c/o Intershop Communications, Inc.' , '25 Lusk Street', 'San Francisco, CA 94107, United States', 'Phone.: +1 123 456-0000', 'Fax: +1 123 456-0099',
								(select id from "Supplier2ReturnTypeDefDO" where "supplierRef" = supplierref and "supplierReturnTypeName" = reason_name),
								(select id from "Shop2SupplierDO"          where "supplierRef" = supplierref and "shopRef" = shopref)
								from RES ON CONFLICT DO NOTHING
				;
		END IF;
	END LOOP;
END LOOP;



-- Return reductions

-- lazy upsert - delete everything
DELETE FROM "ReductionValueDO";
ALTER SEQUENCE "ReductionValueDO_id_seq" RESTART WITH 10000;

FOREACH shopref IN ARRAY shops_all
LOOP
	FOREACH supplierref IN ARRAY suppliers_all || supplier_int
	LOOP
		-- iterate existing Shop2SupplierDOs
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



-- to generate RMA numbers
CREATE SEQUENCE IF NOT EXISTS "rma_number_sequence_generator"
  INCREMENT 1
  START 10000
  CYCLE -- allows the sequence to wrap around when the maxvalue or minvalue has been reached by an ascending or descending sequence respectively
;



-- Enable the creation of return-related documents

-- return slip
perform admin.add_document_transformer_config(1, 2, 7, shopRef, 2, true); /* p_documentformatdefref, p_documentmapperdefref, p_documenttypedefref, p_shopref, p_transformerframeworkdefref, p_save */
	
-- return label and documentMapperDefRef=1
-- requires BarCodeGenDO
perform admin.add_document_transformer_config(1, 1, 1, shopRef, 2, true); /* p_documentformatdefref, p_documentmapperdefref, p_documenttypedefref, p_shopref, p_transformerframeworkdefref, p_save */



END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;