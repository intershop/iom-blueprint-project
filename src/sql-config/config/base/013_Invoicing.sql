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
processref bigint;
eventregistryentryref bigint;
shoppartnerref bigint;
-- end variables block with 
BEGIN

-- dedicated invoice number range per channel
IF NOT EXISTS (SELECT * FROM "InvoicingNoConfigDO" WHERE "shopRef" = shop_intronics_b2c AND "numberRangeFormatterDefRef" = 5)
THEN
    INSERT INTO "InvoicingNoConfigDO"(id, 
                "name", "creationDate", enabled, 
                "startNumber","endNumber", "numberRangeFormatterDefRef", 
                "invoicingTypeDefRef", "maxNotAllocatedInvoiceNo", 
                "modificationDate", "startDate","shopRef", version)
        SELECT     nextval('"InvoicingNoConfigDO_id_seq"'), 
                 'InvoiceNo config - inTRONICS B2C',  CURRENT_TIMESTAMP, true,
                 '1000000000', '2999999999', 5, 
                null, 5, 
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, shop_intronics_b2c, 1;
END IF;

IF NOT EXISTS (SELECT * FROM "InvoicingNoConfigDO" WHERE "shopRef" = shop_intronics_b2b AND "numberRangeFormatterDefRef" = 5)
THEN
    INSERT INTO "InvoicingNoConfigDO"(id, 
                "name",  "creationDate", enabled, 
                "startNumber","endNumber", "numberRangeFormatterDefRef", 
                "invoicingTypeDefRef", "maxNotAllocatedInvoiceNo", 
                "modificationDate", "startDate","shopRef", version)
        SELECT     nextval('"InvoicingNoConfigDO_id_seq"'), 
                'InvoiceNo config - inTRONICS B2B',  CURRENT_TIMESTAMP, true,
                '3000000000', '4999999999', 5, 
                null, 5, 
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, shop_intronics_b2b, 1;
END IF;


