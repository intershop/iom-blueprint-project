package com.intershop.oms.enums.expand;

import javax.persistence.Column;
import javax.persistence.Transient;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.configuration.common.NumberRangeFormatterDefDO;
import bakery.persistence.expand.NumberRangeFormatterEnumInterface;

@PersistedEnumerationTable(NumberRangeFormatterDefDO.class)
public enum ExpandedNumberRangeFormatterDefDO implements NumberRangeFormatterEnumInterface
{

    /**
     * Minimum ID for custom entries: 1000
     */
    EXAMPLE(-999, "EXAMPLE_INVOICENO_GENERATOR", "java:global/blueprint-app/blueprint-ejb/ExampleNumberRangeSequencerBean!bakery.logic.service.configuration.NumberRangeFormatterService"),;
    private Integer id;
    private String jndiName;
    private String description;

    private ExpandedNumberRangeFormatterDefDO(int id, String description, String jndiName)
    {
        this.id = id;
        this.description = description;
        this.jndiName = jndiName;
    }

    @Override
    public Integer getId()
    {
        return id;
    }

    @Override
    @Transient
    public String getName()
    {
        return this.getJndiName();
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return jndiName;
    }

    @Override
    @Column(name = "`description`")
    public String getDescription()
    {
        return description;
    }

}
