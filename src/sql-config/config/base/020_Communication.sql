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
shopId int8;
supplierId int8;
supplierIds int8[];
senderId int8;
receiverId int8;

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
		k_shop_transmitter_order,
		id_docformat_xml,
    	eb_shop_transmitter,
		id_transtype_sendorder,
		id_commversion_1,
		id_transform_push
    WHERE NOT EXISTS (SELECT * FROM oms."CommunicationDO" WHERE key = k_shop_transmitter_order AND "transmissionTypeDefRef" = id_transtype_sendorder);

	communicationId := (SELECT id FROM oms."CommunicationDO" WHERE key = k_shop_transmitter_order AND "transmissionTypeDefRef" = id_transtype_sendorder);

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
					false;

			END IF;

		END LOOP;
	
	END LOOP;



	-- RETURN ANNOUNCEMENT EXPORT/TRANSMISSION
	-- REGISTER shopMessageTransmitter
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
		k_shop_transmitter_rma,
		id_docformat_xml,
    	eb_shop_transmitter,
		id_transtype_sendrma,
		id_commversion_1,
		id_transform_push
    WHERE NOT EXISTS (SELECT * FROM oms."CommunicationDO" where key = k_shop_transmitter_rma AND "transmissionTypeDefRef" = id_transtype_sendrma);

	communicationId := (SELECT id FROM oms."CommunicationDO" WHERE key = k_shop_transmitter_rma AND "transmissionTypeDefRef" = id_transtype_sendrma);

	-- CONFIGURE partners
	FOREACH shopId IN ARRAY shops_all LOOP
	
		senderId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "shopRef" = shopId);
		IF NOT EXISTS (SELECT * FROM "CommunicationPartnerDO"
			WHERE "sendingPartnerReferrerRef" = senderId
			AND "receivingPartnerReferrerRef" = NULL	-- NULL, because no supplier is assigned to be checked				
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
				false;

			END IF;
	
	END LOOP;



	/*
		SUPPLIER MESSAGES
	*/

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
		id_docformat_xml,
    	eb_supplier_transmitter,
		id_transtype_sendresponse,
		id_commversion_1,
		id_transform_push
    WHERE NOT EXISTS (SELECT * FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_res);

	communicationId := (SELECT id FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_res);

	-- CONFIGURE partners
	FOREACH shopId IN ARRAY shops_all LOOP
	
		-- iterate all suppliers of the shop and insert if not existing yet
		supplierIds := ARRAY(SELECT "supplierRef" FROM oms."Shop2SupplierDO" WHERE "shopRef" = shopId and "supplierRef" != internal_supplier_id);
		--senderId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "shopRef" = shopId);

		FOREACH supplierId IN ARRAY supplierIds LOOP

			senderId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "supplierRef" = supplierId);

			IF NOT EXISTS (SELECT * FROM "CommunicationPartnerDO"
				WHERE "sendingPartnerReferrerRef" = senderId			
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
		id_docformat_xml,
    	eb_supplier_transmitter,
		id_transtype_senddispatch,
		id_commversion_1,
		id_transform_push
    WHERE NOT EXISTS (SELECT * FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_dis);

	communicationId := (SELECT id FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_dis);

	-- CONFIGURE partners
	FOREACH shopId IN ARRAY shops_all LOOP
	
		-- iterate all suppliers of the shop and insert if not existing yet
		supplierIds := ARRAY(SELECT "supplierRef" FROM oms."Shop2SupplierDO" WHERE "shopRef" = shopId and "supplierRef" != internal_supplier_id);
		--senderId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "shopRef" = shopId);

		FOREACH supplierId IN ARRAY supplierIds LOOP

			senderId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "supplierRef" = supplierId);

			IF NOT EXISTS (SELECT * FROM "CommunicationPartnerDO"
				WHERE "sendingPartnerReferrerRef" = senderId				
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
		id_docformat_xml,
    	eb_supplier_transmitter,
		id_transtype_sendreturn,
		id_commversion_1,
		id_transform_push
    WHERE NOT EXISTS (SELECT * FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_ret);

	communicationId := (SELECT id FROM oms."CommunicationDO" WHERE key = supplier_transmitter_key_ret);

	-- CONFIGURE partners
	FOREACH shopId IN ARRAY shops_all LOOP
	
		-- iterate all suppliers of the shop and insert if not existing yet
		supplierIds := ARRAY(SELECT "supplierRef" FROM oms."Shop2SupplierDO" WHERE "shopRef" = shopId and "supplierRef" != internal_supplier_id);
		
		FOREACH supplierId IN ARRAY supplierIds LOOP

			senderId := (SELECT id FROM oms."PartnerReferrerDO" WHERE "supplierRef" = supplierId);

			IF NOT EXISTS (SELECT * FROM "CommunicationPartnerDO"
				WHERE "sendingPartnerReferrerRef" = senderId				
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
					false;

			END IF;

		END LOOP;
	
	END LOOP;


	
END;
]]#
-- dollar quoting
$do;