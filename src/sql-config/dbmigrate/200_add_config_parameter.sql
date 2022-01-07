DO $$
BEGIN

		-- DROP FUNCTION oms.add_config_parameter(bigint, character varying, character varying, character varying);
		CREATE OR REPLACE FUNCTION oms.add_config_parameter(
		    p_shop2supplierref bigint,
		    p_configtype character varying,
		    p_key character varying,
		    p_value character varying)
		  RETURNS void AS
		$BODY$BEGIN
		  IF NOT EXISTS (SELECT 1 FROM oms."CustomConfigurationDO"  where "shop2SupplierRef" = p_shop2supplierref and "configType" = p_configtype) THEN
		    INSERT INTO oms."CustomConfigurationDO" ("id", "shop2SupplierRef", "configType")
		      SELECT nextval('oms."CustomConfigurationDO_id_seq"'), p_shop2supplierref, p_configtype;
		  END IF;
		  IF p_key IS NOT NULL THEN
			  insert into oms."CustomConfigurationDO_AV" ("customConfigurationRef", key, value)
				select (select id from oms."CustomConfigurationDO" where "shop2SupplierRef" = p_shop2supplierref and "configType" = p_configtype), p_key, p_value
				ON CONFLICT ("customConfigurationRef", key) DO UPDATE SET value = p_value;
		  END IF;
		END;
		$BODY$
		  LANGUAGE plpgsql VOLATILE
		  COST 100;

END;
$$;