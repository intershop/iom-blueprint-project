-- Function: oms.upsert_eb_value(bigint, text, bigint)

-- DROP FUNCTION oms.upsert_eb_value(bigint, text, bigint);

CREATE OR REPLACE FUNCTION oms.upsert_eb_value(
    p_executionbeankeydefref bigint,
    p_parametervalue text,
    p_communicationpartnerref bigint)
  RETURNS void AS
$BODY$

BEGIN

	IF NOT EXISTS (select * from oms."ExecutionBeanValueDO" 
						where "communicationPartnerRef" = p_communicationPartnerRef 
						and "executionBeanKeyDefRef" = p_executionBeanKeyDefRef) 
	THEN
		INSERT INTO oms."ExecutionBeanValueDO"(
			id, 
			"executionBeanKeyDefRef", 
			"parameterValue", 
			"communicationPartnerRef")
		SELECT nextval('oms."ExecutionBeanValueDO_id_seq"'),
			p_executionBeanKeyDefRef,
			p_parameterValue,
			p_communicationPartnerRef;
	ELSE
		UPDATE  oms."ExecutionBeanValueDO" SET 
			"parameterValue" = p_parameterValue
		WHERE "executionBeanKeyDefRef" = p_executionBeanKeyDefRef 
		AND "communicationPartnerRef" = p_communicationPartnerRef;
	END IF;

	RETURN;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
