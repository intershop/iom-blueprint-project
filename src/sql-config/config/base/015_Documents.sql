#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier

-- PAUSE velocity parser
#[[

-- local variables go here
shopref bigint;

-- end variables block with 
BEGIN

FOREACH shopref IN ARRAY shops_all
LOOP

    -- delivery note
	perform admin.add_document_transformer_config(1, 2, 6, shopRef, 2, true);
	
	-- return slip
	perform admin.add_document_transformer_config(1, 2, 7, shopRef, 2, true);
	
	-- returnLabel and documentMapperDefRef=1
	-- requires BarCodeGenDO
	perform admin.add_document_transformer_config(1, 1, 1, shopRef, 2, true);


END LOOP;



END;
]]#
-- dollar quoting
$do;