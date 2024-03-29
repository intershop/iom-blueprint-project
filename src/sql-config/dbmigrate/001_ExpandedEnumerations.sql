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
		(20000, null,  'supplierMessageTransmitter'),
		(30000, null,  'customMailTransmitter')
	ON CONFLICT (id) DO NOTHING;

	--KEYS
	INSERT INTO oms."ExecutionBeanKeyDefDO"(
			id, "executionBeanDefRef", "parameterKey", "parameterTypeDefRef",
			mandatory, "defaultValue") VALUES
		(10001, 30000, 'mimeType', 2 /* MIMETYPE */, true, null),
		(10002, 30000, 'shopEmailAddress', 4 /* EMAIL */, false, null),
		(10003, 30000, 'shopEmailSenderName', 11 /* STRING */, false, null)
	ON CONFLICT (id) DO NOTHING;

	--TRANSFORMER BEANS
	INSERT INTO oms."TransformerBeanDefDO"(id, name) VALUES
		(10000, 'BlueprintIcmTransformer'),
		(10200, 'OpenTransDispatchTransformer')
	ON CONFLICT (id) DO NOTHING;

	--ROUTING RULES
	INSERT INTO oms."OrderSupplierEvaluationRuleDefDO"(id, "name", "description", "rank", "mandatory") values
		(10000, 'SupplierHasStockCheckPTBean', 'Filters for suppliers that have stock to deliver.', 50, false)
	ON CONFLICT (id) DO NOTHING;

	--APPROVAL TYPES
	INSERT INTO oms."ApprovalTypeDefDO"(id, "name", "ObjectTypeName") values
		(10000, 'PaymentMethod',  'Order')
	ON CONFLICT (id) DO NOTHING;

	--MESSAGE TYPES
	INSERT INTO oms."MessageTypeDefDO"(id, name, description) VALUES
		(10000, 'Approval notification', 'Approval notification')
	ON CONFLICT (id) DO NOTHING;

	--TRANSMISSION TYPES
	INSERT INTO oms."TransmissionTypeDefDO"(id, name, "roleDefRef", description, "messageTypeName") VALUES
		(10000, 'E-mail approval notification', 2 /* BAKERY|OMS */, 'Approval notification e-mail.', 'example ShopCustomerMailTransmissionDO.class')
	ON CONFLICT (id) DO NOTHING;

	--CHARGE TYPES
	INSERT INTO oms."ChargeTypeDefDO"(id, name, description, "chargeType") VALUES
		(10000, 'Container Service Charge', 'Container Service Charge', 'Container Service Charge')
	ON CONFLICT (id) DO NOTHING;



	--TRANSFORMER BEANS
	INSERT INTO oms."TransformerBeanDefDO"(id, name) VALUES
		(10000, 'BlueprintIcmTransformer'),
		(10200, 'OpenTransDispatchTransformer')
	ON CONFLICT (id) DO NOTHING;



--further examples

/*

	INSERT INTO oms."DocumentMapperDefDO"(id,name) values
		(10000, 'Example')
	ON CONFLICT (id) DO NOTHING;
		
	INSERT INTO oms."ExecutionBeanDefDO"(id, "decisionBeanDefRef", description) VALUES
		(10000, null, 'Example')
	ON CONFLICT (id) DO NOTHING;
  
	INSERT INTO oms."JobDefDO"(id, name, description) VALUES
		(10000, 'Example', 'Example')
	ON CONFLICT (id) DO NOTHING;

	INSERT INTO oms."OrderSupplierEvaluationRuleDefDO"(id, description, mandatory, name, rank) VALUES
		(10000, 'Example', false, 'Example', 30)
	ON CONFLICT (id) DO NOTHING;

	INSERT INTO oms."EventDefDO"(id, description) VALUES
		(10000, 'EXAMPLE_EVENT_MANAGER_BEAN')
	ON CONFLICT (id) DO NOTHING;

*/

END;
$$;
