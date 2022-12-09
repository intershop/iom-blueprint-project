SET client_min_messages=error;
#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier
$vars_execution_beans
$vars_decision_beans

-- PAUSE velocity parser
#[[
-- local variables go here
internal_supplier_id int8 = 1;

-- keys
k_shop_transmitter_order varchar = 'shopMessageTransmitterOrder';
k_shop_transmitter_rma varchar = 'shopMessageTransmitterRMA';
supplier_transmitter_key_res varchar = 'supplierMessageTransmitterRes';
supplier_transmitter_key_dis varchar = 'supplierMessageTransmitterDis';
supplier_transmitter_key_ret varchar = 'supplierMessageTransmitterRet';
communicationId int8;

-- ids (instead of subselects)
id_docformat_xml int8 = 2; 				-- see oms."DocumentFormatDefDO"
id_commversion_1 int8 = 1; 				-- see oms."CommunicationVersionDefDO"
id_transform_push int8 = 10; 			-- see oms."TransmissionFormDefDO"
id_transtype_sendorder int8 = 10;		-- see oms."TransmissionTypeDefDO"
id_transtype_sendresponse int8 = 40;	-- see oms."TransmissionTypeDefDO"
id_transtype_senddispatch int8 = 80;	-- see oms."TransmissionTypeDefDO"
id_transtype_sendrma int8 = 64;			-- see oms."TransmissionTypeDefDO"
id_transtype_sendreturn int8 = 60;		-- see oms."TransmissionTypeDefDO"

