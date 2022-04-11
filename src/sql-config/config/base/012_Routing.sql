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
    
    	/* rule: 6=delivery due date, 7=supports cash on delivery, 10000=has stock to deliver */
    	FOR rec in 
    		select 6 as rule, true as cancel    union all
    		select 7        , true				union all
			select 10000	, true
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

END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;
