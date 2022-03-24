SET client_min_messages=error;
#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier

-- PAUSE velocity parser
#[[
-- local variables go here
internal_supplier_id int8 = 1;
shopId int8;
supplierId int8;
supplierIds int8[];
senderId int8;
receiverId int8;
order_transmitter varchar = 'customOrderMessageTransmitter';
order_decisionBean varchar = 'orderTransmissionDecisionBean';
supplier_transmitter varchar = 'supplierMessageTransmitter';
supplier_transmitter_key_res varchar = 'supplierMessageTransmitterRes';
supplier_transmitter_key_dis varchar = 'supplierMessageTransmitterDis';
supplier_transmitter_key_ret varchar = 'supplierMessageTransmitterRet';
supplier_decisionBean varchar = 'supplierTransmissionDecisionBean';
communicationId int8;
-- end variables block with
BEGIN

	-- ORDER EXPORT/TRANSMISSION
	-- REGISTER customOrderMessageTransmitter
	INSERT INTO oms."CommunicationDO"
	(
    	id,
		active,
		"activeOMT",
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
		null,
		order_transmitter,
		(SELECT id FROM oms."DocumentFormatDefDO" WHERE name = 'XML'),
    	(SELECT id FROM oms."ExecutionBeanDefDO" WHERE description = order_transmitter),
		(SELECT id FROM oms."TransmissionTypeDefDO" WHERE name = 'sendAnnounceOrder'),
		(SELECT id FROM oms."CommunicationVersionDefDO" WHERE "incomingURLParameter" = 'v1.0'),
		(SELECT id FROM oms."TransmissionFormDefDO" WHERE name = 'PUSH')
    WHERE 1 NOT IN (SELECT 1 FROM oms."CommunicationDO" where key = order_transmitter);

	communicationId := (SELECT id FROM oms."CommunicationDO" WHERE key = order_transmitter);

	-- CONFIGURE partners
	FOREACH shopId IN ARRAY shops_all LOOP
	
		-- iterate all suppliers of the shop and insert if not existing yet
		supplierIds := ARRAY(SELECT "supplierRef" FROM oms."Shop2SupplierDO" WHERE "shopRef" = shopId and "supplierRef" != internal_supplier_id);
		senderId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "shopRef" = shopId);

		FOREACH supplierId IN ARRAY supplierIds LOOP

			receiverId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "supplierRef" = supplierId);

			IF NOT EXISTS (SELECT * FROM "CommunicationPartnerDO"
				WHERE "sendingPartnerReferrerRef" = senderId
				AND "receivingPartnerReferrerRef" = receiverId				
				AND "communicationRef" = communicationId)
			THEN

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
					"mergeTypeDefRef",
					"splitTransmissionPerSupplier"
				)
				SELECT 
					nextval('"CommunicationPartnerDO_id_seq"'),
					null, --TODO fix exception   (SELECT id FROM oms."DecisionBeanDefDO" WHERE description = order_decisionBean), -- skip export ?
					false,
					communicationId,
					senderId,
					receiverId,
					5,
					'2m',
					null,
					false;

			END IF;

		END LOOP;
	
	END LOOP;



	-- RESPONSE EXPORT/TRANSMISSION
	-- REGISTER supplierMessageTransmitter for responses
	INSERT INTO oms."CommunicationDO"
	(
    	id,
		active,
		"activeOMT",
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
		null,
		supplier_transmitter_key_res,
		(SELECT id FROM oms."DocumentFormatDefDO" WHERE name = 'XML'),
    	(SELECT id FROM oms."ExecutionBeanDefDO" WHERE description = supplier_transmitter),
		(SELECT id FROM oms."TransmissionTypeDefDO" WHERE name = 'sendResponse'),
		(SELECT id FROM oms."CommunicationVersionDefDO" WHERE "incomingURLParameter" = 'v1.0'),
		(SELECT id FROM oms."TransmissionFormDefDO" WHERE name = 'PUSH')
    WHERE 1 NOT IN (SELECT 1 FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_res);

	communicationId := (SELECT id FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_res);

	-- CONFIGURE partners
	FOREACH shopId IN ARRAY shops_all LOOP
	
		-- iterate all suppliers of the shop and insert if not existing yet
		supplierIds := ARRAY(SELECT "supplierRef" FROM oms."Shop2SupplierDO" WHERE "shopRef" = shopId and "supplierRef" != internal_supplier_id);
		senderId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "shopRef" = shopId);

		FOREACH supplierId IN ARRAY supplierIds LOOP

			receiverId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "supplierRef" = supplierId);

			IF NOT EXISTS (SELECT * FROM "CommunicationPartnerDO"
				WHERE "sendingPartnerReferrerRef" = senderId
				AND "receivingPartnerReferrerRef" = receiverId				
				AND "communicationRef" = communicationId)
			THEN

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
					"mergeTypeDefRef",
					"splitTransmissionPerSupplier"
				)
				SELECT 
					nextval('"CommunicationPartnerDO_id_seq"'),
					null, --TODO fix exception   (SELECT id FROM oms."DecisionBeanDefDO" WHERE description = supplier_decisionBean), -- skip export ?
					false,
					communicationId,
					senderId,
					receiverId,
					5,
					'2m',
					null,
					false;

			END IF;

		END LOOP;
	
	END LOOP;



	-- DISPATCH EXPORT/TRANSMISSION
	-- REGISTER supplierMessageTransmitter for dispatches
	INSERT INTO oms."CommunicationDO"
	(
    	id,
		active,
		"activeOMT",
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
		null,
		supplier_transmitter_key_dis,
		(SELECT id FROM oms."DocumentFormatDefDO" WHERE name = 'XML'),
    	(SELECT id FROM oms."ExecutionBeanDefDO" WHERE description = supplier_transmitter),
		(SELECT id FROM oms."TransmissionTypeDefDO" WHERE name = 'sendDispatch'),
		(SELECT id FROM oms."CommunicationVersionDefDO" WHERE "incomingURLParameter" = 'v1.0'),
		(SELECT id FROM oms."TransmissionFormDefDO" WHERE name = 'PUSH')
    WHERE 1 NOT IN (SELECT 1 FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_dis);

	communicationId := (SELECT id FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_dis);

	-- CONFIGURE partners
	FOREACH shopId IN ARRAY shops_all LOOP
	
		-- iterate all suppliers of the shop and insert if not existing yet
		supplierIds := ARRAY(SELECT "supplierRef" FROM oms."Shop2SupplierDO" WHERE "shopRef" = shopId and "supplierRef" != internal_supplier_id);
		senderId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "shopRef" = shopId);

		FOREACH supplierId IN ARRAY supplierIds LOOP

			receiverId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "supplierRef" = supplierId);

			IF NOT EXISTS (SELECT * FROM "CommunicationPartnerDO"
				WHERE "sendingPartnerReferrerRef" = senderId
				AND "receivingPartnerReferrerRef" = receiverId				
				AND "communicationRef" = communicationId)
			THEN

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
					"mergeTypeDefRef",
					"splitTransmissionPerSupplier"
				)
				SELECT 
					nextval('"CommunicationPartnerDO_id_seq"'),
					null, --TODO fix exception   (SELECT id FROM oms."DecisionBeanDefDO" WHERE description = supplier_decisionBean), -- skip export ?
					false,
					communicationId,
					senderId,
					receiverId,
					5,
					'2m',
					null,
					false;

			END IF;

		END LOOP;
	
	END LOOP;



	-- RETURN EXPORT/TRANSMISSION
	-- REGISTER supplierMessageTransmitter for returns
	INSERT INTO oms."CommunicationDO"
	(
    	id,
		active,
		"activeOMT",
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
		null,
		supplier_transmitter_key_ret,
		(SELECT id FROM oms."DocumentFormatDefDO" WHERE name = 'XML'),
    	(SELECT id FROM oms."ExecutionBeanDefDO" WHERE description = supplier_transmitter),
		(SELECT id FROM oms."TransmissionTypeDefDO" WHERE name = 'sendReturn'),
		(SELECT id FROM oms."CommunicationVersionDefDO" WHERE "incomingURLParameter" = 'v1.0'),
		(SELECT id FROM oms."TransmissionFormDefDO" WHERE name = 'PUSH')
    WHERE 1 NOT IN (SELECT 1 FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_ret);

	communicationId := (SELECT id FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_ret);

	-- CONFIGURE partners
	FOREACH shopId IN ARRAY shops_all LOOP
	
		-- iterate all suppliers of the shop and insert if not existing yet
		supplierIds := ARRAY(SELECT "supplierRef" FROM oms."Shop2SupplierDO" WHERE "shopRef" = shopId and "supplierRef" != internal_supplier_id);
		senderId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "shopRef" = shopId);

		FOREACH supplierId IN ARRAY supplierIds LOOP

			receiverId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "supplierRef" = supplierId);

			IF NOT EXISTS (SELECT * FROM "CommunicationPartnerDO"
				WHERE "sendingPartnerReferrerRef" = senderId
				AND "receivingPartnerReferrerRef" = receiverId				
				AND "communicationRef" = communicationId)
			THEN

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
					"mergeTypeDefRef",
					"splitTransmissionPerSupplier"
				)
				SELECT 
					nextval('"CommunicationPartnerDO_id_seq"'),
					null, --TODO fix exception   (SELECT id FROM oms."DecisionBeanDefDO" WHERE description = supplier_decisionBean), -- skip export ?
					false,
					communicationId,
					senderId,
					receiverId,
					5,
					'2m',
					null,
					false;

			END IF;

		END LOOP;
	
	END LOOP;
	
	
END;
]]#
-- dollar quoting
$do;