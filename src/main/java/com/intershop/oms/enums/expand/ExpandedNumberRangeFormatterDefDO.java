package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.common.NumberRangeFormatterDefDO;
import bakery.persistence.expand.NumberRangeFormatterEnumInterface;

@ExpandedEnum(NumberRangeFormatterDefDO.class)
public enum ExpandedNumberRangeFormatterDefDO implements NumberRangeFormatterEnumInterface
{

    /**
     * Start with 10000 to avoid conflict with NumberRangeFormatterDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */

    EXAMPLE(-9999, "EXAMPLE_INVOICENO_GENERATOR", "java:global/blueprint-app/blueprint-ejb/ExampleNumberRangeSequencerBean!bakery.logic.service.configuration.NumberRangeFormatterService")
    ;

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
    public String getName()
    {
        return this.getJndiName();
    }

    @Override
    public String getJndiName()
    {
        return jndiName;
    }

    @Override
    public String getDescription()
    {
        return description;
    }

}
