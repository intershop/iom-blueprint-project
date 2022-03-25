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

-- user administartion
user_admin_rights int8[] = ARRAY [85,88,127,128,130];
user_admin_role_name text='user_administrator';
user_admin_user_name text='user_admin';

shop_service_user_name text = 'webservice_shop'; --if you change the name, change cryptedPassword too

--technical shop APIs
shop_service_role_name text = 'shop_services'; --if you change the name, change cryptedPassword too
shop_service_rights int8[] = ARRAY[1,2,67,123,124,125,126,131,137,139,140,141,142,143,144,145,146,147,148];

--technical supplier APIs
supplier_service_user_name text = 'webservice_supplier'; --if you change the name, change cryptedPassword too
supplier_service_role_name text = 'supplier_services'; 
                                     --returns,              ATP,   Dispatches
supplier_service_rights int8[] = ARRAY[131,139,140,141,142,  123,   10,11];

--technical supplier API

callcenter_role_name text = 'callcenter_agent';
callcenter_agent_name text = 'callcenter_agent'; --if you change the name, change cryptedPassword too
callcenter_agent_rights int8[] = ARRAY[3,4,5,6,7,8,9,10,11,12,13,17,19,20,21,25,26,27,28,29,30,31,32,33,
									   34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,56,57,58,62,
									   63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,107,108,109,112,
									   113,114,115,116,117,118,119,120,121,132,133,135,136,138];
-- end variables block with 

