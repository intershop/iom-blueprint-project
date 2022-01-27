#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier
$vars_carriers
-- PAUSE velocity parser
#[[

-- local variables go here
carrierref int8;
shopref int8;
supplierref int8;
-- end variables block with 

BEGIN

PERFORM create_or_update_carrier(carrier_dhl, 'DHL', 'https://www.dhl.com/en-us/home/tracking.html?AWB=');

FOREACH carrierref IN ARRAY carriers_all LOOP
	IF NOT EXISTS (SELECT NULL FROM oms."PartnerReferrerDO" WHERE "carrierRef" =  carrierref) THEN
		INSERT INTO oms."PartnerReferrerDO" ("id", "version", "carrierRef")
			SELECT nextval('oms."PartnerReferrerDO_id_seq"'), 0, carrierref;
	END IF;
END LOOP;

FOREACH carrierref IN ARRAY carriers_all LOOP
	FOREACH shopref IN ARRAY shops_all LOOP
		IF NOT EXISTS (SELECT NULL FROM oms."Shop2CarrierDO" WHERE "shopRef" = shopref AND "carrierRef" = carrierref) THEN
			INSERT INTO oms."Shop2CarrierDO" (id, "shopCarrierName", "carrierRef", "shopRef")
				SELECT nextval('oms."Shop2CarrierDO_id_seq"'), (select name from "CarrierDO" where id = carrierref) , carrierref, shopref;
		END IF;
	END LOOP;
	
	FOREACH supplierref IN ARRAY suppliers_all LOOP
		IF NOT EXISTS (SELECT NULL FROM oms."Supplier2CarrierDO" WHERE "carrierRef" = carrierref AND "supplierRef" = supplierref) THEN
		INSERT INTO oms."Supplier2CarrierDO" (id, "supplierCarrierName", "carrierRef", "supplierRef")
			SELECT nextval('oms."Supplier2CarrierDO_id_seq"'), (select name from "CarrierDO" where id = carrierref), carrierref, supplierref;
		END IF;
	END LOOP;
	
END LOOP;

END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;