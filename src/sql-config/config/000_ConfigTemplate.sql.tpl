#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier

-- PAUSE velocity parser
#[[

-- local variables go here

-- end variables block with 
BEGIN



END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;