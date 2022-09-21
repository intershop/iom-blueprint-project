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
	INSERT INTO "Shop2ReturnTypeDefDO" (id, "returnTypeDefRef", "shopReturnTypeName", "shopRef")
	SELECT nextval('"Shop2ReturnTypeDefDO_id_seq"'), 4, 'RET', shopref
	WHERE NOT EXISTS (SELECT * FROM "Shop2ReturnTypeDefDO" WHERE "shopRef" = shopref AND "returnTypeDefRef" = 4);

	-- DEFECT
	INSERT INTO "Shop2ReturnTypeDefDO" (id, "returnTypeDefRef", "shopReturnTypeName", "shopRef")
	SELECT nextval('"Shop2ReturnTypeDefDO_id_seq"'), 5, 'DEF', shopref
	WHERE NOT EXISTS (SELECT * FROM "Shop2ReturnTypeDefDO" WHERE "shopRef" = shopref AND "returnTypeDefRef" = 5);

	-- Shop return reasons
	WITH alist (reason, rname, shop) AS
	(	
		SELECT 301, 'RET020', shopref UNION ALL
		SELECT 313, 'RET045', shopref UNION ALL
		SELECT 304, 'RET050', shopref UNION ALL
		SELECT 305, 'RET060', shopref UNION ALL
		SELECT 308, 'RET090', shopref UNION ALL
		SELECT 323, 'RET190', shopref UNION ALL
		SELECT 312, 'RET990', shopref
	)

	INSERT INTO "Shop2ReturnReasonDefDO" (id, "returnReasonDefRef", "shopReturnReasonName", "shopRef")
	SELECT nextval('"Shop2ReturnReasonDefDO_id_seq"'), reason, rname, shop
	FROM alist
	WHERE (reason, shop)  NOT IN (select "returnReasonDefRef", "shopRef" from  "Shop2ReturnReasonDefDO");
	
	/* in preparation */
	-- approval reason mapping Shop2ReturnReason2ApprovalStateCodeReasonDefDO
	/*
	INSERT INTO "Shop2ReturnReason2ApprovalStateCodeReasonDefDO"(id, "approvalStateCodeReasonDefRef", "shop2ReturnReasonDefRef")
    	SELECT nextval('"Shop2ReturnReason2ApprovalStateCodeReasonDefDO_id_seq"'), 4100, (select id from "Shop2ReturnReasonDefDO" where "returnReasonDefRef" = 114 and "shopRef" = shopref)
    ON CONFLICT ("approvalStateCodeReasonDefRef", "shop2ReturnReasonDefRef") DO NOTHING;
	*/

END LOOP;


FOREACH supplierref IN ARRAY suppliers_all
LOOP

	-- Supplier return types
	WITH alist (rtype, rname, supplier, rma, preselect) AS
	(	
			SELECT  1, 'CAN', supplierref, '', false UNION ALL
			SELECT  2, 'RCL', supplierref, '', false UNION ALL
			SELECT  3, 'INV', supplierref, '', false UNION ALL
			SELECT  4, 'RET', supplierref, '', true  UNION ALL
			SELECT  5, 'DEF', supplierref, '', false
	)
	INSERT INTO "Supplier2ReturnTypeDefDO"(id, "returnTypeDefRef", "supplierReturnTypeName", "supplierRef", "rmaNo", preselected)
	SELECT nextval('"Supplier2ReturnTypeDefDO_id_seq"'), rtype, rname, supplier, rma, preselect
	FROM alist
	WHERE (rtype, supplier)  NOT IN (select "returnTypeDefRef", "supplierRef" from  "Supplier2ReturnTypeDefDO");


	-- Supplier return reasons
	-- should have one preselected pro type
	WITH alist (returnreason,reasonname,supplier, preselect) AS
	(	
			SELECT  301, 'RET020', supplierref, true UNION ALL
			SELECT  313, 'RET045', supplierref, false UNION ALL
			SELECT  304, 'RET050', supplierref, false UNION ALL
			SELECT  305, 'RET060', supplierref, false UNION ALL
			SELECT  308, 'RET090', supplierref, false UNION ALL
			SELECT  323, 'RET190', supplierref, false UNION ALL
			SELECT  312, 'RET990', supplierref, false

			/* in preparation */
			--SELECT  1, 'CAN010', supplierref, false UNION ALL
			--SELECT  2, 'CAN020', supplierref, false UNION ALL
			--SELECT  12, 'CAN990', supplierref, false UNION ALL

			--SELECT  100, 'RCL010', supplierref, false UNION ALL
			--SELECT  101, 'RCL015', supplierref, false UNION ALL
			--SELECT  102, 'RCL020', supplierref, false UNION ALL
			--SELECT  109, 'RCL990', supplierref, false UNION ALL

			--SELECT  204, 'INV990', supplierref, false UNION ALL
	)
	INSERT INTO "Supplier2ReturnReasonDefDO" (id, "returnReasonDefRef", "supplierReturnReasonName", "supplierRef", "preselected")
	SELECT nextval('"Supplier2ReturnReasonDefDO_id_seq"'), returnreason, reasonname, supplier, preselect
	FROM alist 
	WHERE (returnreason, supplier) NOT IN (select "returnReasonDefRef", "supplierRef" from  "Supplier2ReturnReasonDefDO");

