DO $$
BEGIN

	-- Function: oms.create_or_update_payment(boolean, integer, character varying, bigint, bigint, smallint)

	-- DROP FUNCTION oms.create_or_update_payment(boolean, integer, character varying, bigint, bigint, smallint);

	CREATE OR REPLACE FUNCTION oms.create_or_update_payment(
		p_active boolean,
	    p_paymentdefref integer,
	    p_shoppaymentname character varying,
	    p_shopref bigint,
	    p_paymentproviderref bigint,
	    p_payment2processstagedefref smallint)
	  RETURNS void AS
	$BODY$BEGIN

				INSERT INTO oms."Shop2PaymentDefDO"
					("id", "active", "initOrderStateDefRef", "paymentDefRef", "shopPaymentName", "shopRef",
					"safePayment", "payment2ProcessStageDefRef", "useAutomaticAuthorizationExtension",
					"authizationDurationInDays", "timeForPaymentAllowed")

				    SELECT 	nextval('oms."Shop2PaymentDefDO_id_seq"'), p_active, 2001, p_paymentdefref, p_shoppaymentname, p_shopref,
				    		FALSE, p_payment2ProcessStageDefRef, FALSE,
				    		NULL, NULL
				    ON CONFLICT ("paymentDefRef", "shopRef") DO UPDATE SET
				    		active = EXCLUDED.active, "shopPaymentName" = EXCLUDED."shopPaymentName",
				    		"payment2ProcessStageDefRef" = EXCLUDED."payment2ProcessStageDefRef"
				    		;

				IF p_paymentproviderref IS NULL THEN
					DELETE FROM oms."Shop2PaymentProvider2PaymentDefDO"
						WHERE "shopRef" = p_shopref AND "paymentDefRef" = p_paymentdefref;
				ELSE
					INSERT INTO oms."Shop2PaymentProvider2PaymentDefDO"(id, "shopRef", "paymentProviderRef", "paymentDefRef")
					    SELECT nextval('oms."Shop2PaymentProvider2PaymentDefDO_id_seq"'), p_shopref, p_paymentproviderref, p_paymentdefref
					    ON CONFLICT("shopRef", "paymentDefRef") DO UPDATE SET "paymentProviderRef" = EXCLUDED."paymentProviderRef";
				END IF;


	            END;
	            $BODY$
	  LANGUAGE plpgsql VOLATILE
	  COST 100;


END;
$$;