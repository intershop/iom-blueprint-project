#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier
$vars_decision_beans

-- PAUSE velocity parser
#[[

-- local variables go here
-- general vars DO NOT MODIFY

enabled  constant text := 'true';
disabled constant text := 'false';

--executionBeanKeyDefRefs:
ebv_senderAddress   constant int8 := 1200;
ebv_senderName      constant int8 := 1201;
ebv_subjectTemplate constant int8 := 1204;
ebv_messageTemplate constant int8 := 1205;
ebv_mimeType        constant int8 := 1207;

-- configurable vars
-- shop: id, sender address, sender name
info_intronics_b2c constant text[] := ARRAY[shop_intronics_b2c::text, 'info@intershop.de', 'inTRONICS'];
info_intronics_b2b constant text[] := ARRAY[shop_intronics_b2b::text, 'info@intershop.de', 'inTRONICS Business'];

--"in loop" variables
rec record;
shopRef int8;
senderAddress varchar;
senderName varchar;
_active boolean;

transmissionType_id int8;
subjectTemplate varchar;
messageTemplate varchar;
queueName varchar;

eventRegistryEntry_id int8;
shop_partner_id int8;
CommunicationDO_id int8;
communicationPartner_id int8;
ProcessesDO_id int8;

BEGIN

FOR rec in SELECT * FROM (VALUES 
		-- 1-3: shop info
		-- 4: active?
		-- 5-8: transmissionType.id, subject template, message template, queueName

		-- on order confirmation
		(info_intronics_b2c || enabled || ARRAY['500','IT_orderSubject.vm', 'IT_orderMessage.vm', 'CheckOrderQueue']),
		(info_intronics_b2b || enabled || ARRAY['500','IB_orderSubject.vm', 'IB_orderMessage.vm', 'CheckOrderQueue']),
		-- on dispatch
		(info_intronics_b2c || enabled || ARRAY['530','IT_dispatchSubject.vm', 'IT_dispatchMessage.vm', 'CloseDispatchQueue']),
		(info_intronics_b2b || enabled || ARRAY['530','IB_dispatchSubject.vm', 'IB_dispatchMessage.vm', 'CloseDispatchQueue']),
		-- on invoice
		(info_intronics_b2c || enabled || ARRAY['570','IT_invoiceSubject.vm', 'IT_invoiceMessage.vm', 'InvoicingTransmissionSyncQueue']),
		(info_intronics_b2b || enabled || ARRAY['570','IB_invoiceSubject.vm', 'IB_invoiceMessage.vm', 'InvoicingTransmissionSyncQueue']),
		-- on cancel, recall, returns
		(info_intronics_b2c || enabled || ARRAY['540','IT_returnSubject_can_rcl.vm', 'IT_returnMessage_can_rcl.vm', 'CloseReturnQueue']),
		(info_intronics_b2b || enabled || ARRAY['540','IB_returnSubject_can_rcl.vm', 'IB_returnMessage_can_rcl.vm', 'CloseReturnQueue']),
		(info_intronics_b2c || enabled || ARRAY['541','IT_returnSubject_can_rcl.vm', 'IT_returnMessage_can_rcl.vm', 'CloseReturnQueue']),
		(info_intronics_b2b || enabled || ARRAY['541','IB_returnSubject_can_rcl.vm', 'IB_returnMessage_can_rcl.vm', 'CloseReturnQueue']),
		(info_intronics_b2c || enabled || ARRAY['543','IT_returnSubject_ret_def_inv.vm', 'IT_returnMessage_ret_def_inv.vm', 'CloseReturnQueue']),
		(info_intronics_b2b || enabled || ARRAY['543','IB_returnSubject_ret_def_inv.vm', 'IB_returnMessage_ret_def_inv.vm', 'CloseReturnQueue']),

		-- return label mail via omt, triggered via GUI and couldn't be registered as event
		(info_intronics_b2c || enabled || ARRAY['713','IT_returnLabelSubject.vm', 'IT_returnLabelMessage.vm', null]), 
		(info_intronics_b2b || enabled || ARRAY['713','IB_returnLabelSubject.vm', 'IB_returnLabelMessage.vm', null])

		-- rma
		--,(info_intronics_b2c || enabled || ARRAY['715','returnAnnouncementSubject.vm', 'returnAnnouncementMessage.vm', null])
		--,(info_intronics_b2b || enabled || ARRAY['715','returnAnnouncementSubject.vm', 'returnAnnouncementMessage.vm', null])
	) AS t (data) --name alias for the result
	
