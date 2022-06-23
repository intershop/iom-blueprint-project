CREATE OR REPLACE FUNCTION product."random_availability"( aDataPackRef bigint ) RETURNS VOID AS $$
DECLARE
    vIdRecord record;
    vIdID bigint;
    viaRecord record;
    vLow int8 = 0;
    vHigh int8 = 500;
    vRandom int8;
BEGIN

    vRandom = floor(random()* (vHigh-vLow + 1) + vLow); /* refer https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-random-range/ */

    -- adjust stock levels
    UPDATE "ImportArticleDO" SET "stockLevel" = vRandom, "availabilityInDays" = 0 WHERE "importDatapackRef" = aDataPackRef;

END;
$$ LANGUAGE plpgsql;
