#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier
-- PAUSE velocity parser
#[[

-- local variables go here
shopref int8;
supplierref int8;
userref int8;

roleref int8;
rightref int8;

--shop
webservice_user_name varchar = 'webservice_shop'; --if you change the name, change cryptedPassword too
webservice_user_rights int8[] = ARRAY[1,2,123,124,125,126,131,137,139,140,141,142,143,144,145,146,147,148];

--supplier TODO
--supplier_webservice_user_name varchar = 'webservice_supplier'; --if you change the name, change cryptedPassword too
--supplier_webservice_user_rights int8[] = ARRAY[];

callcenter_agent_name varchar = 'callcenter_agent'; --if you change the name, change cryptedPassword too
callcenter_agent_rights int8[] = ARRAY[3,4,5,6,7,8,9,10,11,12,13,17,19,20,21,25,26,27,28,29,30,31,32,33,
									   34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,56,57,58,62,
									   63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,106,107,108,109,112,
									   113,114,115,116,117,118,119,120,121,132,133,135,136,138];
-- end variables block with 

BEGIN

	/* 
	 * This is only for demo purposes.
	 * You should create users and roles in the OMT.
	 */
	
	-- User webservice_user
	IF NOT EXISTS (SELECT NULL FROM oms."UserDO" WHERE "accountName" = webservice_user_name) THEN
		INSERT INTO "UserDO" (id,"accountName",active,"companyName", --1
			"firstName","languageDefRef","lastName","loginErrors", --2
			"modificationDate","uniformRoleConf","version", --3
			email,"cryptedPassword","hashSalt", --4
			"deletionTime",discriminator) --5 
		VALUES
			(nextval('"UserDO_id_seq"'),webservice_user_name,true,'company', --1
			'webservice',2,'shop',0, --2
			'2022-02-24 10:37:47.282',false,1, --3
			'','fEbjJo7gZ5sAMgZtPy2FjCQunYSuJ64Xh37hJNNG/j8=','hkP5gPPxgrmpRBH0mdvdGQ==', --4
			NULL,1); --5
	END IF;
	userref = (SELECT id FROM  "UserDO" WHERE "accountName" = webservice_user_name);
	
	-- Role webservices
	IF NOT EXISTS (SELECT NULL FROM oms."RoleDO" WHERE "name" = 'webservices') THEN
		INSERT INTO "RoleDO" (id,description,"name","version") VALUES
		 (nextval('"RoleDO_id_seq"'),'','webservices',0);
	END IF;
	roleref = (SELECT id FROM "RoleDO" WHERE "name" = 'webservices');
	
	-- Role2Rights for webservices role
	FOREACH rightref IN ARRAY webservice_user_rights LOOP
		INSERT INTO "Role2RightDO" ("id","rightDefRef","roleRef")
			SELECT nextval('"Role2RightDO_id_seq"'), rightref,roleref
			ON CONFLICT ("rightDefRef", "roleRef") DO NOTHING;
	END LOOP;
	
	--User2RoleDO: asssign user to role
	INSERT INTO "User2RoleDO" (id,"roleRef", "userRef") VALUES
	(nextval('"User2RoleDO_id_seq"'),roleRef,userref)
	ON CONFLICT ("roleRef", "userRef") DO NOTHING;
	
	-- assign user and role to organization
	INSERT INTO "User2OrganizationDO" (id,"organizationRef", "userRef") VALUES
		(nextval('"User2OrganizationDO_id_seq"'),1,userref)
		ON CONFLICT ("organizationRef", "userRef") DO NOTHING;
	
	INSERT INTO "User2Role2OrganizationDO" (id,"organizationRef", "roleRef", "userRef") VALUES
		(nextval('"User2Role2OrganizationDO_id_seq"'),1,roleref,userref)
		ON CONFLICT ("organizationRef", "roleRef", "userRef") DO NOTHING;
	
	----------------------------
	
	-- User callcenter_agent
	IF NOT EXISTS (SELECT NULL FROM oms."UserDO" WHERE "accountName" = callcenter_agent_name) THEN
		INSERT INTO "UserDO" (id,"accountName",active,"companyName", --1
			"firstName","languageDefRef","lastName","loginErrors", --2
			"modificationDate","uniformRoleConf","version", --3
			email,"cryptedPassword","hashSalt", --4
			"deletionTime",discriminator) --5 
		VALUES
			(nextval('"UserDO_id_seq"'),callcenter_agent_name,true,'company', --1
			'callcenter',2,'agent',0, --2
			'2022-02-24 10:37:47.282',false,1, --3
			'','Nqa1Yvs9r9Clp3qpLgoUMhrT/tfq1ZWDXQUvOK0x2/I=','AMDFaxpae/ipXgY7sho+kg==', --4
			NULL,1); --5
	END IF;
	userref = (SELECT id FROM  "UserDO" WHERE "accountName" = callcenter_agent_name);
	
	-- Role callcenter_agent
	IF NOT EXISTS (SELECT NULL FROM oms."RoleDO" WHERE "name" = 'callcenter_agent') THEN
		INSERT INTO "RoleDO" (id,description,"name","version") VALUES
		 (nextval('"RoleDO_id_seq"'),'','callcenter_agent',0);
	END IF;
	roleref = (SELECT id FROM "RoleDO" WHERE "name" = 'callcenter_agent');
	
	-- Role2Rights for callcenter_agent role
	FOREACH rightref IN ARRAY callcenter_agent_rights LOOP
		INSERT INTO "Role2RightDO" ("id","rightDefRef","roleRef")
			SELECT nextval('"Role2RightDO_id_seq"'), rightref,roleref
			ON CONFLICT ("rightDefRef", "roleRef") DO NOTHING;
	END LOOP;
	
	--User2RoleDO: asssign user to role
	INSERT INTO "User2RoleDO" (id,"roleRef", "userRef") VALUES
	(nextval('"User2RoleDO_id_seq"'),roleRef,userref)
	ON CONFLICT ("roleRef", "userRef") DO NOTHING;
	
	-- assign user and role to organization
	INSERT INTO "User2OrganizationDO" (id,"organizationRef", "userRef") VALUES
		(nextval('"User2OrganizationDO_id_seq"'),1,userref)
		ON CONFLICT ("organizationRef", "userRef") DO NOTHING;
	
	INSERT INTO "User2Role2OrganizationDO" (id,"organizationRef", "roleRef", "userRef") VALUES
		(nextval('"User2Role2OrganizationDO_id_seq"'),1,roleref,userref)
		ON CONFLICT ("organizationRef", "roleRef", "userRef") DO NOTHING;
		
END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;