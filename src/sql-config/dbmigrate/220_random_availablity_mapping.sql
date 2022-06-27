CREATE OR REPLACE FUNCTION product.random_availability(adatapackref bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    vIdRecord record;
    vIdID bigint;
    viaRecord record;
    vLow int8 = 0;
    vHigh int8 = 500;
BEGIN

   /*
        For random stockLevel refer https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-random-range/
        Must be inline!
    */

    -- adjust stock levels
    -- Note, that supplierNet (cost price) must be set to have a 'valid' product for order routing
    UPDATE "ImportArticleDO" SET "stockLevel" = ( floor(random()* (vHigh-vLow + 1) + vLow) )::int8, "availabilityInDays" = 0, "supplierNet" = 1.00000 WHERE "importDatapackRef" = aDataPackRef;

END;
$function$
;
