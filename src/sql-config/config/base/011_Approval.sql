SET client_min_messages=error;
#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier

-- PAUSE velocity parser
#[[
-- local variables go here
shopId int8;
rec record;
-- end variables block with
BEGIN



     -- ORDER APPROVAL
    FOREACH shopId IN ARRAY shops_all LOOP
    
    	/* approval_type: 10000=custom type, 3=general type
    	   decisionBean: 10000=COD_PAYMENT_DECISION_BEAN, 10001=MAX_ORDER_VALUE_DECISION_BEAN */
    	FOR rec in 
    		select 10000 as approval_type, 'Cash on delivery approval' as apr_name, 20000 as bean_ref   union all
    		select 3                     , 'Order value approval',                  20001
    	LOOP
    	
			IF NOT EXISTS ( select * FROM "Shop2Supplier2ApprovalTypeDefDO"
								 where "shopRef" = shopId 
								 and "approvalTypeDefRef" = rec.approval_type 
								 and "supplierRef" = supplier_int 
								 and "decisionBeanDefRef" = rec.bean_ref ) THEN	
				INSERT INTO oms."Shop2Supplier2ApprovalTypeDefDO"
							(
								id, 
								active, 
								"isAffectingDOSEonChange", 
								"approvalRank", 
								"approvalTypeDefRef",
								"isOrderTransmission", 
								"supplierApprovalTypeName", 
								"shopRef", "supplierRef", 
								"paymentProviderRef",
								"decisionBeanDefRef", 
								"sendOrderApproval", 
								"manualApproval", 
								"supplierApprovalTypeDescription"
							)
							SELECT nextval('"Shop2Supplier2ApprovalTypeDefDO_id_seq"'), 
							true, 
							false,
							1, 
							rec.approval_type,
							false, 
							rec.apr_name, 
							shopId, 
							supplier_int, 
							null,
							rec.bean_ref, 
							false, 
							true, 
							rec.apr_name;

			END IF;

		END LOOP;

	END LOOP;



    -- RMA APPROVAL
	FOREACH shopId IN ARRAY shops_all LOOP
	
		IF NOT EXISTS (SELECT * FROM "Shop2Supplier2ApprovalTypeDefDO"
						  WHERE "shopRef" = shopId 
						  AND "supplierRef" IS NULL 
						  AND "approvalTypeDefRef" = 6) THEN
				
			INSERT INTO oms."Shop2Supplier2ApprovalTypeDefDO"
				(
					id,
					active,
					"approvalTypeDefRef",
					"supplierApprovalTypeName",
					"shopRef",
					"supplierRef", -- NULL, for all suppliers
					"supplierApprovalTypeDescription",
					"decisionBeanDefRef"
				)
			SELECT 
					nextval('"Shop2Supplier2ApprovalTypeDefDO_id_seq"'),
					TRUE,
					6,      -- return-request approval
					'Approval for return-requests',
					shopId,
					NULL,   -- NULL, for all suppliers
					'Return requests should be approved',
					30000
					;
				
		END IF;
			
	END LOOP;


END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;