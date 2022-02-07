#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier
$vars_country_codes
$vars_payment_methods

-- PAUSE velocity parser
#[[
-- local variables go here
shopref int8;
-- end variables block with 
BEGIN
	
-- payment provider blueprint
INSERT INTO oms."PaymentProviderDO" SELECT pp_blueprint, CURRENT_TIMESTAMP, 'blueprint', true, false
    WHERE NOT EXISTS -- for idempotent SQL insertion
        (
            SELECT NULL from oms."PaymentProviderDO" where id = pp_blueprint
        );
INSERT INTO oms."PartnerReferrerDO"(id, "paymentProviderRef") SELECT nextval('"PartnerReferrerDO_id_seq"'), pp_blueprint
    WHERE NOT EXISTS -- for idempotent SQL insertion
        (
            SELECT NULL from oms."PartnerReferrerDO" where "paymentProviderRef" = pp_blueprint
        );
        
-- payment methods
FOREACH shopref IN ARRAY shops_all
LOOP
	-- active, payment method, name in shop, shop id, provider id, process stage
	PERFORM create_or_update_payment(true, pm_no_payment, 'NO_PAYMENT', shopref, pp_blueprint, 1::smallint);
	PERFORM create_or_update_payment(true, pm_cash_in_advance, 'ISH_CASH_IN_ADVANCE', shopref, pp_blueprint, 1::smallint);
	PERFORM create_or_update_payment(true, pm_creditcard, 'ISH_CREDITCARD', shopref, pp_blueprint, 5::smallint);
	PERFORM create_or_update_payment(true, pm_cash_on_delivery, 'ISH_CASH_ON_DELIVERY', shopref, pp_blueprint, 7::smallint);
	PERFORM create_or_update_payment(true, pm_invoice, 'ISH_INVOICE', shopref, pp_blueprint, 5::smallint);
	PERFORM create_or_update_payment(true, pm_directdebit, 'ISH_DEBIT_TRANSFER', shopref, pp_blueprint, 5::smallint);
	PERFORM create_or_update_payment(true, pm_paypal, 'ISH_ONLINEPAY', shopref, pp_blueprint, 1::smallint);
	PERFORM create_or_update_payment(true, pm_fastpay, 'ISH_FASTPAY', shopref, pp_blueprint, 1::smallint);
	PERFORM create_or_update_payment(true, pm_refund, 'BPS_MANUAL_REFUND', shopref, pp_blueprint, null);
	PERFORM create_or_update_payment(true, pm_total_zero, 'ISH_INVOICE_TOTAL_ZERO', shopref, pp_blueprint, 1::smallint);
	--PERFORM create_or_update_payment(true, pm_apple_pay, 'APPLE_PAY', shopref, pp_blueprint, 5::smallint);
END LOOP; 

