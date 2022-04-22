#parse("src/sql-config/config/vars.vm")
-- import global variables
$vars_shop_supplier

-- PAUSE velocity parser
#[[

  transformerGroupName varchar;
  transformerGroupId bigint;
  transformerProcessId bigint;
  ftpConfigRef bigint;
  communicationPartner bigint;

  fileNameRegex varchar;
  filepath varchar;
  localdirectory varchar;
  supplierref int8;
  
BEGIN

   fileNameRegex = '10020_productavaibility_[0-9]+.zip';
   transformerGroupName = '10020_ProductImport';
   localdirectory ='/var/opt/share/importarticle/10020_ProductImport';
   /*
    As devenv-4-iom does not contain a ftp service, the  file 
    src\test-data\env\dev\zip_1020\10020_productavaibility_20220409.zip 
    from the blueprint project need to be copied manually to the directory 
    devenv-share/importarticle/10020_ProductImport (to be created ba hand)
    in order to demonstrate the functionnality of the hereby configured transformer, 
    which pick the file from this custom directory and just unpack the zip file into 
    the articleimport/in folder.
   */
   
   filepath =  null; -- default to $(IS_OMS_DIR_SHARE)/ScheduleDO.key >  '/var/opt/share/importarticle/10020_ProductImport';

    IF NOT EXISTS (SELECT * FROM "TransformerProcessGroupDO" WHERE name = transformerGroupName) THEN
        INSERT INTO "TransformerProcessGroupDO"(id, name)
        SELECT nextval('"TransformerProcessGroupDO_id_seq"'), transformerGroupName;
    END IF;
    transformerGroupId = (SELECT id FROM "TransformerProcessGroupDO" WHERE name = transformerGroupName);

    -- Add new custom transformer for unzip (TransformerBeanDefDO id 19)
    IF NOT EXISTS (SELECT * FROM "TransformerProcessDO" WHERE "transformerBeanDefRef" = 19 AND "transformerProcessGroupRef" = transformerGroupId) THEN
    
        INSERT INTO "TransformerProcessDO"( id, index, "transformerBeanDefRef", "transformerProcessGroupRef", "filenameRegex", "moveObsoleteFiles")
            SELECT nextval('"TransformerProcessDO_id_seq"'), 1, 19, transformerGroupId, null, true;
    
    END IF;
    transformerProcessId = (SELECT id FROM "TransformerProcessDO" WHERE "transformerBeanDefRef" = 19 AND "transformerProcessGroupRef" = transformerGroupId);

    -- Add parameters for the new transformer
    -- (TransformerProcessParameterKeyDefDO 4=sourceFilename, 1=shopId)
    PERFORM upsert_tp_parameter(4, fileNameRegex, transformerProcessId);
    -- parent shopid
    PERFORM upsert_tp_parameter(1, shop_intronics_b2c::varchar, transformerProcessId);
    
    -------- FTP Config --------
    IF NOT EXISTS (SELECT * FROM oms."FileTransferConfigurationDO"
        WHERE "partnerReferrerRef" = (select id from "PartnerReferrerDO" where "supplierRef" = supplier_wh_texas)
            AND "transformerProcessGroupRef" = transformerGroupId) THEN

         --1040= TransmissionTypeDefDO.EXT_RECEIVE_ARTICLE
         --30 FileTransferJobTypeDefDO pullAndPush
        INSERT INTO oms."FileTransferConfigurationDO" (id,
            "basePath",
            "transmissionTypeDefRef",
            "typeDefRef",
            "creationDate","modificationDate",
            "partnerReferrerRef",
            "description",
            "transformerProcessGroupRef")
            SELECT nextval('"FileTransferConfigurationDO_id_seq"'), 
               filepath,  --basePath
               1040, 
               30, 
               current_timestamp, current_timestamp,
               (select id from "PartnerReferrerDO" where "supplierRef" = supplier_wh_texas), 
               transformerGroupName, 
               transformerGroupId;
    
    END IF;
    
    ftpConfigRef = (SELECT id FROM oms."FileTransferConfigurationDO" 
                   WHERE "partnerReferrerRef" = (select id from "PartnerReferrerDO" where "supplierRef" = supplier_wh_texas) 
                   AND "transformerProcessGroupRef" = transformerGroupId);

    -------- create the schedule --------
    IF NOT EXISTS (SELECT * FROM "ScheduleDO" WHERE "key" = transformerGroupName AND "configId" = ftpConfigRef) THEN
    
        INSERT INTO oms."ScheduleDO" (id, 
        "creationDate", "modificationDate", 
        active, 
        "configId", 
        cron, 
        "expectedRuntime", 
        "jobDefRef", 
        "key", 
        "maxNoOfRetries", 
        "retryDelay", 
        "countRetry")
        SELECT nextval('"ScheduleDO_id_seq"'), 
            current_timestamp, current_timestamp, 
            TRUE,
            ftpConfigRef, 
            '0 0/2 * * * ?', 
            60000, 
            3,  --(FTP Job)
            transformerGroupName, 
            9999, 
            '10m', 
            0;
  
  END IF;

    -------- create the communication config --------
    IF NOT EXISTS (SELECT * from "CommunicationPartnerDO"
            where "communicationRef" = (select id from "CommunicationDO" where "key" = 'ANY###FTP_JOB###EXT_RECEIVE_ARTICLE')
            and "receivingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shop_intronics_b2c)
            and "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "supplierRef" = supplier_wh_texas)) THEN
            
       INSERT INTO oms."CommunicationPartnerDO" (id, 
          "splitTransmission", 
          "communicationRef", 
          "receivingPartnerReferrerRef",
           "sendingPartnerReferrerRef", 
           "maxNoOfRetries", 
           "retryDelay")
       SELECT nextval('"CommunicationPartnerDO_id_seq"'), 
           FALSE, 
           (select id from "CommunicationDO" where "key" = 'ANY###FTP_JOB###EXT_RECEIVE_ARTICLE'), 
           (select id from "PartnerReferrerDO" where "shopRef" = shop_intronics_b2c),
           (select id from "PartnerReferrerDO" where "supplierRef" = supplier_wh_texas), 
           12, 
           '30m'
           ON CONFLICT ("communicationRef", "sendingPartnerReferrerRef", "receivingPartnerReferrerRef") DO NOTHING;
   
   END IF;

    -------- create the parameter values --------
    -- key, value, communicationPartner
    communicationPartner = (select id from "CommunicationPartnerDO"
            where "communicationRef" = (select id from "CommunicationDO" where "key" = 'ANY###FTP_JOB###EXT_RECEIVE_ARTICLE')
            and "receivingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "shopRef" = shop_intronics_b2c)
            and "sendingPartnerReferrerRef" = (select id from "PartnerReferrerDO" where "supplierRef" = supplier_wh_texas))
            ;
    -- set parameters in "ExecutionBeanValueDO"
    --PERFORM upsert_eb_value(1330, 'sftp://user:pass@localhost:21', communicationPartner); --FTP_JOB_PULL_FTP_ACCOUNT
    PERFORM upsert_eb_value(1331, localdirectory, communicationPartner);      --FTP_JOB_PULL_DIRECTORY
    PERFORM upsert_eb_value(1332, 'importarticle/in/', communicationPartner); --FTP_JOB_PUSH_DIRECTORY
    PERFORM upsert_eb_value(1333, fileNameRegex, communicationPartner);       --FTP_JOB_PULL_FILENAME_REGEX
    --PERFORM upsert_eb_value(1338, 'project-files/private-keys/rsa-key-sftp', communicationPartner);

END;


-- RESUME velocity parser
]]#
$do;