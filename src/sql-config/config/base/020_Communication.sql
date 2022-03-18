SET client_min_messages=error;
#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier

-- PAUSE velocity parser
#[[
-- local variables go here
shopId int8;
supplierId int8;
supplierIds int8[];
senderId int8;
receiverId int8;
transmitter varchar = 'customOrderMessageTransmitter';
-- end variables block with
BEGIN

	/*
	TODOS:
		-  *CHECK* have all required PartnerReferrerDO (who is an actor and which role he has)

		- have CommunicationDO for order export (which type/form of communication is supported)
			<-- have ext. ExecutionBeanDefDO ! 10000
			<-- have ext. decision bean ?
		- have all required CommunicationPartnerDO (who is sending/receiving which type/form of information in which way and how often to retry)
		- configure execution of order export / + DecisionBean (TBI)
	*/

	-- insert the transmitter if not existing yet
	IF 0 = (SELECT count(*) FROM oms."CommunicationDO" WHERE key = transmitter)
	THEN
		INSERT INTO oms."ExecutionBeanDefDO"
			(id, "decisionBeanDefRef", description)
		VALUES
			(10000, null, transmitter);
	END IF;

	-- register the customOrderMessageTransmitter
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
		transmitter,
		(SELECT id FROM oms."DocumentFormatDefDO" WHERE name = 'XML'),
    	(SELECT id FROM oms."ExecutionBeanDefDO" WHERE description = transmitter),
		(SELECT id FROM oms."TransmissionTypeDefDO" WHERE name = 'sendAnnounceOrder'),
		(SELECT id FROM oms."CommunicationVersionDefDO" WHERE "incomingURLParameter" = 'v1.0'),
		(SELECT id FROM oms."TransmissionFormDefDO" WHERE name = 'PUSH')
    WHERE 1 NOT IN (SELECT 1 FROM oms."CommunicationDO" where key = transmitter);

	-- enable customOrderMessageTransmitter for both shops and it's suppliers
	FOREACH shopId IN ARRAY shops_all LOOP
	
		-- iterate all suppliers of the shop and insert if not existing yet
		supplierIds := ARRAY(SELECT id FROM oms."Shop2SupplierDO" WHERE "shopRef" = shopId);
		senderId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "shopRef" = shopId);

		FOREACH supplierId IN ARRAY supplierIds LOOP

			receiverId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "supplierRef" = supplierId);

			IF NOT EXISTS (SELECT * FROM "CommunicationPartnerDO"
				WHERE "receivingPartnerReferrerRef" = senderId
				AND "sendingPartnerReferrerRef" = receiverId
				AND "communicationRef" = (SELECT id FROM oms."CommunicationDO" WHERE key = transmitter))
			THEN

				INSERT INTO oms."CommunicationPartnerDO"
				(
					id,
					"decisionBeanDefRef",
					"splitTransmission",
					"communicationRef",
					"receivingPartnerReferrerRef",
					"sendingPartnerReferrerRef",
					"maxNoOfRetries",
					"retryDelay",
					"mergeTypeDefRef",
					"splitTransmissionPerSupplier"
				)
				SELECT 
					nextval('"CommunicationPartnerDO_id_seq"'),
					null, -- TODO to skip the export by order property
					false,
					(SELECT id FROM oms."CommunicationDO" WHERE key = transmitter),
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