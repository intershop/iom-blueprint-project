#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier
$vars_country_codes

-- PAUSE velocity parser
#[[
-- local variables go here
shopref int8;
-- end variables block with 
BEGIN

-- TaxDO - NoTax(1) - 0%
INSERT INTO oms."TaxDO" ("id", "countryDefRef", "tax", "taxTypeDefRef", "validFrom", "validUntil")
SELECT nextval('oms."TaxDO_id_seq"'), cc_us, 0.00000, 1, '2000-01-01 00:00:00', '2999-01-01 00:00:00'
WHERE NOT EXISTS
(
	SELECT 1 from oms."TaxDO" WHERE "taxTypeDefRef" = 1 AND "countryDefRef" = cc_us AND "tax" = 0.00000 AND "validFrom" = '2000-01-01 00:00:00' AND "validUntil" = '2999-01-01 00:00:00'
);

-- TaxDO - ReducedTax(3) - 7%
INSERT INTO oms."TaxDO" ("id", "countryDefRef", "tax", "taxTypeDefRef", "validFrom", "validUntil")
SELECT nextval('oms."TaxDO_id_seq"'), cc_us, 7.00000, 3, '2000-01-01 00:00:00', '2999-01-01 00:00:00'
WHERE NOT EXISTS
(
	SELECT 1 from oms."TaxDO" WHERE "taxTypeDefRef" = 3 AND "countryDefRef" = cc_us AND "tax" = 7.00000 AND "validFrom" = '2000-01-01 00:00:00' AND "validUntil" = '2999-01-01 00:00:00'
);

-- TaxDO - FullTax(5) - 19%
INSERT INTO oms."TaxDO" ("id", "countryDefRef", "tax", "taxTypeDefRef", "validFrom", "validUntil")
SELECT nextval('oms."TaxDO_id_seq"'), cc_us, 19.00000, 5, '2000-01-01 00:00:00', '2999-01-01 00:00:00'
WHERE NOT EXISTS
(
	SELECT 1 from oms."TaxDO" WHERE "taxTypeDefRef" = 5 AND "countryDefRef" = cc_us AND "tax" = 19.00000 AND "validFrom" = '2000-01-01 00:00:00' AND "validUntil" = '2999-01-01 00:00:00'
);

---- Shop2TaxTypeDefDO
FOREACH shopref IN ARRAY shops_all LOOP
	INSERT INTO oms."Shop2TaxTypeDefDO"("id", "shopTaxTypeName", "taxTypeDefRef", "shopRef", "modificationDate")
		SELECT nextval('"Shop2TaxTypeDefDO_id_seq"'), 'NoTax', 1, shopref, now() UNION ALL
		SELECT nextval('"Shop2TaxTypeDefDO_id_seq"'), 'ReducedTax', 3, shopref, now() UNION ALL
		SELECT nextval('"Shop2TaxTypeDefDO_id_seq"'), 'FullTax', 5, shopref, now()
		ON CONFLICT ("taxTypeDefRef", "shopRef") DO UPDATE SET "shopTaxTypeName" = EXCLUDED."shopTaxTypeName";
END LOOP;


---- Shop2DeliveryTypeDefDO
---- per shop
FOREACH shopref IN ARRAY shops_all LOOP
	INSERT INTO "Shop2DeliveryTypeDefDO"("id", "deliveryTypeDefRef", "shopDeliveryTypeName", "shopRef")
	    SELECT nextval('"Shop2DeliveryTypeDefDO_id_seq"'), 1, 'SHIPPING_STANDARD', shopref
		ON CONFLICT ("deliveryTypeDefRef", "shopRef") DO UPDATE SET "shopDeliveryTypeName" = EXCLUDED."shopDeliveryTypeName";
		
	INSERT INTO "Shop2DeliveryTypeDefDO"("id", "deliveryTypeDefRef", "shopDeliveryTypeName", "shopRef")
	    SELECT nextval('"Shop2DeliveryTypeDefDO_id_seq"'), 2, 'SHIPPING_EXPRESS', shopref
		ON CONFLICT ("deliveryTypeDefRef", "shopRef") DO UPDATE SET "shopDeliveryTypeName" = EXCLUDED."shopDeliveryTypeName";
END LOOP;

---- Shop2DeliveryFormDefDO for all shops
---- per shop
FOREACH shopref IN ARRAY shops_all LOOP
INSERT INTO "Shop2DeliveryFormDefDO"("id", "deliveryFormDefRef", "shopDeliveryFormName", "shopRef")
    SELECT nextval('"Shop2DeliveryFormDefDO_id_seq"'), 10, 'STD_GROUND', shopref
	ON CONFLICT ("deliveryFormDefRef", "shopRef") DO UPDATE SET "shopDeliveryFormName" = EXCLUDED."shopDeliveryFormName";
END LOOP;

-- Shop2OrderValidationRuleDefDO
FOREACH shopref in array shops_all LOOP

	INSERT into "Shop2OrderValidationRuleDefDO"("id", "orderValidationRuleDefRef", "runSynchron", "shopRef")
		SELECT nextval('"Shop2OrderValidationRuleDefDO_id_seq"'), 1, TRUE, shopref UNION ALL
		SELECT nextval('"Shop2OrderValidationRuleDefDO_id_seq"'), 3, TRUE, shopref UNION ALL
		SELECT nextval('"Shop2OrderValidationRuleDefDO_id_seq"'), 4, FALSE, shopref UNION ALL
		SELECT nextval('"Shop2OrderValidationRuleDefDO_id_seq"'), 5, FALSE, shopref UNION ALL
		SELECT nextval('"Shop2OrderValidationRuleDefDO_id_seq"'), 6, TRUE, shopref UNION ALL
		SELECT nextval('"Shop2OrderValidationRuleDefDO_id_seq"'), 10, FALSE, shopref UNION ALL
		SELECT nextval('"Shop2OrderValidationRuleDefDO_id_seq"'), 11, FALSE, shopref UNION ALL
		SELECT nextval('"Shop2OrderValidationRuleDefDO_id_seq"'), 13, TRUE, shopref
	
		ON CONFLICT("orderValidationRuleDefRef", "shopRef") DO NOTHING;
END LOOP;

FOREACH shopref IN ARRAY shops_all LOOP

    INSERT INTO oms."PartnerReferrerDO" ("id", "version", "shopRef")
        SELECT nextval('oms."PartnerReferrerDO_id_seq"'), 0, shopref
        ON CONFLICT("shopRef") DO NOTHING;

END LOOP;

END;
]]#
-- dollar quoting
$do;
