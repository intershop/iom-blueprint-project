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
	    'OmsSystem',                    --parent_org_name varchar,
	    'inSPIRED',    						--name            varchar,
		'inSPIRED Organization'				--description     varchar
	);
END IF;

IF NOT EXISTS (SELECT null from oms."ShopOrderValidationDO" where name = 'B2C Invoicing Rules Set') THEN
	INSERT into oms."ShopOrderValidationDO"
	(
	  id,                           -- bigint NOT NULL,
	  "articleId",                  --boolean,
	  "commercialRegister",         --boolean,
	  "companyName",              	--boolean,
	  "companyType",              	--boolean,
	  "costNo",                     --boolean,
	  department,                   --boolean,
	  ean,                          --boolean,
	  "lineOfBusiness",             --boolean,
	  "purchaseGross",              --boolean,
	  "purchaseNet",              	--boolean,
	  "purchaseTax",              	--boolean,
	  "salesGross",                 --boolean,
	  "salesNet",                 	--boolean,
	  "salesTax",                 	--boolean,
	  "shopCustomerNo",             --boolean,
	  "shopOrderNo",              	--boolean,
	  "shopSelectedSupplierId",     --boolean,
	  "vatNo",                      --boolean,
	  "singlePositionArticle",      --boolean,
	  name,                         --character varying(255) NOT NULL,
	  "orderAddressEmailRequired"   --boolean DEFAULT false,
	)
	SELECT
	    nextval('oms."ShopOrderValidationDO_id_seq"'),
	    true, 				-- articleId
	    FALSE, 				-- commercialRegister
	    FALSE, 				-- companyName
	    FALSE, 				-- companyType
	    FALSE, 				-- costNo
	    FALSE, 				-- department
	    FALSE, 				-- ean
	    FALSE, 				-- lineOfBusiness
	    FALSE, 				-- purchaseGross
	    FALSE, 				-- purchaseNet
	    FALSE, 				-- purchaseTax
	    FALSE,				-- salesGross (FALSE)
	    TRUE, 				-- salesNet (TRUE)
	    TRUE, 				-- salesTax (TRUE)
	    TRUE,				-- shopCustomerNo (TRUE)
	    TRUE,				-- shopOrderNo (TRUE)
	    FALSE, 				-- shopSelectedSupplierId
	    FALSE, 				-- vatNo
	    FALSE, 				-- singlePositionArticle
	    'B2C Invoicing Rules Set', --some self-descriptive name
	    TRUE 				-- orderAddressEmailRequired (???)

	    ;
END IF;

IF NOT EXISTS (SELECT null from oms."ShopOrderValidationDO" where name = 'B2B Invoicing Rules Set') THEN
	INSERT into oms."ShopOrderValidationDO"
	(
	  id,                           -- bigint NOT NULL,
	  "articleId",                  --boolean,
	  "commercialRegister",         --boolean,
	  "companyName",              	--boolean,
	  "companyType",              	--boolean,
	  "costNo",                     --boolean,
	  department,                   --boolean,
	  ean,                          --boolean,
	  "lineOfBusiness",             --boolean,
	  "purchaseGross",              --boolean,
	  "purchaseNet",              	--boolean,
	  "purchaseTax",              	--boolean,
	  "salesGross",                 --boolean,
	  "salesNet",                 	--boolean,
	  "salesTax",                 	--boolean,
	  "shopCustomerNo",             --boolean,
	  "shopOrderNo",              	--boolean,
	  "shopSelectedSupplierId",     --boolean,
	  "vatNo",                      --boolean,
	  "singlePositionArticle",      --boolean,
	  name,                         --character varying(255) NOT NULL,
	  "orderAddressEmailRequired"   --boolean DEFAULT false,
	)
	SELECT
	    nextval('oms."ShopOrderValidationDO_id_seq"'),
	    true, 				-- articleId
	    FALSE, 				-- commercialRegister
	    FALSE, 				-- companyName
	    FALSE, 				-- companyType
	    FALSE, 				-- costNo
	    FALSE, 				-- department
	    FALSE, 				-- ean
	    FALSE, 				-- lineOfBusiness
	    FALSE, 				-- purchaseGross
	    FALSE, 				-- purchaseNet
	    FALSE, 				-- purchaseTax
	    FALSE,				-- salesGross (FALSE)
	    TRUE, 				-- salesNet (TRUE)
	    TRUE, 				-- salesTax (TRUE)
	    TRUE,				-- shopCustomerNo (TRUE)
	    TRUE,				-- shopOrderNo (TRUE)
	    FALSE, 				-- shopSelectedSupplierId
	    FALSE, 				-- vatNo
	    FALSE, 				-- singlePositionArticle
	    'B2B Invoicing Rules Set', --some self-descriptive name
	    TRUE 				-- orderAddressEmailRequired (???)

	    ;
END IF;

END;
]]#
-- dollar quoting
$do;