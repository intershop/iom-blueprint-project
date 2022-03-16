SET client_min_messages=error;
#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier

-- PAUSE velocity parser
#[[
-- local variables go here
shopId int8;
-- end variables block with 
BEGIN



     -- ORDER APPROVAL
    FOREACH shopId IN ARRAY shops_all LOOP
    
        -- payment method is cash on delivery
		INSERT INTO oms."Shop2Supplier2ApprovalTypeDefDO"
            (
				id, active, "isAffectingDOSEonChange", "approvalRank", "approvalTypeDefRef",
				"isOrderTransmission", "supplierApprovalTypeName", "shopRef", "supplierRef", "paymentProviderRef",
                "decisionBeanDefRef", "sendOrderApproval", "manualApproval", "supplierApprovalTypeDescription"
			)
			SELECT nextval('"Shop2Supplier2ApprovalTypeDefDO_id_seq"'), true, false, 1, 10000 /* custom type */,
                false, 'Cash on delivery approval', shopId, supplier_int, null,
                10000 /* custom decision */, false, true, 'Cash on delivery approval'
			WHERE NOT EXISTS (SELECT NULL FROM "Shop2Supplier2ApprovalTypeDefDO"
				WHERE "shopRef" = shopId AND "approvalTypeDefRef" = 10000 AND "supplierRef" = supplier_int AND "decisionBeanDefRef" = 10000);

        -- order gross total > 1000 USD
        INSERT INTO oms."Shop2Supplier2ApprovalTypeDefDO"
            (
				id, active, "isAffectingDOSEonChange", "approvalRank", "approvalTypeDefRef",
				"isOrderTransmission", "supplierApprovalTypeName", "shopRef", "supplierRef", "paymentProviderRef",
                "decisionBeanDefRef", "sendOrderApproval", "manualApproval", "supplierApprovalTypeDescription"
			)
			SELECT nextval('"Shop2Supplier2ApprovalTypeDefDO_id_seq"'), true, false, 1, 3 /* general type */,
                false, 'Order value approval', shopId, supplier_int, null,
                10001 /* custom decision */, false, true, 'Order value approval'
			WHERE NOT EXISTS (SELECT NULL FROM "Shop2Supplier2ApprovalTypeDefDO"
				WHERE "shopRef" = shopId AND "approvalTypeDefRef" = 3 AND "supplierRef" = supplier_int AND "decisionBeanDefRef" = 10001);

	END LOOP;



    -- RMA APPROVAL
    -- Manual approval of return requests
	FOREACH shopId IN ARRAY shops_all LOOP
	
		IF 0 = (SELECT count(id) FROM "Shop2Supplier2ApprovalTypeDefDO"
						WHERE "shopRef" = shopId AND "supplierRef" IS NULL AND "approvalTypeDefRef" = 6) THEN
				
			INSERT INTO oms."Shop2Supplier2ApprovalTypeDefDO"
				(
			        id,
					"active",
					"approvalTypeDefRef",
					"supplierApprovalTypeName",
					"shopRef",
					"supplierRef", -- NULL, for all suppliers
					"supplierApprovalTypeDescription"
				)
			    SELECT 
				
					nextval('"Shop2Supplier2ApprovalTypeDefDO_id_seq"'),
					TRUE,
					6,      -- return-request approval
					'Approval for return-requests',
					shopId,
					NULL,   -- NULL, for all suppliers
					'Return requests should be approved'
					;
				
		END IF;
			
	END LOOP;



END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;
