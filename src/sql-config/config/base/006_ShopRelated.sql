#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier
$vars_country_codes

-- PAUSE velocity parser
#[[
-- local variables go here
shopref int8;
rec record;
-- end variables block with 
BEGIN

---- TaxDO
  -- see TaxTypeDefDO. There is a fallback on the taxTypeDefDO internal names, hence this table only usage is to provide alternate tax names.
  -- Only one name per shop and taxName is allowed.
  -- recommended: use country isoCode3 as location
  FOR rec IN (
   select 'USA' as location,  0.0 as rate, 1 as type_id UNION ALL --NoTax(1)
   select 'USA'            ,  4.0        , 3            UNION ALL --ReducedTax(3)
   select 'USA'            ,  6.0        , 5                      --FullTax(5) 
  )
  LOOP
  
    IF NOT EXISTS (select * from "TaxDO" where location = rec.location and tax = rec.rate and "taxTypeDefRef" = rec.type_id) THEN
    	  INSERT INTO oms."TaxDO" (id, location, tax, "taxTypeDefRef", "validFrom", "validUntil")
    	  SELECT nextval('oms."TaxDO_id_seq"'), rec.location, rec.rate, rec.type_id, '2000-01-01 00:00:00', '2999-01-01 00:00:00';
    END IF;
  
  END LOOP;



---- Shop2TaxTypeDefDO
  --provide shop specific names for the taxes
	FOREACH shopref IN ARRAY shops_all LOOP
		INSERT INTO oms."Shop2TaxTypeDefDO"("id", "shopTaxTypeName", "taxTypeDefRef", "shopRef", "modificationDate")
			SELECT nextval('"Shop2TaxTypeDefDO_id_seq"'), 'NoTax',      1, shopref, now() UNION ALL
			SELECT nextval('"Shop2TaxTypeDefDO_id_seq"'), 'ReducedTax', 3, shopref, now() UNION ALL
			SELECT nextval('"Shop2TaxTypeDefDO_id_seq"'), 'FullTax',    5, shopref, now()
			ON CONFLICT ("taxTypeDefRef", "shopRef") DO UPDATE SET "shopTaxTypeName" = EXCLUDED."shopTaxTypeName";
	END LOOP;


---- Shop2DeliveryTypeDefDO
  -- only used for the type EXPRESS (id=2)(mappings for other types are ignored)
  -- Without a mapping, the type EXPESS is not available in the corresponding shop
FOREACH shopref IN ARRAY shops_all LOOP
	INSERT INTO "Shop2DeliveryTypeDefDO"("id", "deliveryTypeDefRef", "shopDeliveryTypeName", "shopRef")
	SELECT nextval('"Shop2DeliveryTypeDefDO_id_seq"'), 2, 'SHIPPING_EXPRESS', shopref
	ON CONFLICT ("deliveryTypeDefRef", "shopRef") DO UPDATE SET "shopDeliveryTypeName" = EXCLUDED."shopDeliveryTypeName";
END LOOP;


-- add missing shop entries in "PartnerReferrerDO"
 INSERT INTO oms."PartnerReferrerDO" ("id", "version", "shopRef")
 SELECT nextval('oms."PartnerReferrerDO_id_seq"'), 0, shop_ref
 FROM (
	select unnest(shops_all) as  shop_ref
	EXCEPT
	select "shopRef" FROM "PartnerReferrerDO"
	order by 1
	) missing;


END;
]]#
-- dollar quoting
$do;