--EventRegistryEntryDO
FOREACH shopref IN ARRAY shops_all
LOOP
	--CloseInvoicingQueue
	INSERT INTO "EventRegistryEntryDO" ("id", "creationDate", "modificationDate", "processesRef", "version", "eventDefRef", "shopRef", "description")
	    SELECT nextval('"EventRegistryEntryDO_id_seq"'), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
	        (SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseInvoicingQueue')),
	        1, 2, shopref, 'Payment Events on CloseInvoicingQueue'
	    WHERE 1 NOT IN (
	        SELECT 1 FROM "EventRegistryEntryDO"
	        WHERE "processesRef"= (
	            SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (
	                SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseInvoicingQueue')
	        )
	        AND "eventDefRef" = 2 AND "shopRef" = shopref
	    );

	--CloseReturnQueue
	INSERT INTO "EventRegistryEntryDO" ("id", "creationDate", "modificationDate", "processesRef", "version", "eventDefRef", "shopRef", "description")
	    SELECT nextval('"EventRegistryEntryDO_id_seq"'), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
	        (SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseReturnQueue')),
	        1, 2, shopref, 'Payment Events on CloseReturnQueue'
	    WHERE 1 NOT IN (
	        SELECT 1 FROM "EventRegistryEntryDO"
	        WHERE "processesRef"= (
	            SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (
	                SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseReturnQueue')
	        )
	        AND "eventDefRef" = 2 AND "shopRef" = shopref
	    );

	--CheckOrderQueue
	INSERT INTO "EventRegistryEntryDO" ("id", "creationDate", "modificationDate", "processesRef", "version", "eventDefRef", "shopRef", "description")
	    SELECT nextval('"EventRegistryEntryDO_id_seq"'), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
	        (SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CheckOrderQueue')),
	        1, 2, shopref, 'Payment Events on CheckOrderQueue'
	    WHERE 1 NOT IN (
	        SELECT 1 FROM "EventRegistryEntryDO"
	        WHERE "processesRef"= (
	            SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (
	                SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CheckOrderQueue')
	        )
	        AND "eventDefRef" = 2 AND "shopRef" = shopref
	    );
END LOOP; --end of loop over shops

--PaymentEventRegistryEntryDO to create payment notifications (paymentEventDefRef = 10)
FOREACH shopref IN ARRAY shops_all
LOOP
	-- Credit Card AUTHORIZE
	INSERT INTO "PaymentEventRegistryEntryDO"(
	            id, version, "creationDate", "modificationDate", active, "eventRegistryEntryRef",
	            "paymentDefRef", "paymentNotificationActionDefRef", "paymentEventDefRef",
	            "decisionBeanDefRef")
	    SELECT  nextval('"PaymentEventRegistryEntryDO_id_seq"'),0, CURRENT_TIMESTAMP ,CURRENT_TIMESTAMP, true, (SELECT id from "EventRegistryEntryDO"
				where "processesRef"= (select id from "ProcessesDO" where "processDefRef" = (select id from "ProcessDefDO" where "queueName" = 'CheckOrderQueue'))
				and "eventDefRef"=2 and "shopRef"=shopref),
	            pm_creditcard, 1, 10,
	            null
		WHERE 1 NOT IN
			(
			SELECT 1 FROM "PaymentEventRegistryEntryDO" WHERE  "eventRegistryEntryRef" = (SELECT id from "EventRegistryEntryDO"
				where "processesRef"= (select id from "ProcessesDO" where "processDefRef" = (select id from "ProcessDefDO" where "queueName" = 'CheckOrderQueue'))
				and "eventDefRef"=2 and "shopRef"=shopref)
	            and "paymentDefRef" = pm_creditcard and "paymentNotificationActionDefRef" = 1
			);
					
	-- Credit Card REVERSE
	INSERT INTO "PaymentEventRegistryEntryDO"(
		    id, version, "creationDate", "modificationDate", active, "eventRegistryEntryRef", "paymentDefRef",
		    "paymentNotificationActionDefRef", "paymentEventDefRef", "decisionBeanDefRef")
		    SELECT nextval('"PaymentEventRegistryEntryDO_id_seq"'), 0, CURRENT_TIMESTAMP ,CURRENT_TIMESTAMP, true, (
		        SELECT id FROM "EventRegistryEntryDO"
		        WHERE "processesRef"= (
		            SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (
		                SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseReturnQueue')
		        )
		        AND "eventDefRef" = 2 AND "shopRef" = shopref
		    ), pm_creditcard, 2, 10, db_payment_action
		WHERE 1 NOT IN (
		    SELECT 1 FROM "PaymentEventRegistryEntryDO" WHERE "eventRegistryEntryRef" = (
		        SELECT id FROM "EventRegistryEntryDO"
		        WHERE "processesRef"= (
		            SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (
		                SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseReturnQueue'
		            )
		        )
		        AND "eventDefRef" = 2 AND "shopRef"=shopref
		    )
		    AND "paymentDefRef" = pm_creditcard AND "paymentNotificationActionDefRef" = 2
		);
	
	-- Credit Card REFUND
	INSERT INTO "PaymentEventRegistryEntryDO"(
	        id, version, "creationDate", "modificationDate", active, "eventRegistryEntryRef", "paymentDefRef",
	        "paymentNotificationActionDefRef", "paymentEventDefRef", "decisionBeanDefRef")
	        SELECT nextval('"PaymentEventRegistryEntryDO_id_seq"'), 0, CURRENT_TIMESTAMP ,CURRENT_TIMESTAMP, true, (
	            SELECT id FROM "EventRegistryEntryDO"
	            WHERE "processesRef"= (
	                SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (
	                    SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseInvoicingQueue')
	            )
	            AND "eventDefRef" = 2 AND "shopRef" = shopref
	        ), pm_creditcard, 4, 10, db_payment_action
	    WHERE 1 NOT IN (
	        SELECT 1 FROM "PaymentEventRegistryEntryDO" WHERE "eventRegistryEntryRef" = (
	            SELECT id FROM "EventRegistryEntryDO"
	            WHERE "processesRef"= (
	                SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (
	                    SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseInvoicingQueue'
	                )
	            )
	            AND "eventDefRef" = 2 AND "shopRef"=shopref
	        )
	        AND "paymentDefRef" = pm_creditcard AND "paymentNotificationActionDefRef" = 4
	    );
	
	-- Credit Card CAPTURE
	INSERT INTO "PaymentEventRegistryEntryDO"(
	        id, version, "creationDate", "modificationDate", active, "eventRegistryEntryRef", "paymentDefRef",
	        "paymentNotificationActionDefRef", "paymentEventDefRef", "decisionBeanDefRef")
	        SELECT nextval('"PaymentEventRegistryEntryDO_id_seq"'), 0, CURRENT_TIMESTAMP ,CURRENT_TIMESTAMP, true, (
	            SELECT id FROM "EventRegistryEntryDO"
	            WHERE "processesRef"= (
	                SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (
	                    SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseInvoicingQueue')
	            )
	            AND "eventDefRef" = 2 AND "shopRef" = shopref
	        ), pm_creditcard, 3, 10, db_payment_action
	    WHERE 1 NOT IN (
	        SELECT 1 FROM "PaymentEventRegistryEntryDO" WHERE "eventRegistryEntryRef" = (
	            SELECT id FROM "EventRegistryEntryDO"
	            WHERE "processesRef"= (
	                SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (
	                    SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseInvoicingQueue'
	                )
	            )
	            AND "eventDefRef" = 2 AND "shopRef"=shopref
	        )
	        AND "paymentDefRef" = pm_creditcard AND "paymentNotificationActionDefRef" = 3
	    );
	    
	-- Paypal REFUND
		INSERT INTO "PaymentEventRegistryEntryDO"(
	        id, version, "creationDate", "modificationDate", active, "eventRegistryEntryRef", "paymentDefRef",
	        "paymentNotificationActionDefRef", "paymentEventDefRef", "decisionBeanDefRef")
	        SELECT nextval('"PaymentEventRegistryEntryDO_id_seq"'), 0, CURRENT_TIMESTAMP ,CURRENT_TIMESTAMP, true, (
	            SELECT id FROM "EventRegistryEntryDO"
	            WHERE "processesRef"= (
	                SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (
	                    SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseInvoicingQueue')
	            )
	            AND "eventDefRef" = 2 AND "shopRef" = shopref
	        ), pm_paypal, 4, 10, db_payment_action
	    WHERE 1 NOT IN (
	        SELECT 1 FROM "PaymentEventRegistryEntryDO" WHERE "eventRegistryEntryRef" = (
	            SELECT id FROM "EventRegistryEntryDO"
	            WHERE "processesRef"= (
	                SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (
	                    SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseInvoicingQueue'
	                )
	            )
	            AND "eventDefRef" = 2 AND "shopRef"=shopref
	        )
	        AND "paymentDefRef" = pm_paypal AND "paymentNotificationActionDefRef" = 4
	    );
	
	-- Paypal CAPTURE
	INSERT INTO "PaymentEventRegistryEntryDO"(
	        id, version, "creationDate", "modificationDate", active, "eventRegistryEntryRef", "paymentDefRef",
	        "paymentNotificationActionDefRef", "paymentEventDefRef", "decisionBeanDefRef")
	        SELECT nextval('"PaymentEventRegistryEntryDO_id_seq"'), 0, CURRENT_TIMESTAMP ,CURRENT_TIMESTAMP, true, (
	            SELECT id FROM "EventRegistryEntryDO"
	            WHERE "processesRef"= (
	                SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (
	                    SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseInvoicingQueue')
	            )
	            AND "eventDefRef" = 2 AND "shopRef" = shopref
	        ), pm_paypal, 3, 10, db_payment_action
	    WHERE 1 NOT IN (
	        SELECT 1 FROM "PaymentEventRegistryEntryDO" WHERE "eventRegistryEntryRef" = (
	            SELECT id FROM "EventRegistryEntryDO"
	            WHERE "processesRef"= (
	                SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (
	                    SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseInvoicingQueue'
	                )
	            )
	            AND "eventDefRef" = 2 AND "shopRef"=shopref
	        )
	        AND "paymentDefRef" = pm_paypal AND "paymentNotificationActionDefRef" = 3
	    );

END LOOP; --end of loop over shops

--PaymentActionApprovalDefDO
FOREACH shopref IN ARRAY shops_all
LOOP
	-- Credit Card AUTHORIZE 
	INSERT INTO oms."PaymentActionApprovalDefDO"(
        id, "doProcess", "doManualApprove", "paymentNotificationActionDefRef",
        "shop2PaymentProvider2PaymentRef")
    SELECT nextval('"PaymentActionApprovalDefDO_id_seq"'), false, false, 1,
            (select id from "Shop2PaymentProvider2PaymentDefDO" where "shopRef" = shopref and "paymentDefRef" = pm_creditcard
             and "paymentProviderRef" = pp_blueprint)
    WHERE 1 NOT IN
    	(
    		SELECT 1 FROM "PaymentActionApprovalDefDO" WHERE "paymentNotificationActionDefRef" = 1
    		AND "shop2PaymentProvider2PaymentRef" =(select id from "Shop2PaymentProvider2PaymentDefDO" where "shopRef" = shopref and "paymentDefRef" = pm_creditcard
            	and "paymentProviderRef" = pp_blueprint)
    	);
	
	-- Credit Card REVERSE
	INSERT INTO oms."PaymentActionApprovalDefDO"(
        id, "doProcess", "doManualApprove", "paymentNotificationActionDefRef",
        "shop2PaymentProvider2PaymentRef")
    SELECT nextval('"PaymentActionApprovalDefDO_id_seq"'), true, false, 2,
            (select id from "Shop2PaymentProvider2PaymentDefDO" where "shopRef" = shopref and "paymentDefRef" = pm_creditcard
             and "paymentProviderRef" = pp_blueprint)
    WHERE 1 NOT IN
    	(
    		SELECT 1 FROM "PaymentActionApprovalDefDO" WHERE "paymentNotificationActionDefRef" = 2
    		AND "shop2PaymentProvider2PaymentRef" =(select id from "Shop2PaymentProvider2PaymentDefDO" where "shopRef" = shopref and "paymentDefRef" = pm_creditcard
            	and "paymentProviderRef" = pp_blueprint)
    	);
	
	-- Credit Card CAPTURE
	INSERT INTO oms."PaymentActionApprovalDefDO"(
        id, "doProcess", "doManualApprove", "paymentNotificationActionDefRef",
        "shop2PaymentProvider2PaymentRef")
    SELECT nextval('"PaymentActionApprovalDefDO_id_seq"'), true, false, 3,
            (select id from "Shop2PaymentProvider2PaymentDefDO" where "shopRef" = shopref and "paymentDefRef" = pm_creditcard
             and "paymentProviderRef" = pp_blueprint)
    WHERE 1 NOT IN
    	(
    		SELECT 1 FROM "PaymentActionApprovalDefDO" WHERE "paymentNotificationActionDefRef" = 3
    		AND "shop2PaymentProvider2PaymentRef" =(select id from "Shop2PaymentProvider2PaymentDefDO" where "shopRef" = shopref and "paymentDefRef" = pm_creditcard
            	and "paymentProviderRef" = pp_blueprint)
    	);
	
	-- Credit Card REFUND
	INSERT INTO oms."PaymentActionApprovalDefDO"(
        id, "doProcess", "doManualApprove", "paymentNotificationActionDefRef",
        "shop2PaymentProvider2PaymentRef")
    SELECT nextval('"PaymentActionApprovalDefDO_id_seq"'), true, false, 4,
            (select id from "Shop2PaymentProvider2PaymentDefDO" where "shopRef" = shopref and "paymentDefRef" = pm_creditcard
             and "paymentProviderRef" = pp_blueprint)
    WHERE 1 NOT IN
    	(
    		SELECT 1 FROM "PaymentActionApprovalDefDO" WHERE "paymentNotificationActionDefRef" = 4
    		AND "shop2PaymentProvider2PaymentRef" =(select id from "Shop2PaymentProvider2PaymentDefDO" where "shopRef" = shopref and "paymentDefRef" = pm_creditcard
            	and "paymentProviderRef" = pp_blueprint)
    	);
	
	--Paypal CAPTURE
	INSERT INTO oms."PaymentActionApprovalDefDO"(
        id, "doProcess", "doManualApprove", "paymentNotificationActionDefRef",
        "shop2PaymentProvider2PaymentRef")
    SELECT nextval('"PaymentActionApprovalDefDO_id_seq"'), false, false, 3,
            (select id from "Shop2PaymentProvider2PaymentDefDO" where "shopRef" = shopref and "paymentDefRef" = pm_paypal
             and "paymentProviderRef" = pp_blueprint)
    WHERE 1 NOT IN
    	(
    		SELECT 1 FROM "PaymentActionApprovalDefDO" WHERE "paymentNotificationActionDefRef" = 3
    		AND "shop2PaymentProvider2PaymentRef" =(select id from "Shop2PaymentProvider2PaymentDefDO" where "shopRef" = shopref and "paymentDefRef" = pm_paypal
            	and "paymentProviderRef" = pp_blueprint)
    	);
	
	--Paypal REFUND
	INSERT INTO oms."PaymentActionApprovalDefDO"(
        id, "doProcess", "doManualApprove", "paymentNotificationActionDefRef",
        "shop2PaymentProvider2PaymentRef")
    SELECT nextval('"PaymentActionApprovalDefDO_id_seq"'), false, false, 4,
            (select id from "Shop2PaymentProvider2PaymentDefDO" where "shopRef" = shopref and "paymentDefRef" = pm_paypal
             and "paymentProviderRef" = pp_blueprint)
    WHERE 1 NOT IN
    	(
    		SELECT 1 FROM "PaymentActionApprovalDefDO" WHERE "paymentNotificationActionDefRef" = 4
    		AND "shop2PaymentProvider2PaymentRef" =(select id from "Shop2PaymentProvider2PaymentDefDO" where "shopRef" = shopref and "paymentDefRef" = pm_paypal
            	and "paymentProviderRef" = pp_blueprint)
    	);

END LOOP; --end of loop over shops

END;
]]#
-- dollar quoting
$do;
