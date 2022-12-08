SET client_min_messages=error;
#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier

-- PAUSE velocity parser
#[[
-- local variables go here

-- end variables block with 
BEGIN

IF NOT EXISTS(SELECT null from oms."OrganizationDO" where "name" = 'inSPIRED') THEN
	PERFORM admin.createdomain
	(
	    'OmsSystem',		--parent_org_name varchar,
	    'inSPIRED',    		--name            varchar,
	    'inSPIRED Organization'	--description     varchar
	);
END IF;

END;
]]#
-- dollar quoting
$do;