BEGIN

  -- make sure to have a late change from IOM 4.0.0 (temporary solution, can be removed after 4.0.0 release...)
  ALTER TABLE "UserDO" ALTER "uniformRoleConf" SET DEFAULT false;

  -- role for user administration
   
    INSERT INTO "RoleDO" (id, name, description, version)
	 SELECT nextval('"RoleDO_id_seq"'),
	 user_admin_role_name,
	 'define users and their permissions',
	 0
	 WHERE NOT EXISTS (select * from "RoleDO" where name= user_admin_role_name);
	 
	 INSERT  INTO "Role2RightDO" (id, "rightDefRef","roleRef")
	 SELECT nextval('"Role2RightDO_id_seq"'), uar, r_id 
	 FROM  unnest( user_admin_rights)uar  
	 CROSS JOIN  (select id as r_id from "RoleDO" where name=user_admin_role_name)r
	 ON CONFLICT ("rightDefRef","roleRef") DO NOTHING;

   -- role for shop services
   
    INSERT INTO "RoleDO" (id, name, description, version)
	 SELECT nextval('"RoleDO_id_seq"'),
	 shop_service_role_name,
	 'rights for shop APIs',
	 0
	 WHERE NOT EXISTS (select * from "RoleDO" where name= shop_service_role_name);
	 
	 INSERT  INTO "Role2RightDO" (id, "rightDefRef","roleRef")
	 SELECT nextval('"Role2RightDO_id_seq"'), uar, r_id 
	 FROM  unnest( shop_service_rights)uar  
	 CROSS JOIN  (select id as r_id from "RoleDO" where name=shop_service_role_name)r
	 ON CONFLICT ("rightDefRef","roleRef") DO NOTHING;

    -- role for supplier services
   
    INSERT INTO "RoleDO" (id, name, description, version)
	 SELECT nextval('"RoleDO_id_seq"'),
	 supplier_service_role_name,
	 'rights for supplier APIs',
	 0
	 WHERE NOT EXISTS (select * from "RoleDO" where name= supplier_service_role_name);
	 
	 INSERT  INTO "Role2RightDO" (id, "rightDefRef","roleRef")
	 SELECT nextval('"Role2RightDO_id_seq"'), uar, r_id 
	 FROM  unnest( supplier_service_rights)uar  
	 CROSS JOIN  (select id as r_id from "RoleDO" where name=supplier_service_role_name)r
	 ON CONFLICT ("rightDefRef","roleRef") DO NOTHING;

    -- role for call center
    
    INSERT INTO "RoleDO" (id, name, description, version)
 	 SELECT nextval('"RoleDO_id_seq"'),
 	 callcenter_role_name,
 	 'rights for call center agents',
 	 0
 	 WHERE NOT EXISTS (select * from "RoleDO" where name= callcenter_role_name);
 	 
 	 INSERT  INTO "Role2RightDO" (id, "rightDefRef","roleRef")
 	 SELECT nextval('"Role2RightDO_id_seq"'), uar, r_id 
	 FROM  unnest( callcenter_agent_rights)uar  
 	 CROSS JOIN  (select id as r_id from "RoleDO" where name=callcenter_role_name)r
	 ON CONFLICT ("rightDefRef","roleRef") DO NOTHING;

	/* 
	 * This is only for demo purposes, the corresponding passwords is for these 4 users !InterShop00!
	 * You should create users and roles in the OMT.
	 * You can only define another password withi the OMT, 
	 * and then pick the modified values from the attributes "cryptedPassword" and "hashSalt"
	 */
	
	-- webservice users
	IF NOT EXISTS (SELECT NULL FROM oms."UserDO" WHERE "accountName" = shop_service_user_name) THEN
		INSERT INTO "UserDO" (id,"accountName",active,"companyName", --1
			"firstName","languageDefRef","lastName", --2
			"modificationDate","version", --3
			email,"cryptedPassword","hashSalt") --4
		VALUES
			(nextval('"UserDO_id_seq"'),shop_service_user_name,true,'company', --1
			'webservice',2,'shop', --2
			now(),0, --3
			'','fEbjJo7gZ5sAMgZtPy2FjCQunYSuJ64Xh37hJNNG/j8=','hkP5gPPxgrmpRBH0mdvdGQ=='); --4
	END IF;

	IF NOT EXISTS (SELECT NULL FROM oms."UserDO" WHERE "accountName" = supplier_service_user_name) THEN
		INSERT INTO "UserDO" (id,"accountName",active,"companyName", --1
			"firstName","languageDefRef","lastName", --2
			"modificationDate","version", --3
			email,"cryptedPassword","hashSalt") --4
		VALUES
			(nextval('"UserDO_id_seq"'),supplier_service_user_name,true,'company', --1
			'webservice',2,'supplier', --2
			now(),0, --3
			'','a+Bfq6fQCRNYzDe5KuUqs/luhhMW48dP9fCox5dAKWM=','fQ+2HULNe06R3yhNqpWnOg=='); --4
	END IF;

	-- assign user and role to organization shop_service_user_name
	INSERT INTO "User2OrganizationDO" (id,"organizationRef", "userRef") 
	SELECT
		nextval('"User2OrganizationDO_id_seq"'),
		1,
		(SELECT id FROM "UserDO" WHERE "accountName" = shop_service_user_name)
	ON CONFLICT ("organizationRef", "userRef") DO NOTHING;
	
	INSERT INTO "User2Role2OrganizationDO" (id,"organizationRef", "roleRef", "userRef") 
	SELECT
		nextval('"User2Role2OrganizationDO_id_seq"'),
		1,
		 "RoleDO".id,
		(SELECT id FROM "UserDO" WHERE "accountName" = shop_service_user_name)
	FROM "RoleDO" WHERE "name" IN( shop_service_role_name)
	ON CONFLICT ("organizationRef", "roleRef", "userRef") DO NOTHING;
	
	-- assign user and role to organization supplier_service_user_name
	INSERT INTO "User2OrganizationDO" (id,"organizationRef", "userRef") 
	SELECT
		nextval('"User2OrganizationDO_id_seq"'),
		1,
		(SELECT id FROM "UserDO" WHERE "accountName" = supplier_service_user_name)
	ON CONFLICT ("organizationRef", "userRef") DO NOTHING;
	
	INSERT INTO "User2Role2OrganizationDO" (id,"organizationRef", "roleRef", "userRef") 
	SELECT
		nextval('"User2Role2OrganizationDO_id_seq"'),
		1,
		 "RoleDO".id,
		(SELECT id FROM "UserDO" WHERE "accountName" = supplier_service_user_name)
	FROM "RoleDO" WHERE "name" IN(  supplier_service_role_name)
	ON CONFLICT ("organizationRef", "roleRef", "userRef") DO NOTHING;
	
	----------------------------
	
	-- User callcenter_agent
	IF NOT EXISTS (SELECT NULL FROM oms."UserDO" WHERE "accountName" = callcenter_agent_name) THEN
		INSERT INTO "UserDO" (id,"accountName",active,"companyName", --1
			"firstName","languageDefRef","lastName", --2
			"modificationDate","version", --3
			email,"cryptedPassword","hashSalt") --4
		VALUES
			(nextval('"UserDO_id_seq"'),callcenter_agent_name,true,'company', --1
			'callcenter',2,'agent', --2
			now(),0, --3
			'','Nqa1Yvs9r9Clp3qpLgoUMhrT/tfq1ZWDXQUvOK0x2/I=','AMDFaxpae/ipXgY7sho+kg=='); --4
	END IF;
	userref = (SELECT id FROM  "UserDO" WHERE "accountName" = callcenter_agent_name);


	-- assign user and role to organization
	INSERT INTO "User2OrganizationDO" (id,"organizationRef", "userRef") 
	SELECT
		nextval('"User2OrganizationDO_id_seq"'),
		1,
		(SELECT id FROM "UserDO" WHERE "accountName" = callcenter_agent_name)
		ON CONFLICT ("organizationRef", "userRef") DO NOTHING;
	
	INSERT INTO "User2Role2OrganizationDO" (id,"organizationRef", "roleRef", "userRef") 
	SELECT
		nextval('"User2Role2OrganizationDO_id_seq"'),
		1,
		"RoleDO".id,
		(SELECT id FROM "UserDO" WHERE "accountName" = callcenter_agent_name)
	FROM "RoleDO" WHERE "name" IN( callcenter_role_name, user_admin_role_name)
	ON CONFLICT ("organizationRef", "roleRef", "userRef") DO NOTHING;
	
	----------------------------

	-- user_admin 
	IF NOT EXISTS (SELECT NULL FROM oms."UserDO" WHERE "accountName" = user_admin_user_name) THEN
		INSERT INTO "UserDO" (id,"accountName",active,"companyName", --1
			"firstName","languageDefRef","lastName", --2
			"modificationDate","version", --3
			email,"cryptedPassword","hashSalt") --4
		VALUES
			(nextval('"UserDO_id_seq"'),user_admin_user_name,true,'company', --1
			'user ',2,'admin', --2
			now(),0, --3
			'','z4q9/vhfWJo9suBtJU8TNR3i7/acCkZhqJpGoNEHLas=','p4uJNxFfemFTa+zX+wJ5rw=='); --4
	END IF;
	userref = (SELECT id FROM  "UserDO" WHERE "accountName" = user_admin_user_name);


	-- assign user and role to organization
	INSERT INTO "User2OrganizationDO" (id,"organizationRef", "userRef") 
	SELECT
		nextval('"User2OrganizationDO_id_seq"'),
		1,
		(SELECT id FROM "UserDO" WHERE "accountName" = user_admin_user_name)
		ON CONFLICT ("organizationRef", "userRef") DO NOTHING;
	
	INSERT INTO "User2Role2OrganizationDO" (id,"organizationRef", "roleRef", "userRef") 
	SELECT
		nextval('"User2Role2OrganizationDO_id_seq"'),
		1,
		"RoleDO".id,
		(SELECT id FROM "UserDO" WHERE "accountName" = user_admin_user_name)
	FROM "RoleDO" WHERE "name" IN(  user_admin_role_name)
	ON CONFLICT ("organizationRef", "roleRef", "userRef") DO NOTHING;
	
	
		
END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;