SET client_min_messages=error;
#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier

-- PAUSE velocity parser
#[[
-- local variables go here
shopref int8;
rec record;
-- end variables block with
BEGIN

	-- Shop2OrderValidationRuleDefDO
	FOREACH shopref in array shops_all LOOP

		FOR rec IN (
			select 4  as rule_id,   FALSE as synchron	union all 
			select 5,           	FALSE          		union all 
			select 6,           	TRUE           		union all
			select 11,          	FALSE          		union all 
			select 13,          	TRUE           		union all 
			select 10000,       	TRUE           		-- custom rule syncrounous
			)
		LOOP
	
		INSERT into "Shop2OrderValidationRuleDefDO"("id", "orderValidationRuleDefRef", "runSynchron", "shopRef")
			SELECT nextval('"Shop2OrderValidationRuleDefDO_id_seq"'), 
				rec.rule_id, 
				rec.synchron, 
				shopref
			WHERE NOT EXISTS (select * from  "Shop2OrderValidationRuleDefDO" where "shopRef"=shopref and "orderValidationRuleDefRef" = rec.rule_id );
	
		END LOOP;
		
	END LOOP;

END;
]]#
-- dollar quoting
$do;