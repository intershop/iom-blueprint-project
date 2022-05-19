#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier
$vars_decision_beans

-- PAUSE velocity parser
#[[

-- local variables go here
-- general vars DO NOT MODIFY
shopRef int8;
senderAddress varchar;
senderName varchar;
_active boolean;
transmissionTypeToTemplates varchar[];
transmissionType int8;
subjectTemplate varchar;
messageTemplate varchar;
queueName varchar;
enabled varchar = 'true';
disabled varchar = 'false';

ebv_senderAddress int8 := 1200;
ebv_senderName int8 := 1201;
ebv_subjectTemplate int8 := 1204;
ebv_messageTemplate int8 := 1205;
ebv_mimeType int8 := 1207;

_null varchar;
-- end variables block with 
BEGIN

-- configurable vars
-- shop: id, sender address, sender name
email_intronics varchar[] = ARRAY[shop_intronics::text, 'info@intershop.de', 'inTRONICS'];
email_intronics_b2b varchar[] = ARRAY[shop_intronics_b2b::text, 'info@intershop.de', 'inTRONICS Business'];

-- transmission type: id, subject template, message template, sender bean type [standard, custom]
-- order confirmation
transmissionType_500_IT varchar[] = ARRAY['500','IT_orderSubject.vm', 'IT_orderMessage.vm', 'CheckOrderQueue'];
transmissionType_500_IB varchar[] = ARRAY['500','IB_orderSubject.vm', 'IB_orderMessage.vm', 'CheckOrderQueue'];
-- dispatch
transmissionType_530_IT varchar[] = ARRAY['530','IT_dispatchSubject.vm', 'IT_dispatchMessage.vm', 'CloseDispatchQueue'];
transmissionType_530_IB varchar[] = ARRAY['530','IB_dispatchSubject.vm', 'IB_dispatchMessage.vm', 'CloseDispatchQueue'];
-- invoice
transmissionType_570_IT varchar[] = ARRAY['570','IT_invoiceSubject.vm', 'IT_invoiceMessage.vm', 'InvoicingTransmissionSyncQueue'];
transmissionType_570_IB varchar[] = ARRAY['570','IB_invoiceSubject.vm', 'IB_invoiceMessage.vm', 'InvoicingTransmissionSyncQueue'];
-- returns
transmissionType_540_IT varchar[] = ARRAY['540','IT_returnSubject_can_rcl.vm', 'IT_returnMessage_can_rcl.vm', 'CloseReturnQueue'];
transmissionType_540_IB varchar[] = ARRAY['540','IB_returnSubject_can_rcl.vm', 'IB_returnMessage_can_rcl.vm', 'CloseReturnQueue'];
transmissionType_541_IT varchar[] = ARRAY['541','IT_returnSubject_can_rcl.vm', 'IT_returnMessage_can_rcl.vm', 'CloseReturnQueue'];
transmissionType_541_IB varchar[] = ARRAY['541','IB_returnSubject_can_rcl.vm', 'IB_returnMessage_can_rcl.vm', 'CloseReturnQueue'];
transmissionType_543_IT varchar[] = ARRAY['543','IT_returnSubject_ret_def_inv.vm', 'IT_returnMessage_ret_def_inv.vm', 'CloseReturnQueue'];
transmissionType_543_IB varchar[] = ARRAY['543','IB_returnSubject_ret_def_inv.vm', 'IB_returnMessage_ret_def_inv.vm', 'CloseReturnQueue'];

-- return label mail via omt
transmissionType_713_IT varchar[] = ARRAY['713','IT_returnLabelSubject.vm', 'IT_returnLabelMessage.vm', _null]; -- triggered via GUI and couldn't be registered as event
transmissionType_713_IB varchar[] = ARRAY['713','IB_returnLabelSubject.vm', 'IB_returnLabelMessage.vm', _null]; -- triggered via GUI and couldn't be registered as event

-- rma
--transmissionType_715_IT varchar[] = ARRAY['715','returnAnnouncementSubject.vm', 'returnAnnouncementMessage.vm', ''];
--transmissionType_715_IB varchar[] = ARRAY['715','returnAnnouncementSubject.vm', 'returnAnnouncementMessage.vm', ''];
  
