DO $$
BEGIN
    -- Function: oms.create_or_update_shop(bigint, boolean, integer, boolean, integer, boolean, character varying, integer, boolean, bigint, numeric, integer, character varying, character varying, boolean, bigint, bigint, boolean, boolean, character varying, boolean, character varying, boolean, character varying, character varying, character varying, character varying, smallint, smallint)
	
    CREATE OR REPLACE FUNCTION oms.create_or_update_shop(
        p_id bigint,
        p_active boolean,
        p_availabilitytolerance integer,
        p_isb2b boolean,
        p_countrydefref integer,
        p_maparticleid boolean,
        p_name character varying,
        p_orderoptimizedefref integer,
        p_overwriteselectedsupplierallowed boolean,
        p_parentref bigint,
        p_parentorganization character varying,
        p_returncharge numeric,
        p_returndeadline integer,
        p_shopname character varying,
        p_shopordersequencename character varying,
        p_singlearticleinfo boolean,
        p_shopaddressref bigint,
        p_shopordervalidationref bigint,
        p_hassupplierprefix boolean,
        p_hasinformshopreturn boolean,
        p_internalshopname character varying,
        p_shopusesomt boolean,
        p_shopcustomersequencename character varying,
        p_preferredsupplieronly boolean,
        p_orderprocessingdelay character varying,
        p_shopordersequencenumberformatstring character varying,
        p_ordertokenvalidityduration character varying,
        p_amountdaysforpaymentremindermailofprepaidorders smallint,
        p_amountdaysforautocancellationofprepaidorders smallint,
        p_isreservationwithdose boolean,
        p_shoprmanumbersequencename character varying,
        p_shoprmanumbersequenceformatstring character varying)
      RETURNS void AS
    $BODY$BEGIN

            INSERT INTO oms."ShopDO"(
                "id", "active", "availabilityTolerance", "isB2B", --1
                "countryDefRef", "mapArticleId", "modificationDate", "name", --2
                "orderOptimizeDefRef", "overwriteSelectedSupplierAllowed", "parentRef", --3
                "returnDeadline", "shopName", "shopOrderSequenceName", --4
                "singleArticleInfo", "shopOrderValidationRef", --5
                "hasSupplierPrefix", "internalShopName", --6
                "shopCustomerSequenceName", "preferredSupplierOnly", --7
                "orderProcessingDelay", "shopOrderSequenceNumberFormatString", --8
                "orderTokenValidityDuration",  --9
                "amountDaysForPaymentReminderMailOfPrepaidOrders", "amountDaysForAutoCancellationOfPrepaidOrders", "isReservationWithDOSE", --10
                "shopRMANumberSequenceName", "shopRMANumberSequenceFormatString") --11
                SELECT p_id, p_active, p_availabilityTolerance, p_isB2B, --1
                p_countryDefRef, p_mapArticleId, now(), p_name, --2
                p_orderOptimizeDefRef, p_overwriteSelectedSupplierAllowed, p_parentRef, --3
                p_returnDeadline, p_shopName, p_shopOrderSequenceName, --4
                p_singleArticleInfo, p_shopOrderValidationRef, --5
                p_hasSupplierPrefix, p_internalShopName, --6
                p_shopCustomerSequenceName, p_preferredSupplierOnly, --7
                p_orderProcessingDelay, p_shopOrderSequenceNumberFormatString, --8
                p_orderTokenValidityDuration, --9
                p_amountDaysForPaymentReminderMailOfPrepaidOrders, p_amountDaysForAutoCancellationOfPrepaidOrders, p_isreservationwithdose, --10
                p_shoprmanumbersequencename, p_shoprmanumbersequenceformatstring --11

            ON CONFLICT (id) DO UPDATE SET
                "active" = EXCLUDED."active", "availabilityTolerance" = EXCLUDED."availabilityTolerance", "isB2B" = EXCLUDED."isB2B", --1
                "countryDefRef" = EXCLUDED."countryDefRef", "mapArticleId" = EXCLUDED."mapArticleId", "modificationDate" = EXCLUDED."modificationDate", "name" = EXCLUDED."name", --2
                "orderOptimizeDefRef" = EXCLUDED."orderOptimizeDefRef", "overwriteSelectedSupplierAllowed" = EXCLUDED."overwriteSelectedSupplierAllowed", "parentRef" = EXCLUDED."parentRef", --3
                "returnDeadline" = EXCLUDED."returnDeadline", "shopName" = EXCLUDED."shopName", "shopOrderSequenceName" = EXCLUDED."shopOrderSequenceName", --4
                "singleArticleInfo" = EXCLUDED."singleArticleInfo",  "shopOrderValidationRef" = EXCLUDED."shopOrderValidationRef", --5
                "hasSupplierPrefix" = EXCLUDED."hasSupplierPrefix", "internalShopName" = EXCLUDED."internalShopName", --6
                "shopCustomerSequenceName" = EXCLUDED."shopCustomerSequenceName", "preferredSupplierOnly" = EXCLUDED."preferredSupplierOnly", --7
                "orderProcessingDelay" = EXCLUDED."orderProcessingDelay", "shopOrderSequenceNumberFormatString" = EXCLUDED."shopOrderSequenceNumberFormatString", --8
                "orderTokenValidityDuration" = EXCLUDED."orderTokenValidityDuration", --9
                "amountDaysForPaymentReminderMailOfPrepaidOrders" = EXCLUDED."amountDaysForPaymentReminderMailOfPrepaidOrders", "amountDaysForAutoCancellationOfPrepaidOrders" = EXCLUDED."amountDaysForAutoCancellationOfPrepaidOrders", "isReservationWithDOSE" = EXCLUDED."isReservationWithDOSE",
                "shopRMANumberSequenceName" = EXCLUDED."shopRMANumberSequenceName", "shopRMANumberSequenceFormatString" = EXCLUDED."shopRMANumberSequenceFormatString"
                ;
            IF p_parentRef IS NULL THEN
				-- TODO adjust in new project or make configurable
                PERFORM admin.set_parent_org(p_name, p_parentorganization);
            END IF;



            END;
            $BODY$
      LANGUAGE plpgsql VOLATILE
      COST 100;

END;
$$;