-- end variables block with
BEGIN



	/*
		SHOP MESSAGES
	*/

	-- ORDER EXPORT/TRANSMISSION
	-- REGISTER shopMessageTransmitter

	INSERT INTO oms."CommunicationDO"
	(
		id,
		active,
		key,
		"documentFormatDefRef",
		"executionBeanDefRef",
		"transmissionTypeDefRef",
		"communicationVersionDefRef",
		"transmissionFormDefRef"
	)
	SELECT
		nextval('"CommunicationDO_id_seq"'),
		true,
		k_shop_transmitter_order,
		id_docformat_xml,
		eb_shop_transmitter,
		id_transtype_sendorder,
		id_commversion_1,
		id_transform_push
	WHERE NOT EXISTS (SELECT * FROM oms."CommunicationDO" WHERE key = k_shop_transmitter_order AND "transmissionTypeDefRef" = id_transtype_sendorder);

	communicationId := (SELECT id FROM oms."CommunicationDO" WHERE key = k_shop_transmitter_order AND "transmissionTypeDefRef" = id_transtype_sendorder);

	-- CONFIGURE partners (sending shops, receiving suppliers)

		INSERT INTO oms."CommunicationPartnerDO"
		(
			id,
			"decisionBeanDefRef",
			"splitTransmission",
			"communicationRef",
			"sendingPartnerReferrerRef",
			"receivingPartnerReferrerRef",
			"maxNoOfRetries",
			"retryDelay",
			"splitTransmissionPerSupplier"
		)
		SELECT 
			nextval('"CommunicationPartnerDO_id_seq"'),
			db_shop_transmission,	-- skip export ?
			false,
			communicationId,
			senderId,				-- a shop
			receiverId,				-- a supplier
			5,
			'2m',
			false 
		FROM (
			SELECT senders.id as senderId, receivers.id as receiverId
			FROM oms."Shop2SupplierDO" s2s
			JOIN oms."PartnerReferrerDO" senders   ON( s2s."shopRef"=senders."shopRef")
			JOIN oms."PartnerReferrerDO" receivers ON( s2s."supplierRef"=receivers."supplierRef")
			WHERE s2s."shopRef" = ANY(shops_all)
			AND s2s."supplierRef"!= internal_supplier_id
			AND (senders.id, receivers.id) NOT IN --idempotency
					(select "sendingPartnerReferrerRef", "receivingPartnerReferrerRef"
					 from "CommunicationPartnerDO" 
					 where "communicationRef" = communicationId)
		) partners;
				



	-- RETURN ANNOUNCEMENT EXPORT/TRANSMISSION
	-- REGISTER shopMessageTransmitter
	INSERT INTO oms."CommunicationDO"
	(
		id,
		active,
		key,
		"documentFormatDefRef",
		"executionBeanDefRef",
		"transmissionTypeDefRef",
		"communicationVersionDefRef",
		"transmissionFormDefRef"
	)
	SELECT
		nextval('"CommunicationDO_id_seq"'),
		true,
		k_shop_transmitter_rma,
		id_docformat_xml,
		eb_shop_transmitter,
		id_transtype_sendrma,
		id_commversion_1,
		id_transform_push
	WHERE NOT EXISTS (SELECT * FROM oms."CommunicationDO" where key = k_shop_transmitter_rma AND "transmissionTypeDefRef" = id_transtype_sendrma);

	communicationId := (SELECT id FROM oms."CommunicationDO" WHERE key = k_shop_transmitter_rma AND "transmissionTypeDefRef" = id_transtype_sendrma);

	-- CONFIGURE partners (sending shops)
	INSERT INTO oms."CommunicationPartnerDO"
	(
		id,
		"decisionBeanDefRef",
		"splitTransmission",
		"communicationRef",
		"sendingPartnerReferrerRef",
		"receivingPartnerReferrerRef",
		"maxNoOfRetries",
		"retryDelay",
		"splitTransmissionPerSupplier"
	)
	SELECT 
		nextval('"CommunicationPartnerDO_id_seq"'),
		db_shop_transmission, 	-- skip export ?
		false,
		communicationId,
		senderId,				-- a shop
		NULL,					-- NULL, because no supplier is assigned to be checked
		5,
		'2m',
		false
	FROM (
		SELECT senders.id as senderId
		FROM oms."PartnerReferrerDO" senders 
		WHERE senders."shopRef" = ANY(shops_all)
		AND senders.id NOT IN --idempotency
				(select "sendingPartnerReferrerRef"
				 from "CommunicationPartnerDO"
				 where "communicationRef" = communicationId
				 and   "receivingPartnerReferrerRef" IS NULL)	
	) partners;




	/*
		SUPPLIER MESSAGES
	*/

	-- RESPONSE EXPORT/TRANSMISSION
	-- REGISTER supplierMessageTransmitter for responses
	INSERT INTO oms."CommunicationDO"
	(
		id,
		active,
		key,
		"documentFormatDefRef",
		"executionBeanDefRef",
		"transmissionTypeDefRef",
		"communicationVersionDefRef",
		"transmissionFormDefRef"
	)
	SELECT
		nextval('"CommunicationDO_id_seq"'),
		true,
		supplier_transmitter_key_res,
		id_docformat_xml,
		eb_supplier_transmitter,
		id_transtype_sendresponse,
		id_commversion_1,
		id_transform_push
	WHERE NOT EXISTS (SELECT * FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_res);

	communicationId := (SELECT id FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_res);

	-- CONFIGURE communication partners (sending suppliers)
	INSERT INTO oms."CommunicationPartnerDO"
	(
		id,
		"decisionBeanDefRef",
		"splitTransmission",
		"communicationRef",
		"sendingPartnerReferrerRef",
		"receivingPartnerReferrerRef",
		"maxNoOfRetries",
		"retryDelay",
		"splitTransmissionPerSupplier"
	)
	SELECT 
		nextval('"CommunicationPartnerDO_id_seq"'),
		db_supplier_transmission, 	-- skip export ?
		false,
		communicationId,
		senderId, 					-- a supplier
		null,
		5,
		'2m',
		false
	FROM (
		SELECT DISTINCT senders.id as senderId
		FROM oms."PartnerReferrerDO" senders 
		JOIN oms."Shop2SupplierDO" s2s ON (s2s."supplierRef"=senders."supplierRef")
		WHERE s2s."shopRef" = ANY(shops_all)
		  AND s2s."supplierRef"!= internal_supplier_id
		AND senders.id NOT IN  --idempotency
				(select "sendingPartnerReferrerRef"
				 from "CommunicationPartnerDO" 
				 where "communicationRef" = communicationId
				 and   "receivingPartnerReferrerRef" IS NULL)	
	) partners;




	-- DISPATCH EXPORT/TRANSMISSION
	-- REGISTER supplierMessageTransmitter for dispatches
	INSERT INTO oms."CommunicationDO"
	(
		id,
		active,
		key,
		"documentFormatDefRef",
		"executionBeanDefRef",
		"transmissionTypeDefRef",
		"communicationVersionDefRef",
		"transmissionFormDefRef"
	)
	SELECT
		nextval('"CommunicationDO_id_seq"'),
		true,
		supplier_transmitter_key_dis,
		id_docformat_xml,
		eb_supplier_transmitter,
		id_transtype_senddispatch,
		id_commversion_1,
		id_transform_push
	WHERE NOT EXISTS (SELECT * FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_dis);

	communicationId := (SELECT id FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_dis);

	-- CONFIGURE communication partners (sending suppliers)
		INSERT INTO oms."CommunicationPartnerDO"
		(
			id,
			"decisionBeanDefRef",
			"splitTransmission",
			"communicationRef",
			"sendingPartnerReferrerRef",
			"receivingPartnerReferrerRef",
			"maxNoOfRetries",
			"retryDelay",
			"splitTransmissionPerSupplier"
		)
		SELECT
			nextval('"CommunicationPartnerDO_id_seq"'),
			db_supplier_transmission, 	-- skip export ?
			false,
			communicationId,
			senderId,					-- a supplier
			null,
			5,
			'2m',
			false
		FROM (
			SELECT DISTINCT senders.id as senderId
			FROM oms."PartnerReferrerDO" senders 
			JOIN oms."Shop2SupplierDO" s2s ON (s2s."supplierRef"=senders."supplierRef")
			WHERE s2s."shopRef" = ANY(shops_all)
			  AND s2s."supplierRef"!= internal_supplier_id
			AND senders.id NOT IN  --idempotency
					(select "sendingPartnerReferrerRef"
					 from "CommunicationPartnerDO" 
					 where "communicationRef" = communicationId
					 and   "receivingPartnerReferrerRef" IS NULL)	
		) partners;


	-- RETURN EXPORT/TRANSMISSION
	-- REGISTER supplierMessageTransmitter for returns
	INSERT INTO oms."CommunicationDO"
	(
		id,
		active,
		key,
		"documentFormatDefRef",
		"executionBeanDefRef",
		"transmissionTypeDefRef",
		"communicationVersionDefRef",
		"transmissionFormDefRef"
	)
	SELECT
		nextval('"CommunicationDO_id_seq"'),
		true,
		supplier_transmitter_key_ret,
		id_docformat_xml,
		eb_supplier_transmitter,
		id_transtype_sendreturn,
		id_commversion_1,
		id_transform_push
	WHERE NOT EXISTS (SELECT * FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_ret);

	communicationId := (SELECT id FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_ret);

	-- CONFIGURE communication partners (sending suppliers)
	INSERT INTO oms."CommunicationPartnerDO"
	(
		id,
		"decisionBeanDefRef",
		"splitTransmission",
		"communicationRef",
		"sendingPartnerReferrerRef",
		"receivingPartnerReferrerRef",
		"maxNoOfRetries",
		"retryDelay",
		"splitTransmissionPerSupplier"
	)
	SELECT 
		nextval('"CommunicationPartnerDO_id_seq"'),
		db_supplier_transmission, 	-- skip export ?
		false,
		communicationId,
		senderId, 					-- a supplier
		null,
		5,
		'2m',
		false
	FROM (
		SELECT DISTINCT senders.id as senderId
		FROM oms."PartnerReferrerDO" senders 
		JOIN oms."Shop2SupplierDO" s2s ON (s2s."supplierRef"=senders."supplierRef")
		WHERE s2s."shopRef" = ANY(shops_all)
		  AND s2s."supplierRef"!= internal_supplier_id
		AND senders.id NOT IN  --idempotency
				(select "sendingPartnerReferrerRef"
				 from "CommunicationPartnerDO"
				 where "communicationRef" = communicationId
				 and   "receivingPartnerReferrerRef" IS NULL)
	) partners;


	
END;
]]#
-- dollar quoting
$do;