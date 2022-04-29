
CREATE OR REPLACE FUNCTION oms.create_or_update_carrier(
	p_id bigint,
	p_name text,
	p_trackingUrl text)
RETURNS void AS
$BODY$
BEGIN

	IF NOT EXISTS (SELECT * FROM "CarrierDO" WHERE id = p_id) THEN
		INSERT INTO oms."CarrierDO" (id, name, "trackingUrl", "modificationDate", version)
			 SELECT p_id, p_name, p_trackingUrl, now(), 0;
	ELSE
		UPDATE "CarrierDO" SET name = p_name, "trackingUrl" = p_trackingUrl WHERE id = p_id;
	END IF;

END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