FOREACH shopref IN ARRAY array[shops_all]
LOOP

    -- -------------------------------
    -- INVOICE ON CLOSEDISPATCHQUEUE -
    -- -------------------------------

    
    -- EventRegistryEntry Invoicing
     processref=(SELECT id FROM "ProcessesDO" 
                  WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseDispatchQueue'));
        
    IF NOT EXISTS (SELECT * FROM "EventRegistryEntryDO" 
                        WHERE "processesRef" = processref
                        AND "eventDefRef" = 3 
                        AND "shopRef" = shopref)
    THEN
        INSERT INTO "EventRegistryEntryDO" ("id", "creationDate", "modificationDate", "processesRef",
                    "version", "eventDefRef", "shopRef", "description")
            SELECT nextval('"EventRegistryEntryDO_id_seq"'), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, processref,
                  -- "version", "eventDefRef", "shopRef", "description"
                   1, 3, shopref, 'Invoicing Events on CloseDispatchQueue';
    END IF;

    -- InvoicingEventRegistryEntryDO
    -- Invoice for ALL payment methods on CloseDispatchQueue
    
   eventregistryentryref =(
            SELECT id FROM "EventRegistryEntryDO" 
            WHERE "processesRef"= (SELECT id FROM "ProcessesDO" 
                                   WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseDispatchQueue'))
            AND "eventDefRef" = 3 
            AND "shopRef" = shopref
        );

    IF NOT EXISTS (SELECT * FROM "InvoicingEventRegistryEntryDO" 
                   WHERE "eventRegistryEntryRef" =eventregistryentryref  
                   AND "invoicingEventDefRef" = 1 
                   AND "paymentDefRef" is null 
                   AND "invoicingTypeDefRef" = 1)
    THEN
        INSERT INTO "InvoicingEventRegistryEntryDO" ("id", 
                    "creationDate", "modificationDate", "eventRegistryEntryRef", 
                    "version", "active", "paymentDefRef", 
                    "invoicingTypeDefRef", "invoicingEventDefRef", "decisionBeanDefRef")
        SELECT nextval('"InvoicingEventRegistryEntryDO_id_seq"'), 
                     -- "creationDate", "modificationDate"
                     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, eventregistryentryref,
                     -- "version", "active", "paymentDefRef"
                     0, true, null, 
                     -- "invoicingTypeDefRef", "invoicingEventDefRef", "decisionBeanDefRef"
                     1, 1, db_invoicing;
    END IF;
    
    -- -------------------------------
    -- CREDITNOTE ON RETURN ----------
    -- -------------------------------
    
    -- EventRegistryEntry Invoicing
    processref= (SELECT id FROM "ProcessesDO" 
                    WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseReturnQueue'));
        
    IF NOT EXISTS (SELECT * FROM "EventRegistryEntryDO" 
                 WHERE "processesRef" =  processref
                 AND "eventDefRef" = 3 
                 AND "shopRef" = shopref)
    THEN
        INSERT INTO "EventRegistryEntryDO" ("id", 
                    "creationDate", "modificationDate", "processesRef",
                    "version", "eventDefRef", "shopRef", "description")
        SELECT nextval('"EventRegistryEntryDO_id_seq"'), 
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, processref,
                -- "version", "eventDefRef", "shopRef", "description"
                1, 3, shopref, 'Invoicing Events on CloseReturnQueue';
    END IF;

    -- InvoicingEventRegistryEntryDO
    -- Invoice for ALL payment methods on CloseDispatchQueue
       eventregistryentryref =(
                SELECT id FROM "EventRegistryEntryDO" 
                WHERE "processesRef"= (SELECT id FROM "ProcessesDO" 
                                       WHERE "processDefRef" = (SELECT id FROM "ProcessDefDO" WHERE "queueName" = 'CloseReturnQueue'))
                AND "eventDefRef" = 3 
                AND "shopRef" = shopref);

    IF NOT EXISTS (SELECT * FROM "InvoicingEventRegistryEntryDO" 
                    WHERE "eventRegistryEntryRef" = eventregistryentryref 
                    AND "invoicingEventDefRef" = 1 
                    AND "paymentDefRef" is null 
                    AND "invoicingTypeDefRef" = 2)
    THEN
        INSERT INTO "InvoicingEventRegistryEntryDO" ("id", 
                    "creationDate", "modificationDate", "eventRegistryEntryRef", 
                    "version", "active", "paymentDefRef", 
                    "invoicingTypeDefRef", "invoicingEventDefRef", "decisionBeanDefRef")
        -- "id", "creationDate", "modificationDate"
        SELECT nextval('"InvoicingEventRegistryEntryDO_id_seq"'), 
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, eventregistryentryref,
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
    shoppartnerref = (SELECT "id" FROM "PartnerReferrerDO" WHERE "shopRef" = shopref);
    IF NOT EXISTS (SELECT * FROM "CommunicationPartnerDO" 
                    WHERE "communicationRef" IN (
                             SELECT "id" FROM "CommunicationDO" WHERE "executionBeanDefRef" = 65 AND "transmissionTypeDefRef" = 300 AND "documentFormatDefRef"=1)
                    AND "receivingPartnerReferrerRef" = shoppartnerref
                    AND "sendingPartnerReferrerRef"   = (SELECT "id" FROM "PartnerReferrerDO" WHERE "shopRef" = shopref)
    )
    THEN
        INSERT INTO "CommunicationPartnerDO" ("id", "decisionBeanDefRef", "splitTransmission", "communicationRef", 
            "receivingPartnerReferrerRef", "sendingPartnerReferrerRef", 
            "maxNoOfRetries", "retryDelay", "mergeTypeDefRef")
            SELECT nextval('"CommunicationPartnerDO_id_seq"'), null, false, 
                --communicationRef
                (SELECT "id" FROM "CommunicationDO" WHERE "executionBeanDefRef" = 65 AND "transmissionTypeDefRef" = 300 AND "documentFormatDefRef" = 1 ),
                --receiving/sending parftners
                shoppartnerref, shoppartnerref,
                --"maxNoOfRetries", "retryDelay", "mergeTypeDefRef")
                5, '2m', null;
    END IF;
    
    communicationPartner = (SELECT id FROM "CommunicationPartnerDO" 
                            WHERE "communicationRef" IN (
                                   SELECT "id" FROM "CommunicationDO" WHERE "executionBeanDefRef" = 65 AND "transmissionTypeDefRef" = 300 AND "documentFormatDefRef"=1)
                            AND "receivingPartnerReferrerRef" = shoppartnerref
                            AND "sendingPartnerReferrerRef" = shoppartnerref
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
        IF NOT EXISTS (SELECT * FROM "DocumentTransformerConfigDO" 
                        WHERE "shopRef" = shopref 
                        AND "documentFormatDefRef" = 1 
                        AND "documentMapperDefRef" = 2 
                        AND "documentTypeDefRef" = documentType)
        THEN
            INSERT INTO "DocumentTransformerConfigDO"("id", 
                "documentFormatDefRef", "documentMapperDefRef", "documentTypeDefRef", 
                "shopRef", "transformerFrameworkDefRef", "save")
            SELECT nextval('"DocumentTransformerConfigDO_id_seq"'), 
                1, 2, documentType, 
                shopref, 2, true;
        END IF;
    END LOOP;

END LOOP;

END;
-- RESUME velocity parser
]]#
-- dollar quoting
$do;