END LOOP;




-- Supplier return addresses (based on entries in Shop2SupplierDO and Supplier2ReturnTypeDefDO)

	WITH alist (supplier_returntype_id, shop_supplier_id) AS
		(	
		SELECT rt.id as supplier_returntype_id, 
		s2s.id as shop_supplier_id
		FROM "Supplier2ReturnTypeDefDO" rt
		JOIN "Shop2SupplierDO" s2s ON( rt."supplierRef" = s2s."supplierRef")
		WHERE rt."supplierReturnTypeName" <> 'CAN' --no return address for cancelations
		AND s2s."shopRef"= ANY(shops_all) AND s2s."supplierRef"=ANY(suppliers_all)
		)
	INSERT INTO "SupplierReturnAddressDO"(
				"id", "addressLine1", "addressLine2", "addressLine3", "addressLine4", "addressLine5", 
				"supplier2ReturnTypeDefRef", 
				"shop2SupplierRef")
	SELECT nextval('"SupplierReturnAddressDO_id_seq"'), 
			 'inTRONICS Return Center c/o Intershop Communications, Inc.' , 
			 '25 Lusk Street', 
			 'San Francisco, CA 94107, United States', 
			 'Phone.: +1 123 456-0000', 
			 'Fax: +1 123 456-0099',
			 supplier_returntype_id,  
			 shop_supplier_id
	FROM alist
	WHERE (supplier_returntype_id,  shop_supplier_id) NOT IN (select "supplier2ReturnTypeDefRef", "shop2SupplierRef" from  "SupplierReturnAddressDO");



-- Return reductions  (based on entries in Shop2SupplierDO)
-- upsert_shop2supplier2reducereason("shopReduceReason", "supplierReduceReason", "shop2SupplierRef","isDefault") returns id
	WITH alist ( prct, reduce_reason_ref) AS
	(	
	   SELECT 
	   	100.0 as prct,
			upsert_shop2supplier2reducereason('AK-100', 'default', id, true) as reduce_reason_ref
	   FROM "Shop2SupplierDO"
	   WHERE "shopRef"= ANY(shops_all) AND "supplierRef"=ANY(suppliers_all)
	   UNION ALL
	   SELECT 
			0.0, 
			upsert_shop2supplier2reducereason('AK-0', 'AK-0', id, false) 
 		FROM "Shop2SupplierDO"
 		WHERE "shopRef"= ANY(shops_all) AND "supplierRef"=ANY(suppliers_all)
 	)
	INSERT INTO oms."ReductionValueDO"(
				id, "reductionInPercent", "validFrom", "validUntil", "shop2Supplier2ReduceReasonRef")
	SELECT nextval('oms."ReductionValueDO_id_seq"'), prct, '2000-01-01 00:00:00', '2999-01-01 00:00:00', reduce_reason_ref
	FROM alist
	WHERE reduce_reason_ref NOT IN (select "shop2Supplier2ReduceReasonRef" from  "ReductionValueDO");


-- Enable the creation of return-related documents

-- add_document_transformer_config(p_documentformatdefref, p_documentmapperdefref, p_documenttypedefref, p_shopref, p_transformerframeworkdefref, p_save) 

-- return slip
perform admin.add_document_transformer_config(1, 2, 7, shopRef, 2, true); 
	
-- return label and documentMapperDefRef=1
-- requires BarCodeGenDO
perform admin.add_document_transformer_config(1, 1, 1, shopRef, 2, true); 



END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;