LOOP  
	shopRef          := rec.data[1]::int8;
	senderAddress    := rec.data[2];
	senderName       := rec.data[3];

	_active          := rec.data[4]::boolean;

	transmissionType_id := rec.data[5]::int8;
	subjectTemplate  := rec.data[6];
	messageTemplate  := rec.data[7];
	queueName        := rec.data[8];
	
	shop_partner_id =(select id from "PartnerReferrerDO" where "shopRef" = shopRef);

	IF queueName is not null THEN
		-- Event registry configuration --> Trigger Mail Event Manager
		/*
			eventDefRef = 1 (EventDefDO.MAIL_EVENT_MANAGER)
		*/
		ProcessesDO_id=(select id from "ProcessesDO" where "processDefRef" = (select id from "ProcessDefDO" where "queueName" = queueName));
		
		INSERT INTO "EventRegistryEntryDO" (
			"id","creationDate","modificationDate",
			"processesRef","version",
			"eventDefRef","shopRef","description")
		SELECT
			nextval('"EventRegistryEntryDO_id_seq"'),CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,
			ProcessesDO_id, 1,
			1, shopRef, 'Mail Events on ' || queueName
		WHERE NOT EXISTS(
			select * from "EventRegistryEntryDO" 
			where "processesRef" = ProcessesDO_id
			and "eventDefRef" = 1 
			and "shopRef" = shopRef
		);

		eventRegistryEntry_id = (select id from "EventRegistryEntryDO"
										 where "processesRef"=ProcessesDO_id 
										 and "eventDefRef"=1 
										 and "shopRef"=shopRef);

		-- Mail Event Registry Configuration
		/*
			mailEventDefRef = 1     (MailEventDefDO.SEND_SHOP_CUSTOMER_MAIL_PC)
			(core) decisionBeanDefRef = 50 (DecisionBeanDefDO.SEND_EMAIL_DECIDER_BEAN) -> SendEmailDeciderBean.java
			(custom) decisionBeanDefRef = 50000 (ExpandedDecisionBeanDefDO.SEND_EMAIL_DECISION_BEAN) -> SendEmailDecisionBean.java
			transmissionTypeDefRef = transmissionType_id (see TransmissionTypeDefDO)
		*/
		INSERT INTO "MailEventRegistryEntryDO"(
				id, version, "creationDate", "modificationDate", active,
				"eventRegistryEntryRef",
				"mailEventDefRef", "decisionBeanDefRef", "transmissionTypeDefRef")
				SELECT
				nextval('"MailEventRegistryEntryDO_id_seq"'), 0, now(), now(), true,
				eventRegistryEntry_id,
				1, db_send_email, transmissionType_id -- "mailEventDefRef", "decisionBeanDefRef", "transmissionTypeDefRef"
				WHERE NOT EXISTS
				(
					SELECT * FROM "MailEventRegistryEntryDO" 
					WHERE "eventRegistryEntryRef" = eventRegistryEntry_id
					AND "mailEventDefRef" = 1
					AND "transmissionTypeDefRef" = transmissionType_id
				);
		IF NOT FOUND THEN --the entry already existed, possibly update it.
			UPDATE "MailEventRegistryEntryDO" SET active = _active 
			WHERE "eventRegistryEntryRef" = eventRegistryEntry_id
			AND "mailEventDefRef" = 1
			AND "transmissionTypeDefRef" = transmissionType_id;
		END IF;

	END IF;  -- /IF queueName is not null

	-- Transmission parameters

	-- TransmissionConfig Order Mail
	-- transmissionTypeDefRef = transmissionType_id (TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_ORDER) -> "sendCustomerMailOrder", RoleDefDO.CUSTOMER, MessageTypeDefDO.SEND_CUSTOMER_MAIL_ORDER
	
	CommunicationDO_id = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType_id);

	INSERT INTO "CommunicationPartnerDO"(id, 
			"decisionBeanDefRef", "splitTransmission", "communicationRef",
			"receivingPartnerReferrerRef", "sendingPartnerReferrerRef", 
			"maxNoOfRetries", "retryDelay")
		SELECT nextval('"CommunicationPartnerDO_id_seq"'), 
			null, false, CommunicationDO_id,
			null, shop_partner_id, 
			12, '30m'
		WHERE NOT EXISTS (
			select * FROM "CommunicationPartnerDO" 
			where "communicationRef" = CommunicationDO_id
			and "sendingPartnerReferrerRef" = shop_partner_id
			and "receivingPartnerReferrerRef" is null
		 );
		
	communicationPartner_id = (select id from "CommunicationPartnerDO" 
                              where "communicationRef" = CommunicationDO_id 
                              and "sendingPartnerReferrerRef" = shop_partner_id 
                              and "receivingPartnerReferrerRef" is null);
		
	/*ExecutionBeanValueDO:
	  help FUNCTION defined in dbmigrate
		oms.upsert_eb_value(
		 p_executionbeankeydefref bigint,
		 p_parametervalue text,
		 p_communicationpartnerref bigint)
	*/
	
	PERFORM oms.upsert_eb_value( ebv_senderAddress, senderAddress, communicationPartner_id );
	PERFORM oms.upsert_eb_value( ebv_senderName, senderName, communicationPartner_id );
	PERFORM oms.upsert_eb_value( ebv_subjectTemplate, subjectTemplate, communicationPartner_id );
	PERFORM oms.upsert_eb_value( ebv_messageTemplate, messageTemplate, communicationPartner_id );
	PERFORM oms.upsert_eb_value( ebv_mimeType, 'text/html', communicationPartner_id );

END LOOP;


END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;