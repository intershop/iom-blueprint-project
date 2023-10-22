#parse("src/sql-config/config/vars.vm")
-- import global variables
--$vars_shop_supplier
--$vars_shop2supplier
-- PAUSE velocity parser
#[[
  transformerGroupName varchar;
  transformerGroupId bigint;
  transformerProcessId bigint;
  ftpConfigRef bigint;
  communicationPartner bigint;
  localdirectory varchar;
  fileNameRegex varchar;
  supplierref int8;
BEGIN

	fileNameRegex = 'icm-product-export.*\.xml';    -- adjust for your project
    transformerGroupName = 'ICM_Product_Import';
    localdirectory ='/var/opt/share/importarticle/20050_ProductImport';

    IF NOT EXISTS (SELECT NULL FROM "TransformerProcessGroupDO" WHERE name = transformerGroupName) THEN
        INSERT INTO "TransformerProcessGroupDO"(id, name)
        SELECT nextval('"TransformerProcessGroupDO_id_seq"'), transformerGroupName;
    END IF;
    transformerGroupId = (SELECT id FROM "TransformerProcessGroupDO" WHERE name = transformerGroupName);

    -- Add the custom transformer
    IF NOT EXISTS (SELECT NULL FROM "TransformerProcessDO" WHERE "transformerBeanDefRef" = 1000 AND "transformerProcessGroupRef" = transformerGroupId) THEN
        INSERT INTO "TransformerProcessDO"( id, index, "transformerBeanDefRef", "transformerProcessGroupRef", "filenameRegex", "moveObsoleteFiles")
            SELECT nextval('"TransformerProcessDO_id_seq"'), 1, 1000, transformerGroupId, null, true;
    END IF;
    transformerProcessId = (SELECT id FROM "TransformerProcessDO" WHERE "transformerBeanDefRef" = 1000 AND "transformerProcessGroupRef" = transformerGroupId);
    -- Add parameters for the custom transformer
    PERFORM upsert_tp_parameter(4, fileNameRegex::varchar, transformerProcessId);
    -- parent shopid
    PERFORM upsert_tp_parameter(1, shop_intronics_b2c::varchar, transformerProcessId);
    
    -- supplier
    -- no supplier config, cause supplierids are coming with xml and could only define ine supplier here

    -------- FTP Config --------
    IF NOT EXISTS (SELECT NULL FROM oms."FileTransferConfigurationDO"
        WHERE "partnerReferrerRef" = (select id from "PartnerReferrerDO" where "supplierRef" = supplier_retailer_losangeles)
            AND "transformerProcessGroupRef" = transformerGroupId) THEN
        INSERT INTO oms."FileTransferConfigurationDO" (id, "basePath", "transmissionTypeDefRef", "typeDefRef", "creationDate",
            "modificationDate", "partnerReferrerRef", "description", "transformerProcessGroupRef")
            SELECT nextval('"FileTransferConfigurationDO_id_seq"'), null, 1040, 30, current_timestamp, current_timestamp,
                (select id from "PartnerReferrerDO" where "supplierRef" = supplier_retailer_losangeles), transformerGroupName, transformerGroupId;
    END IF;
    ftpConfigRef = (SELECT id FROM oms."FileTransferConfigurationDO" WHERE "partnerReferrerRef" =
        (select id from "PartnerReferrerDO" where "supplierRef" = supplier_retailer_losangeles) AND "transformerProcessGroupRef" = transformerGroupId);

    -------- create the schedule --------
    IF NOT EXISTS (SELECT NULL FROM "ScheduleDO" WHERE "key" = transformerGroupName AND "configId" = ftpConfigRef) THEN
        INSERT INTO oms."ScheduleDO" (id, "creationDate", "modificationDate", active, "configId", cron, "expectedRuntime", "jobDefRef", "lastRun", "lockedSince", "key", "maxNoOfRetries", "retryDelay", "countRetry")
            SELECT nextval('"ScheduleDO_id_seq"'), current_timestamp, current_timestamp, TRUE,
            ftpConfigRef, '0 0/5 * * * ?', 60000, 3, NULL, NULL,
            transformerGroupName, 10, '10m', 0;
    END IF;

    -------- create the Communication config --------
    IF NOT EXISTS (SELECT NULL from "CommunicationPartnerDO"
            where "communicationRef" = (select id from "CommunicationDO" where "key" = 'ANY###FTP_JOB###EXT_RECEIVE_ARTICLE')
            and "receivingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shop_intronics_b2c)
            and "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "supplierRef" = supplier_retailer_losangeles)) THEN
	    INSERT INTO oms."CommunicationPartnerDO" (id, "splitTransmission", "communicationRef", "receivingPartnerReferrerRef",
	        "sendingPartnerReferrerRef", "maxNoOfRetries", "retryDelay")
	        SELECT nextval('"CommunicationPartnerDO_id_seq"'), FALSE, (select id from "CommunicationDO"
	            where "key" = 'ANY###FTP_JOB###EXT_RECEIVE_ARTICLE'), (select id from "PartnerReferrerDO" where "shopRef" = shop_intronics_b2c),
	            (select id from "PartnerReferrerDO" where "supplierRef" = supplier_retailer_losangeles), 12, '30m'
	        ON CONFLICT ("communicationRef", "sendingPartnerReferrerRef", "receivingPartnerReferrerRef") DO NOTHING;
	END IF;

    -------- create the parameter values --------
    -- key, value, communicationPartner
    communicationPartner = (select id from "CommunicationPartnerDO"
            where "communicationRef" = (select id from "CommunicationDO" where "key" = 'ANY###FTP_JOB###EXT_RECEIVE_ARTICLE')
            and "receivingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shop_intronics_b2c)
            and "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "supplierRef" = supplier_retailer_losangeles));

    -- set parameters in "ExecutionBeanValueDO"
    --PERFORM upsert_eb_value(1330, 'sftp://user:pass@localhost:21', communicationPartner); --FTP_JOB_PULL_FTP_ACCOUNT
    --PERFORM upsert_eb_value(1331, localdirectory, communicationPartner);      --FTP_JOB_PULL_DIRECTORY 
    -- PERFORM upsert_eb_value(1332, 'importarticle/in/', communicationPartner); --FTP_JOB_PUSH_DIRECTORY
    -- PERFORM upsert_eb_value(1333, fileNameRegex, communicationPartner);       --FTP_JOB_PULL_FILENAME_REGEX
    --PERFORM upsert_eb_value(1338, 'project-files/private-keys/rsa-key-sftp', communicationPartner);

END;


-- RESUME velocity parser
]]#
$do;