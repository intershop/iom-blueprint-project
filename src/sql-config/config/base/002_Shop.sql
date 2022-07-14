#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier
$vars_country_codes

-- PAUSE velocity parser
#[[
-- local variables go here

-- end variables block with 
BEGIN

-- inTRONICS b2c Shop
PERFORM create_or_update_shop(
            -- "id", "active", "availabilityTolerance", "isB2B"
            shop_intronics_b2c, TRUE, 0, FALSE,
            -- "countryDefRef", "mapArticleId", "name"
            cc_us, TRUE, 'inTRONICS',
            -- "orderOptimizeDefRef", "overwriteSelectedSupplierAllowed", "parentRef", "parentOrganization"
            2, false, null, 'inSPIRED',
            -- "returnCharge", "returnDeadline", "shopName", "shopOrderSequenceName"
            0, 16, 'inTRONICS', NULL,
            -- "singleArticleInfo", "shopAddressRef", "shopOrderValidationRef"
            TRUE, 10000, null,
            -- "hasSupplierPrefix", "hasInformShopReturn", "internalShopName"
            FALSE, FALSE, 'inTRONICS',
            -- "shopUsesOMT", "shopCustomerSequenceName", "preferredSupplierOnly"
            FALSE, NULL, FALSE,
            -- "orderProcessingDelay", "shopOrderSequenceNumberFormatString"
            NULL, NULL,
            -- "orderTokenValidityDuration"
            NULL, 
            -- "amountDaysForPaymentReminderMailOfPrepaidOrders", "amountDaysForAutoCancellationOfPrepaidOrders", "isReservationWithDOSE"
            NULL, NULL, TRUE,
            -- "shopRMANumberSequenceName", "shopRMANumberSequenceFormatString"
            'rma_number_sequence_generator', 'rma-number-{0}' -- will produce number like 'rma-number-10000'
);

-- inTRONICS b2b Shop
PERFORM create_or_update_shop(
            -- "id", "active", "availabilityTolerance", "isB2B"
            shop_intronics_b2b, TRUE, 0, TRUE,
            -- "countryDefRef", "mapArticleId", "name"
            cc_us, TRUE, 'inTRONICS Business',
            -- "orderOptimizeDefRef", "overwriteSelectedSupplierAllowed", "parentRef", "parentOrganization"
            2, false, null, 'inSPIRED',
            -- "returnCharge", "returnDeadline", "shopName", "shopOrderSequenceName"
            0, 16, 'inTRONICS Business', NULL,
            -- "singleArticleInfo", "shopAddressRef", "shopOrderValidationRef"
            TRUE, 10000, null,
            -- "hasSupplierPrefix", "hasInformShopReturn", "internalShopName"
            FALSE, FALSE, 'inTRONICS Business',
            -- "shopUsesOMT", "shopCustomerSequenceName", "preferredSupplierOnly"
            FALSE, NULL, FALSE,
            -- "orderProcessingDelay", "shopOrderSequenceNumberFormatString"
            NULL, NULL,
            -- "orderTokenValidityDuration"
            NULL, 
            -- "amountDaysForPaymentReminderMailOfPrepaidOrders", "amountDaysForAutoCancellationOfPrepaidOrders", "isReservationWithDOSE"
            NULL, NULL, TRUE,
            -- "shopRMANumberSequenceName", "shopRMANumberSequenceFormatString"
            'rma_number_sequence_generator', 'rma-number-{0}' -- will produce number like 'rma-number-10000'
);

END;
]]#
-- dollar quoting
$do;