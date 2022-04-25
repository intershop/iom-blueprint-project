#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier
$vars_decision_beans
$vars_execution_beans

-- PAUSE velocity parser
#[[

-- local variables go here
shopref bigint;
communicationPartner bigint;
documentType int;
-- end variables block with 
BEGIN

-- dedicated invoice number range per channel
IF NOT EXISTS (SELECT NULL FROM "InvoicingNoConfigDO" WHERE "shopRef" = shop_intronics_b2c AND "numberRangeFormatterDefRef" = 5)
THEN
	INSERT INTO "InvoicingNoConfigDO"(id, "name", "countGenerated", "creationDate", enabled, 
				"generationDate","startNumber","endNumber", "numberRangeFormatterDefRef", 
				"invoicingTypeDefRef","lastGeneratedNumber", "maxNotAllocatedInvoiceNo", 
				"modificationDate", "startDate","shopRef", version)
	    SELECT 	nextval('"InvoicingNoConfigDO_id_seq"'), 'InvoiceNo config - inTRONICS B2C', 0, CURRENT_TIMESTAMP, true,
	    		null, '1000000000', '2999999999', 500, 
	    		null, null, 5, 
	    		CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, shop_intronics_b2c, 1;
END IF;

IF NOT EXISTS (SELECT NULL FROM "InvoicingNoConfigDO" WHERE "shopRef" = shop_intronics_b2b AND "numberRangeFormatterDefRef" = 5)
THEN
	INSERT INTO "InvoicingNoConfigDO"(id, "name", "countGenerated", "creationDate", enabled, 
				"generationDate","startNumber","endNumber", "numberRangeFormatterDefRef", 
				"invoicingTypeDefRef","lastGeneratedNumber", "maxNotAllocatedInvoiceNo", 
				"modificationDate", "startDate","shopRef", version)
	    SELECT 	nextval('"InvoicingNoConfigDO_id_seq"'), 'InvoiceNo config - inTRONICS B2B', 0, CURRENT_TIMESTAMP, true,
	    		null, '3000000000', '4999999999', 500, 
	    		null, null, 5, 
	    		CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, shop_intronics_b2b, 1;
END IF;


