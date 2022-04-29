SET client_min_messages='warning';

-- Function: oms.s2s_id(bigint, bigint)

-- a possible previous version with a different signature must be dropped first (cannot use REPLACE)
DROP FUNCTION IF EXISTS oms.s2s_id(bigint, bigint);

CREATE FUNCTION oms.s2s_id(
    p_shopref bigint,
    p_supplierref bigint)
RETURNS bigint AS
$$
SELECT id FROM oms."Shop2SupplierDO" WHERE "shopRef" = p_shopref AND "supplierRef" = p_supplierref;
$$
LANGUAGE sql
COST 100;

comment  on function oms.s2s_id(bigint, bigint) is 'returns the Shop2SupplierDO.id (if any) for the parameters(shopRef, supplierRef)';
