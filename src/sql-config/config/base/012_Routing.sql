SET client_min_messages=error;
#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier

-- PAUSE velocity parser
#[[
-- local variables go here
rec record;
shopId int8;
B2CRoutingRuleId int8 = 10000;
-- end variables block with 
BEGIN

--ORDER ROUTING
FOREACH shopId IN ARRAY shops_all LOOP
    
    	/* rule: 6=delivery due date, 7=supports cash on delivery, 10000=only one supplier per order if B2C */
    	FOR rec in 
    		select 6 as rule, true as cancel    union all
    		select 7        , true
    	LOOP
    	
			IF NOT EXISTS ( select * FROM "Shop2OrderSupplierEvaluationRuleDefDO"
								 where "shopRef" = shopId 
								 and "orderSupplierEvaluationRuleDefRef" = rec.rule )
                THEN

				INSERT INTO oms."Shop2OrderSupplierEvaluationRuleDefDO"
							(
								id,
                                "shopRef",
					            "orderSupplierEvaluationRuleDefRef",
					            "errorForcesAutomaticCancelation"
							)
							SELECT
                                nextval('"Shop2OrderSupplierEvaluationRuleDefDO_id_seq"'), 
                                shopId,
                                rec.rule,
                                rec.cancel;

			END IF;

		END LOOP;

	END LOOP;

    --custom rule for B2C only
    /*
    IF NOT EXISTS ( select * FROM "Shop2OrderSupplierEvaluationRuleDefDO"
					where "shopRef" = shop_intronics_b2c 
					and "orderSupplierEvaluationRuleDefRef" = B2CRoutingRuleId )
    THEN

		INSERT INTO oms."Shop2OrderSupplierEvaluationRuleDefDO"
		(
			id,
            "shopRef",
	        "orderSupplierEvaluationRuleDefRef",
			"errorForcesAutomaticCancelation"
		)
		SELECT
            nextval('"Shop2OrderSupplierEvaluationRuleDefDO_id_seq"'), 
            shop_intronics_b2c,
            B2CRoutingRuleId,
            true;

    END IF;
    */

END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;
