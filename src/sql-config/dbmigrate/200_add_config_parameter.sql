/*
This function name is not well chosen. It is too generic and could hence conflict with a future core function.
Moreover it does not mention the object containing the new parameter.
better would be something like add_s2s_config_parameter(...)
*/

-- DROP FUNCTION oms.add_config_parameter(bigint, character varying, character varying, character varying);
CREATE OR REPLACE FUNCTION add_s2s_config_parameter(
	 p_shop2supplierref bigint,
	 p_configtype       varchar,
	 p_key              varchar,
	 p_value            varchar)
  RETURNS void AS
$$

BEGIN

	INSERT INTO oms."CustomConfigurationDO" ("id", "shop2SupplierRef", "configType")
	SELECT nextval('oms."CustomConfigurationDO_id_seq"'), p_shop2supplierref, p_configtype
	WHERE NOT EXISTS (select 1 FROM oms."CustomConfigurationDO"  
					      where "shop2SupplierRef" = p_shop2supplierref and "configType" = p_configtype);

	IF p_key IS NOT NULL THEN
		INSERT INTO oms."CustomConfigurationDO_AV" ("customConfigurationRef", key, value)
		SELECT (select id from oms."CustomConfigurationDO" where "shop2SupplierRef" = p_shop2supplierref and "configType" = p_configtype), p_key, p_value
		ON CONFLICT ("customConfigurationRef", key) DO UPDATE SET value = p_value;
	END IF;
  
END;

$$
LANGUAGE plpgsql VOLATILE;