-- mapping: shop || enabled/disabled || transmissionType
transmissionTypesToTemplates varchar[][] = array [
	email_intronics || enabled || transmissionType_570_IT,
	email_intronics || enabled || transmissionType_530_IT,
	email_intronics || enabled || transmissionType_500_IT,
	email_intronics || enabled || transmissionType_540_IT,
	email_intronics || enabled || transmissionType_541_IT,
	email_intronics || enabled || transmissionType_543_IT,
	email_intronics || enabled || transmissionType_713_IT,
	email_intronics_b2b || enabled || transmissionType_570_IB,
	email_intronics_b2b || enabled || transmissionType_530_IB,
	email_intronics_b2b || enabled || transmissionType_500_IB,
	email_intronics_b2b || enabled || transmissionType_540_IB,
	email_intronics_b2b || enabled || transmissionType_541_IB,
	email_intronics_b2b || enabled || transmissionType_543_IB,
	email_intronics_b2b || enabled || transmissionType_713_IB
];

BEGIN

FOREACH transmissionTypeToTemplates SLICE 1 IN ARRAY transmissionTypesToTemplates LOOP
	shopRef := transmissionTypeToTemplates[1]::int8;
	senderAddress := transmissionTypeToTemplates[2];
	senderName := transmissionTypeToTemplates[3];
	_active := transmissionTypeToTemplates[4]::boolean;

	transmissionType := transmissionTypeToTemplates[5]::int8;
	subjectTemplate := transmissionTypeToTemplates[6];
	messageTemplate := transmissionTypeToTemplates[7];
	queueName := transmissionTypeToTemplates[8];


	IF queueName is not null THEN
		-- Event registry configuration --> Trigger Mail Event Manager
		/*
			eventDefRef = 1 (EventDefDO.MAIL_EVENT_MANAGER)
		*/
		INSERT INTO "EventRegistryEntryDO" (
			"id","creationDate","modificationDate",
			"processesRef","version",
			"eventDefRef","shopRef","description")
			SELECT
			nextval('"EventRegistryEntryDO_id_seq"'),CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,
			(select id from "ProcessesDO" where "processDefRef" = (select id from "ProcessDefDO" where "queueName" = queueName)), 1,
			1, shopRef, 'Mail Events on ' || queueName
			WHERE 1 NOT IN
			(
			SELECT 1 from "EventRegistryEntryDO" where
				"processesRef" = (select id from "ProcessesDO" where "processDefRef" = (select id from "ProcessDefDO" where "queueName" = queueName)) and
				"eventDefRef" = 1 and
				"shopRef" = shopRef
			);

		-- Mail Event Registry Configuration
		/*
			mailEventDefRef = 1 (MailEventDefDO.SEND_SHOP_CUSTOMER_MAIL_PC)
			decisionBeanDefRef = 50 (ExpandedDecisionBeanDefDO.SEND_EMAIL_DECIDER_BEAN) -> SendEmailDeciderBean.java
			transmissionTypeDefRef = transmissionType (TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_ORDER) -> "sendCustomerMailOrder", RoleDefDO.CUSTOMER, MessageTypeDefDO.SEND_CUSTOMER_MAIL_ORDER
		*/
		INSERT INTO "MailEventRegistryEntryDO"(
				id, version, "creationDate", "modificationDate", active,
				"eventRegistryEntryRef",
				"mailEventDefRef", "decisionBeanDefRef", "transmissionTypeDefRef")
				SELECT
				nextval('"MailEventRegistryEntryDO_id_seq"'), 0, now(), now(), true,
				(select id from "EventRegistryEntryDO" where "processesRef"=(select id from "ProcessesDO" where "processDefRef" = (select id from "ProcessDefDO" where "queueName" = queueName)) and "eventDefRef"=1 and "shopRef"=shopRef),
				1, 50, transmissionType -- "mailEventDefRef", "decisionBeanDefRef", "transmissionTypeDefRef"
				WHERE 1 NOT IN
				(
					SELECT 1 FROM "MailEventRegistryEntryDO" WHERE
						"eventRegistryEntryRef" = (select id from "EventRegistryEntryDO" where "processesRef"=(select id from "ProcessesDO" where "processDefRef" = (select id from "ProcessDefDO" where "queueName" = queueName)) and "eventDefRef"=1 and "shopRef"=shopRef)
						AND "mailEventDefRef" = 1
						AND "transmissionTypeDefRef" = transmissionType
				);
		UPDATE "MailEventRegistryEntryDO" SET active = _active WHERE
						"eventRegistryEntryRef" = (select id from "EventRegistryEntryDO" where "processesRef"=(select id from "ProcessesDO" where "processDefRef" = (select id from "ProcessDefDO" where "queueName" = queueName)) and "eventDefRef"=1 and "shopRef"=shopRef)
						AND "mailEventDefRef" = 1
						AND "transmissionTypeDefRef" = transmissionType;
	END IF;

	-- Transmission parameters

	-- TransmissionConfig Order Mail
	-- transmissionTypeDefRef = transmissionType (TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_ORDER) -> "sendCustomerMailOrder", RoleDefDO.CUSTOMER, MessageTypeDefDO.SEND_CUSTOMER_MAIL_ORDER
	INSERT INTO "CommunicationPartnerDO"(
			id, "decisionBeanDefRef", "splitTransmission", "communicationRef",
			"receivingPartnerReferrerRef", "sendingPartnerReferrerRef", "maxNoOfRetries",
			"retryDelay", "mergeTypeDefRef")
		SELECT nextval('"CommunicationPartnerDO_id_seq"'), null, false, (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType),
			null, (select id from "PartnerReferrerDO" where "shopRef" = shopRef), 12,
			'30m', null
		WHERE 1 NOT IN (
			SELECT 1 FROM "CommunicationPartnerDO" WHERE
				"communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType)
				AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef)
				AND "receivingPartnerReferrerRef" isNull
		);
	-- shopEmailAddress (1200 - ExecutionBeanKeyDefDO.SHOPCUSTOMERMAILSENDERBEAN_SHOP_EMAIL_ADDRESS)
	INSERT INTO "ExecutionBeanValueDO"(
			id, "executionBeanKeyDefRef", "parameterValue", "communicationPartnerRef")
		SELECT nextval('"ExecutionBeanValueDO_id_seq"'), ebv_senderAddress, senderAddress, (select id from "CommunicationPartnerDO" where "communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType) AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef) AND "receivingPartnerReferrerRef" isNull)
		WHERE 1 NOT IN (
			SELECT 1 FROM "ExecutionBeanValueDO"
			WHERE
			"communicationPartnerRef" = (select id from "CommunicationPartnerDO" where "communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType) AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef) AND "receivingPartnerReferrerRef" isNull)
			and "executionBeanKeyDefRef" = ebv_senderAddress
		)
		;
	UPDATE "ExecutionBeanValueDO"
			SET "parameterValue" = senderAddress
			WHERE
			"communicationPartnerRef" = (select id from "CommunicationPartnerDO" where "communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType) AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef) AND "receivingPartnerReferrerRef" isNull)
			and "executionBeanKeyDefRef" = ebv_senderAddress
		;
	-- shopEmailSenderName (1201 - ExecutionBeanKeyDefDO.SHOPCUSTOMERMAILSENDERBEAN_SHOP_EMAIL_SENDERNAME)
	INSERT INTO "ExecutionBeanValueDO"(
			id, "executionBeanKeyDefRef", "parameterValue", "communicationPartnerRef")
		SELECT nextval('"ExecutionBeanValueDO_id_seq"'), ebv_senderName, senderName, (select id from "CommunicationPartnerDO" where "communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType) AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef) AND "receivingPartnerReferrerRef" isNull)
		WHERE 1 NOT IN (
			SELECT 1 FROM "ExecutionBeanValueDO"
			WHERE
			"communicationPartnerRef" = (select id from "CommunicationPartnerDO" where "communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType) AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef) AND "receivingPartnerReferrerRef" isNull)
			and "executionBeanKeyDefRef" = ebv_senderName
		)
		;
	UPDATE "ExecutionBeanValueDO"
			SET "parameterValue" = senderName
			WHERE
			"communicationPartnerRef" = (select id from "CommunicationPartnerDO" where "communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType) AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef) AND "receivingPartnerReferrerRef" isNull)
			and "executionBeanKeyDefRef" = ebv_senderName
		;

	-- subjectTemplate (1204 - ExecutionBeanKeyDefDO.SHOPCUSTOMERMAILSENDERBEAN_SUBJECT_TEMPLATE_FILE_NAME)
	INSERT INTO "ExecutionBeanValueDO"(
			id, "executionBeanKeyDefRef", "parameterValue", "communicationPartnerRef")
		SELECT nextval('"ExecutionBeanValueDO_id_seq"'), ebv_subjectTemplate, subjectTemplate, (select id from "CommunicationPartnerDO" where "communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType) AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef) AND "receivingPartnerReferrerRef" isNull)
		WHERE 1 NOT IN (
			SELECT 1 FROM "ExecutionBeanValueDO"
			WHERE
			"communicationPartnerRef" = (select id from "CommunicationPartnerDO" where "communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType) AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef) AND "receivingPartnerReferrerRef" isNull)
			and "executionBeanKeyDefRef" = ebv_subjectTemplate
		)
		;
	UPDATE "ExecutionBeanValueDO"
			SET "parameterValue" = subjectTemplate
			WHERE
			"communicationPartnerRef" = (select id from "CommunicationPartnerDO" where "communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType) AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef) AND "receivingPartnerReferrerRef" isNull)
			and "executionBeanKeyDefRef" = ebv_subjectTemplate
		;

	-- messageTemplate (1205 - ExecutionBeanKeyDefDO.SHOPCUSTOMERMAILSENDERBEAN_MESSAGE_TEMPLATE_FILE_NAME)
	INSERT INTO "ExecutionBeanValueDO"(
			id, "executionBeanKeyDefRef", "parameterValue", "communicationPartnerRef")
		SELECT nextval('"ExecutionBeanValueDO_id_seq"'), ebv_messageTemplate, messageTemplate, (select id from "CommunicationPartnerDO" where "communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType) AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef) AND "receivingPartnerReferrerRef" isNull)
		WHERE 1 NOT IN (
			SELECT 1 FROM "ExecutionBeanValueDO"
			WHERE
			"communicationPartnerRef" = (select id from "CommunicationPartnerDO" where "communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType) AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef) AND "receivingPartnerReferrerRef" isNull)
			and "executionBeanKeyDefRef" = ebv_messageTemplate
		)
		;
	UPDATE "ExecutionBeanValueDO"
			SET "parameterValue" = messageTemplate
			WHERE
			"communicationPartnerRef" = (select id from "CommunicationPartnerDO" where "communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType) AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef) AND "receivingPartnerReferrerRef" isNull)
			and "executionBeanKeyDefRef" = ebv_messageTemplate
		;


	-- mimeType (1207 - ExecutionBeanKeyDefDO.SHOPCUSTOMERMAILSENDERBEAN_MIME_TYPE)
	INSERT INTO "ExecutionBeanValueDO"
			(id, "executionBeanKeyDefRef", "parameterValue", "communicationPartnerRef")
		SELECT nextval('"ExecutionBeanValueDO_id_seq"'), ebv_mimeType, 'text/html', (select id from "CommunicationPartnerDO" where "communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType) AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef) AND "receivingPartnerReferrerRef" isNull)
		WHERE 1 NOT IN (
			SELECT 1 FROM "ExecutionBeanValueDO"
			WHERE
			"communicationPartnerRef" = (select id from "CommunicationPartnerDO" where "communicationRef" = (select id from "CommunicationDO" where "transmissionTypeDefRef" = transmissionType) AND "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shopRef) AND "receivingPartnerReferrerRef" isNull)
			and "executionBeanKeyDefRef" = ebv_mimeType
		)
		;

END LOOP;

END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;