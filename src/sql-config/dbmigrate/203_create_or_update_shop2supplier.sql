
-- Function: oms.create_or_update_shop2supplier(boolean, bigint, bigint, character varying, character varying, bigint, boolean)

-- DROP FUNCTION oms.create_or_update_shop2supplier(boolean, bigint, bigint, character varying, character varying, bigint, boolean, character varying);

CREATE OR REPLACE FUNCTION oms.create_or_update_shop2supplier(
	 p_active boolean,
	 p_shopref bigint,
	 p_supplierref bigint,
	 p_shopsuppliername character varying,
	 p_suppliershopname character varying,
	 p_returncarrierref bigint,
	 p_usesupplierarticlenoasshoparticleno boolean,
	 p_shoparticlenoprefix character varying)
  RETURNS void AS
$BODY$
BEGIN

	INSERT INTO oms."Shop2SupplierDO"(
		"id",
		"active",
		"modificationDate",
		"reservationTimeInDays",
		"shopAccount",
		"shopPassword",
		"shopSupplierName",
		"splitShipmentAllowed",
		"supplierAccount",
		"supplierPassword",
		"supplierShopName",
		"shopRef",
		"supplierRef",
		"returnCarrierRef",
		"useSupplierArticleNoAsShopArticleNo",
		"shopArticleNoPrefix",
		"stockReduceModel",
		"supplierSupportsCOD")
	SELECT nextval('oms."Shop2SupplierDO_id_seq"'),
		p_active,
		CURRENT_TIMESTAMP,
		0,
		'',
		'',
		coalesce(p_shopSupplierName, (SELECT name FROM oms."SupplierDO" WHERE id = p_supplierRef)),
		FALSE,
		'',
		'',
		coalesce(p_supplierShopName, (SELECT name FROM oms."ShopDO" WHERE id = p_shopRef)),
		p_shopRef,
		p_supplierRef,
		p_returnCarrierRef,
		p_useSupplierArticleNoAsShopArticleNo,
		p_shoparticlenoprefix,
		25, --stockReduceModel
		true
	ON CONFLICT ("shopRef", "supplierRef") DO UPDATE SET
		"shopSupplierName" = EXCLUDED."shopSupplierName",
		"supplierShopName" = EXCLUDED."supplierShopName",
		active = EXCLUDED.active,
		"returnCarrierRef" = EXCLUDED."returnCarrierRef",
		"useSupplierArticleNoAsShopArticleNo" = EXCLUDED."useSupplierArticleNoAsShopArticleNo",
		"shopArticleNoPrefix" = EXCLUDED."shopArticleNoPrefix",
		"stockReduceModel" = EXCLUDED."stockReduceModel"
		;

END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
