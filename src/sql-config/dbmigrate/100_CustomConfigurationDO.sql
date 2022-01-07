DO $Do$
BEGIN

    IF false = admin.is_table('oms', 'CustomConfigurationDO') THEN
        CREATE TABLE oms."CustomConfigurationDO"
        (
            id bigint,
            "shop2SupplierRef" bigint,
            "configType" character varying(255) NOT NULL,
            CONSTRAINT "CustomConfigurationDO_pkey" PRIMARY KEY (id),
            CONSTRAINT "Shop2SupplierDO_fkey" FOREIGN KEY ("shop2SupplierRef") REFERENCES oms."Shop2SupplierDO" (id) ON UPDATE NO ACTION ON DELETE NO ACTION
        )
        WITH (
          OIDS = FALSE
        )
        ;
        CREATE SEQUENCE oms."CustomConfigurationDO_id_seq";
    END IF;


    IF false = admin.is_table('oms', 'CustomConfigurationDO_AV') THEN
        CREATE TABLE oms."CustomConfigurationDO_AV"
        (
          "customConfigurationRef" bigint NOT NULL,
          key character varying(255) NOT NULL,
          value text NOT NULL,
          CONSTRAINT pk_ref_key PRIMARY KEY ("customConfigurationRef", key),
          CONSTRAINT "fk_customConfigurationRef" FOREIGN KEY ("customConfigurationRef")
              REFERENCES oms."CustomConfigurationDO" (id) MATCH SIMPLE
              ON UPDATE NO ACTION ON DELETE NO ACTION
        )
        WITH (
          OIDS=FALSE
        );
    END IF;


END;
$Do$;
