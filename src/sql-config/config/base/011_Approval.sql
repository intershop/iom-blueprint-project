SET client_min_messages=error;
DO $$
DECLARE

--see CountryDefDO for the ids






-- import global variables

-- internal
shop_int int8 = 1;
supplier_int int8 = 1;

-- parent shops


-- actual shops
shop_intronics_b2c int8 = 10010;
shop_intronics_b2b int8 = 10020;

-- all non-abstract shops
shops_all int8[] = ARRAY[shop_intronics_b2c, shop_intronics_b2b];

-- all abstract shops
shops_parent_all int8[] = ARRAY[]::int8[];

-- Supplier
supplier_wh_texas int8 = 20010;
supplier_wh_arizona int8 = 20020;
supplier_wh_losangeles int8 = 20030;
supplier_wh_detroit int8 = 20040;
supplier_retailer_losangeles int8 = 20050;

-- all suppliers
suppliers_all int8[] = ARRAY[supplier_wh_texas, supplier_wh_arizona, supplier_wh_losangeles, supplier_wh_detroit, supplier_retailer_losangeles];

-- payment provider
--pp_paypal int8 = 100;





-- PAUSE velocity parser

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

-- dollar quoting
$$;