FOREACH shopref IN ARRAY array[shops_all]
LOOP

    -- -------------------------------
    -- INVOICE ON CLOSEDISPATCHQUEUE -
    -- -------------------------------

    -- EventRegistryEntry Invoicing
    IF NOT EXISTS (SELECT NULL FROM "EventRegistryEntryDO" WHERE "processesRef" = (SELECT id FROM "ProcessesDO" 
    	WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseDispatchQueue'))
    	AND "eventDefRef" = 3 AND "shopRef" = shopref)
    THEN
	    INSERT INTO "EventRegistryEntryDO" ("id", "creationDate", "modificationDate", "processesRef",
	    			"version", "eventDefRef", "shopRef", "description")
		    SELECT nextval('"EventRegistryEntryDO_id_seq"'), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, (
		        SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseDispatchQueue')
		        -- "version", "eventDefRef", "shopRef", "description"
		        ), 1, 3, shopref, 'Invoicing Events on CloseDispatchQueue';
	END IF;

    -- InvoicingEventRegistryEntryDO
    -- Invoice for ALL payment methods on CloseDispatchQueue
    IF NOT EXISTS (SELECT NULL FROM "InvoicingEventRegistryEntryDO" WHERE "eventRegistryEntryRef" = (
            SELECT id FROM "EventRegistryEntryDO" WHERE "processesRef"= (
                SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseDispatchQueue')
            ) AND "eventDefRef" = 3 AND "shopRef" = shopref
        ) AND "invoicingEventDefRef" = 1 and "paymentDefRef" is null AND "invoicingTypeDefRef" = 1)
	THEN
	    INSERT INTO "InvoicingEventRegistryEntryDO" ("id", "creationDate", "modificationDate", "eventRegistryEntryRef", 
	    			"version", "active", "paymentDefRef", "invoicingTypeDefRef", "invoicingEventDefRef", "decisionBeanDefRef")
	    -- "id", "creationDate", "modificationDate"
	    SELECT nextval('"InvoicingEventRegistryEntryDO_id_seq"'), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, (
	    	-- "eventRegistryEntryRef"
	        SELECT id FROM "EventRegistryEntryDO" WHERE "processesRef" = (
	            SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseDispatchQueue')
	        ) AND "eventDefRef" = 3 AND "shopRef" = shopref),
	        -- "version", "active", "paymentDefRef"
	        0, true, null, 
	        -- "invoicingTypeDefRef", "invoicingEventDefRef", "decisionBeanDefRef"
	        1, 1, db_invoicing;
	END IF;
	
    -- -------------------------------
    -- CREDITNOTE ON RETURN ----------
    -- -------------------------------
    
    -- EventRegistryEntry Invoicing
    IF NOT EXISTS (SELECT NULL FROM "EventRegistryEntryDO" WHERE "processesRef" = (SELECT id FROM "ProcessesDO" 
    	WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseReturnQueue')) 
    	AND "eventDefRef" = 3 AND "shopRef" = shopref)
    THEN
	    INSERT INTO "EventRegistryEntryDO" ("id", "creationDate", "modificationDate", "processesRef",
	    			"version", "eventDefRef", "shopRef", "description")
		    SELECT nextval('"EventRegistryEntryDO_id_seq"'), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, (
		        SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseReturnQueue')
		        -- "version", "eventDefRef", "shopRef", "description"
		        ), 1, 3, shopref, 'Invoicing Events on CloseReturnQueue';
	END IF;

    -- InvoicingEventRegistryEntryDO
    -- Invoice for ALL payment methods on CloseDispatchQueue
    IF NOT EXISTS (SELECT NULL FROM "InvoicingEventRegistryEntryDO" WHERE "eventRegistryEntryRef" = (
            SELECT id FROM "EventRegistryEntryDO" WHERE "processesRef"= (
                SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseReturnQueue')
            ) AND "eventDefRef" = 3 AND "shopRef" = shopref
        ) AND "invoicingEventDefRef" = 1 and "paymentDefRef" is null AND "invoicingTypeDefRef" = 2)
	THEN
	    INSERT INTO "InvoicingEventRegistryEntryDO" ("id", "creationDate", "modificationDate", "eventRegistryEntryRef", 
	    			"version", "active", "paymentDefRef", 
	    			"invoicingTypeDefRef", "invoicingEventDefRef", "decisionBeanDefRef")
	    -- "id", "creationDate", "modificationDate"
	    SELECT nextval('"InvoicingEventRegistryEntryDO_id_seq"'), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, (
	    	-- "eventRegistryEntryRef"
	        SELECT id FROM "EventRegistryEntryDO" WHERE "processesRef" = (
	            SELECT id FROM "ProcessesDO" WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseReturnQueue')
	        ) AND "eventDefRef" = 3 AND "shopRef" = shopref),
	        -- "version", "active", "paymentDefRef"
	        0, true, null, 
	        -- "invoicingTypeDefRef", "invoicingEventDefRef", "decisionBeanDefRef"
	        2, 1, db_invoicing;
	END IF;

    -- -------------------------------
    -- DOCUMENT CREATION -------------
    -- -------------------------------
    
	-- CommunicationPartnerDO
	-- sendingPartner + receivingPartner = SHOP
	IF NOT EXISTS (SELECT NULL FROM "CommunicationPartnerDO" WHERE "communicationRef" IN (
        SELECT "id" FROM "CommunicationDO" WHERE "executionBeanDefRef" = 65 AND "transmissionTypeDefRef" = 300 AND "documentFormatDefRef"=1)
	    AND "receivingPartnerReferrerRef" = (SELECT "id" FROM "PartnerReferrerDO" WHERE "shopRef" = shopref)
	    AND "sendingPartnerReferrerRef" = (SELECT "id" FROM "PartnerReferrerDO" WHERE "shopRef" = shopref)
	)
	THEN
		INSERT INTO "CommunicationPartnerDO" ("id", "decisionBeanDefRef", "splitTransmission", "communicationRef", "receivingPartnerReferrerRef",
		    "sendingPartnerReferrerRef", "maxNoOfRetries", "retryDelay", "mergeTypeDefRef")
		    SELECT nextval('"CommunicationPartnerDO_id_seq"'), null, false, (
		        SELECT "id" FROM "CommunicationDO" WHERE "executionBeanDefRef" = 65 AND "transmissionTypeDefRef" = 300 AND "documentFormatDefRef" = 1 ),
		        (SELECT "id" FROM "PartnerReferrerDO" WHERE "shopRef" = shopref), (SELECT "id" FROM "PartnerReferrerDO" WHERE "shopRef" = shopref),
		        5, '2m', null;
	END IF;
	
	communicationPartner = (SELECT id FROM "CommunicationPartnerDO" WHERE "communicationRef" IN (
        SELECT "id" FROM "CommunicationDO" WHERE "executionBeanDefRef" = 65 AND "transmissionTypeDefRef" = 300 AND "documentFormatDefRef"=1)
	    AND "receivingPartnerReferrerRef" = (SELECT "id" FROM "PartnerReferrerDO" WHERE "shopRef" = shopref)
	    AND "sendingPartnerReferrerRef" = (SELECT "id" FROM "PartnerReferrerDO" WHERE "shopRef" = shopref)
	);

	-- ExecutionBeanValueDO
	-- documentFormat
    PERFORM upsert_eb_value(213, 'PDF', communicationPartner);
    -- documentType
    PERFORM upsert_eb_value(214, 'INVOICE_CREDIT_NOTE', communicationPartner);
    -- addInvoiceCreditNote (true/false)
    PERFORM upsert_eb_value(215, 'true', communicationPartner);

    -- DocumentTransformerConfigDO
    FOREACH documentType IN ARRAY array[17, 18, 19]
    LOOP
    	IF NOT EXISTS (SELECT 1 FROM "DocumentTransformerConfigDO" WHERE "shopRef" = shopref AND "documentFormatDefRef" = 1 
    		AND "documentMapperDefRef" = 2 AND "documentTypeDefRef" = documentType)
    	THEN
			INSERT INTO "DocumentTransformerConfigDO"("id", "documentFormatDefRef", "documentMapperDefRef", "documentTypeDefRef", "shopRef",
			    "transformerFrameworkDefRef", "save")
			SELECT nextval('"DocumentTransformerConfigDO_id_seq"'), 1, 2, documentType, shopref, 2, TRUE;
    	END IF;
    END LOOP;

END LOOP;

END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;