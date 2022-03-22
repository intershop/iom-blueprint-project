package com.intershop.oms.enums.expand;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Transient;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.article.configuration.ImportConfigurationBeanDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.StringUtils;

@PersistedEnumerationTable(ImportConfigurationBeanDefDO.class)
public enum ExpandedImportConfigurationBeanDefDO implements EnumInterface
{

    /**
     * Start with 10000 to avoid conflict with ImportConfigurationBeanDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */

    EXAMPLE(-999, "java:global/blueprint-app/blueprint-ejb/ExampleImportConfigurationBean!bakery.logic.job.transformation.Transformer")
    ;

    private Integer id;
    private String jndiName;

    private ExpandedImportConfigurationBeanDefDO(Integer id, String jndiName)
    {
        this.id = id;
        this.jndiName = jndiName;
    }

    @Override
    @Id
    public Integer getId()
    {
        return this.id;
    }

    @Override
    @Column(name = "`description`")
    public String getName()
    {
        return StringUtils.constantToHungarianNotation(this.name(), StringUtils.FLAG_FIRST_LOWER);
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return this.jndiName;
    }

}
