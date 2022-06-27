/*
  For random refer to https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-random-range/
*/


CREATE OR REPLACE FUNCTION product.random_availability(adatapackref bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$

DECLARE
    vLow int8 = 0;
    vHigh int8 = 500;

BEGIN
    -- adjust stock levels, availability and supplier price
    -- Note that supplierNet (cost price) must be set to have a 'valid' product for order routing
    UPDATE "ImportArticleDO" 
    SET "stockLevel" = ( floor(random()* (vHigh-vLow + 1) + vLow) )::int8, 
        "availabilityInDays" = 0, 
        "supplierNet" = 1.00000 
    WHERE "importDatapackRef" = aDataPackRef;

END;
$function$;

COMMENT ON FUNCTION  product.random_availability(bigint) IS 'set dummy stock, avaibility and price on imported product. 
(Used to have "valid" product in IOM when no BCG file is available, e.g. for A* CSV files generated out of the ICM data.)
These dummy data can be corrected later on, while providing according BCG files.';

