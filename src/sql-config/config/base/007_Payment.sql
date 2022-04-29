#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier
$vars_country_codes
$vars_payment_methods

-- PAUSE velocity parser
#[[
-- local variables go here
shopref int8;

procId_CheckOrderQueue int8;
procId_CloseInvoicingQueue int8;
procId_CloseReturnQueue int8;
rec record;
EventRegistryEntry_id  int8;
Shop2PaymentProvider2Payment_id int8;

-- end variables block with 
BEGIN

	procId_CheckOrderQueue =	 (select id from "ProcessesDO" where "processDefRef" = (select id from "ProcessDefDO" where "queueName" = 'CheckOrderQueue'));
	procId_CloseInvoicingQueue =(select id from "ProcessesDO" where "processDefRef" = (select id from "ProcessDefDO" where "queueName" = 'CloseInvoicingQueue'));
	procId_CloseReturnQueue =	 (select id from "ProcessesDO" where "processDefRef" = (select id from "ProcessDefDO" where "queueName" = 'CloseReturnQueue'));

	-- payment provider blueprint
	INSERT INTO oms."PaymentProviderDO" (id, "modificationDate", name, "partlyCaptureAllowed", "partlyReverseAllowed")
		 SELECT pp_blueprint, CURRENT_TIMESTAMP, 'blueprint', true, false
		 WHERE NOT EXISTS -- for idempotent SQL insertion
			  (
					SELECT * from oms."PaymentProviderDO" where id = pp_blueprint
			  );

	INSERT INTO oms."PartnerReferrerDO"(id, "paymentProviderRef") 
		 SELECT nextval('"PartnerReferrerDO_id_seq"'), pp_blueprint
		 WHERE NOT EXISTS -- for idempotent SQL insertion
			  (
					SELECT * from oms."PartnerReferrerDO" where "paymentProviderRef" = pp_blueprint
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
			 SELECT nextval('"EventRegistryEntryDO_id_seq"'), 
					  CURRENT_TIMESTAMP, 
					  CURRENT_TIMESTAMP,
					  procId_CloseInvoicingQueue,
					  1, 
					  2, 
					  shopref, 
					  'Payment Events on CloseInvoicingQueue'
			 WHERE NOT EXISTS (
				  SELECT * FROM "EventRegistryEntryDO"
				  WHERE "processesRef"= procId_CloseInvoicingQueue
				  AND "eventDefRef" = 2 AND "shopRef" = shopref
			 );

		--CloseReturnQueue
		INSERT INTO "EventRegistryEntryDO" ("id", "creationDate", "modificationDate", "processesRef", "version", "eventDefRef", "shopRef", "description")
			 SELECT nextval('"EventRegistryEntryDO_id_seq"'), 
					  CURRENT_TIMESTAMP, 
					  CURRENT_TIMESTAMP,
					  procId_CloseReturnQueue,
					  1, 
					  2, 
					  shopref, 
					  'Payment Events on CloseReturnQueue'
			 WHERE NOT EXISTS (
				  SELECT * FROM "EventRegistryEntryDO"
				  WHERE "processesRef"= procId_CloseReturnQueue
				  AND "eventDefRef" = 2 AND "shopRef" = shopref
			 );

		--CheckOrderQueue
		INSERT INTO "EventRegistryEntryDO" ("id", "creationDate", "modificationDate", "processesRef", "version", "eventDefRef", "shopRef", "description")
			 SELECT nextval('"EventRegistryEntryDO_id_seq"'),
					  CURRENT_TIMESTAMP, 
					  CURRENT_TIMESTAMP,
					  procId_CheckOrderQueue,
					  1, 
					  2, 
					  shopref, 
					  'Payment Events on CheckOrderQueue'
			 WHERE NOT EXISTS (
				  SELECT * FROM "EventRegistryEntryDO"
				  WHERE "processesRef"=  procId_CheckOrderQueue
				  AND "eventDefRef" = 2 AND "shopRef" = shopref
			 );
	END LOOP; --end of loop over shops

	--PaymentEventRegistryEntryDO to create payment notifications (paymentEventDefRef = 10)
	FOREACH shopref IN ARRAY shops_all
	LOOP

		FOR rec IN
		(
		 -- Credit Card AUTHORIZE
		 select procId_CheckOrderQueue as process_id,  pm_creditcard as payDefRef, 1 as payNotifActionRef, null::int         as decBeanRef, false as doprocess UNION ALL
		 -- Credit Card REVERSE
		 select procId_CloseReturnQueue,               pm_creditcard,              2,                      db_payment_action,               true             UNION ALL     
		 -- Credit Card CAPTURE
		 select procId_CloseInvoicingQueue,            pm_creditcard,              3,                      db_payment_action,               true             UNION ALL     
		 -- Credit Card REFUND
		 select procId_CloseInvoicingQueue,            pm_creditcard,              4,                      db_payment_action,               true             UNION ALL     
		 -- Paypal CAPTURE
		 select procId_CloseInvoicingQueue,            pm_paypal,                  3,                      db_payment_action,               false            UNION ALL       
		 -- Paypal REFUND
		 select procId_CloseInvoicingQueue,            pm_paypal,                  4,                      db_payment_action,               false
		 )
		 LOOP
				EventRegistryEntry_id = (select id from "EventRegistryEntryDO"
												 where "processesRef"= rec.process_id
												 and "eventDefRef"=2  --PAYMENT_EVENT_MANAGER
												 and "shopRef"=shopref);

				INSERT INTO "PaymentEventRegistryEntryDO"(
								id, version, "creationDate", "modificationDate", active, 
								"eventRegistryEntryRef",
								"paymentDefRef", 
								"paymentNotificationActionDefRef",
								"paymentEventDefRef",
								"decisionBeanDefRef")
					 SELECT  nextval('"PaymentEventRegistryEntryDO_id_seq"'),0, CURRENT_TIMESTAMP ,CURRENT_TIMESTAMP, true, 
								EventRegistryEntry_id,
								rec.payDefRef,
								rec.payNotifActionRef,
								10, 
								rec.decBeanRef
					WHERE NOT EXISTS(
						select * FROM "PaymentEventRegistryEntryDO" 
						where "eventRegistryEntryRef" = EventRegistryEntry_id
						and   "paymentDefRef" = rec.payDefRef 
						and   "paymentNotificationActionDefRef" = rec.payNotifActionRef
						);

				Shop2PaymentProvider2Payment_id = (select id from "Shop2PaymentProvider2PaymentDefDO" 
															  where "shopRef" = shopref 
															  and "paymentDefRef" = rec.payDefRef
															  and "paymentProviderRef" = pp_blueprint);

				INSERT INTO oms."PaymentActionApprovalDefDO"(
					  id, 
					  "doProcess", 
					  "doManualApprove", 
					  "paymentNotificationActionDefRef",
					  "shop2PaymentProvider2PaymentRef"
					  )
				 SELECT nextval('"PaymentActionApprovalDefDO_id_seq"'), 
							rec.doprocess, 
							false, 
							rec.payNotifActionRef,
							Shop2PaymentProvider2Payment_id
				 WHERE NOT EXISTS
					(
						select * FROM "PaymentActionApprovalDefDO" 
						where "paymentNotificationActionDefRef" = rec.payNotifActionRef
						AND "shop2PaymentProvider2PaymentRef" =Shop2PaymentProvider2Payment_id
					);

		 END LOOP;

	END LOOP; --end of loop over shops

END;
]]#
-- dollar quoting
$do;
