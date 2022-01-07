DO $$
BEGIN

-- Function: oms.s2s_id(bigint, bigint)

-- DROP FUNCTION oms.s2s_id(bigint, bigint);

CREATE OR REPLACE FUNCTION oms.s2s_id(
    p_shopref bigint,
    p_supplierref bigint)
  RETURNS bigint AS
$BODY$BEGIN
  RETURN (SELECT id FROM oms."Shop2SupplierDO" WHERE "shopRef" = p_shopref AND "supplierRef" = p_supplierref);
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

END;
$$;