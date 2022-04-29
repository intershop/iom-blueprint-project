DO $$
BEGIN

-- Function: oms.upsert_shop2supplier2reducereason(text, text, bigint, boolean)

-- DROP FUNCTION oms.upsert_shop2supplier2reducereason(text, text, bigint, boolean);

CREATE OR REPLACE FUNCTION oms.upsert_shop2supplier2reducereason(
    p_shopReduceReason text,
    p_supplierReduceReason text,
    p_shop2SupplierRef bigint,
    p_isDefault boolean)
  RETURNS bigint AS
$BODY$BEGIN
	IF NOT EXISTS (SELECT 1 FROM oms."Shop2Supplier2ReduceReasonDO" WHERE "shop2SupplierRef" = p_shop2SupplierRef AND "supplierReduceReason" = p_supplierReduceReason) THEN
		INSERT INTO oms."Shop2Supplier2ReduceReasonDO"(
					id, "shopReduceReason", "supplierReduceReason", "shop2SupplierRef",
					"isDefault")
			SELECT nextval('oms."Shop2Supplier2ReduceReasonDO_id_seq"'), p_shopReduceReason, p_supplierReduceReason, p_shop2SupplierRef, p_isDefault;
	ELSE
		UPDATE oms."Shop2Supplier2ReduceReasonDO" SET "shopReduceReason" = p_shopReduceReason, "isDefault" = p_isDefault
			WHERE "shop2SupplierRef" = p_shop2SupplierRef AND "supplierReduceReason" = p_supplierReduceReason;
	END IF;

	RETURN (SELECT id FROM oms."Shop2Supplier2ReduceReasonDO" WHERE "shop2SupplierRef" = p_shop2SupplierRef AND "isDefault" = p_isDefault AND "supplierReduceReason" = p_supplierReduceReason AND "shopReduceReason" = p_shopReduceReason);
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

END;
$$;