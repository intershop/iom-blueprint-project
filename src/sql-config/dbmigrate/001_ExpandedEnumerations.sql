DO $$
BEGIN

	--ORDER VALIDATION RULES
	INSERT INTO oms."OrderValidationRuleDefDO"(id, name, rank, mandatory, description) VALUES
		(10000, 'ValidateCustomOrderPropertiesPTBean', 1000, false, 'Validation fails if custom order level property group|key|value = order|validation|fail is given.')
	ON CONFLICT (id) DO NOTHING;



	--DECISION BEANS
	INSERT INTO oms."DecisionBeanDefDO"(id, description) values
		(10001, 'invoicingDecisionBean'),
		(20000, 'codPaymentDecisionBean'),
		(20001, 'maxOrderValueDecisionBean'),
		(30000, 'rmaApprovalDecisionBean'),
		(40000, 'shopTransmissionDecisionBean'),
		(41000, 'supplierTransmissionDecisionBean'),
		(50000, 'sendEmailDecisionBean')
	ON CONFLICT (id) DO NOTHING;



	--EXECUTION BEANS
	INSERT INTO oms."ExecutionBeanDefDO"(id, "decisionBeanDefRef", description) values
		(10000, null,  'shopMessageTransmitter'),
		(20000, null,  'supplierMessageTransmitter')
	ON CONFLICT (id) DO NOTHING;



	--ROUTING RULES
	INSERT INTO oms."OrderSupplierEvaluationRuleDefDO"(id, "name", "description", "rank", "mandatory") values
		(10000, 'SupplierHasStockCheckPTBean', 'Filters for suppliers that have stock to deliver.', 50, false)
	ON CONFLICT (id) DO NOTHING;



	--APPROVAL TYPES
	INSERT INTO oms."ApprovalTypeDefDO"(id, "name", "ObjectTypeName") values
		(10000, 'PaymentMethod',  'Order')
	ON CONFLICT (id) DO NOTHING;



	--TRANSFORMER BEANS
	INSERT INTO oms."TransformerBeanDefDO"(id, name) VALUES
		(1000, 'IcmToIomProductTransformer')
	ON CONFLICT (id) DO NOTHING;




--further examples

/*

	INSERT INTO oms."DocumentMapperDefDO"(id,name) values
		(1000, 'Example')
	ON CONFLICT (id) DO NOTHING;
		
	INSERT INTO oms."ExecutionBeanDefDO"(id, "decisionBeanDefRef", description) VALUES
		(1000, null, 'Example')
	ON CONFLICT (id) DO NOTHING;

	INSERT INTO oms."ExecutionBeanKeyDefDO"(
			id, "executionBeanDefRef", "parameterKey", "parameterTypeDefRef",
			mandatory, "defaultValue", "activeOMT") VALUES
		(11200, 1003, 'shopEmailAddress', 11, true, null, true),
		(11201, 1003, 'shopEmailSenderName', 11, false, null, true)
	ON CONFLICT (id) DO NOTHING;

	INSERT INTO oms."JobDefDO"(id, name, description) VALUES
		(1000, 'Example', 'Example')
	ON CONFLICT (id) DO NOTHING;

	INSERT INTO oms."MessageTypeDefDO"(id, name, description) VALUES
		(10500, 'Send customer mail - order', 'Send customer mail - order')
	ON CONFLICT (id) DO NOTHING;

	INSERT INTO oms."OrderSupplierEvaluationRuleDefDO"(id, description, mandatory, name, rank) VALUES
		(1000, 'Example', false, 'Example', 30)
	ON CONFLICT (id) DO NOTHING;

	INSERT INTO oms."TransmissionTypeDefDO"(id, name, "roleDefRef", description, "messageTypeName") VALUES
		(10500, 'Example', 6, 'Example', 'EXAMPLE')
	ON CONFLICT (id) DO NOTHING;

	INSERT INTO oms."EventDefDO"(id, description) VALUES
		(1001, 'EXAMPLE_EVENT_MANAGER_BEAN')
	ON CONFLICT (id) DO NOTHING;
*/
END;
$$;
