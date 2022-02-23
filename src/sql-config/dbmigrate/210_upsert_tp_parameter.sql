DO $$
BEGIN

-- Function: oms.upsert_tp_parameter(bigint, text, bigint)

-- DROP FUNCTION oms.upsert_tp_parameter(bigint, text, bigint);

CREATE OR REPLACE FUNCTION oms.upsert_tp_parameter(
    p_transformerProcessesParameterKeyDefRef bigint,
    p_parametervalue text,
    p_transformerProcessesRef bigint)
  RETURNS void AS
$BODY$BEGIN
	IF NOT EXISTS (SELECT 1 FROM oms."TransformerProcessParameterDO" WHERE "transformerProcessesParameterKeyDefRef" = p_transformerProcessesParameterKeyDefRef AND "transformerProcessesRef" = p_transformerProcessesRef) THEN
	    INSERT INTO "TransformerProcessParameterDO"( id, "parameterValue", "transformerProcessesParameterKeyDefRef", "transformerProcessesRef")
	        SELECT nextval('"TransformerProcessParameterDO_id_seq"'), p_parametervalue,
	                p_transformerProcessesParameterKeyDefRef, p_transformerProcessesRef;
	ELSE
		UPDATE oms."TransformerProcessParameterDO" SET "parameterValue" = p_parameterValue
			WHERE "transformerProcessesParameterKeyDefRef" = p_transformerProcessesParameterKeyDefRef AND "transformerProcessesRef" = p_transformerProcessesRef;
	END IF;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

END;
$$;