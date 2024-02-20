package com.intershop.oms.enums.expand;

import java.util.EnumSet;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.common.NumberRangeFormatterDefDO;
import bakery.persistence.expand.NumberRangeFormatterEnumInterface;
import bakery.util.DeploymentConfig;
import bakery.util.StringUtils;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Transient;

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

    private ExpandedNumberRangeFormatterDefDO(Integer id, String description, String jndiName)
    {
        this.id = id;
        this.description = description;
        this.jndiName = String.format(jndiName, DeploymentConfig.APP_VERSION);
    }

    @Override
    @Id
    public Integer getId()
    {
        return id;
    }

    @Override
    @Transient
    public String getName()
    {
        return StringUtils.constantToHungarianNotation(name(), false);
    }

    @Override
    @Column(name = "description")
    public String getDescription()
    {
        return description;
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return jndiName;
    }

    /**
     * get list of expanded enums
     * @return
     */
    @Transient
    public final EnumSet<ExpandedNumberRangeFormatterDefDO> getExpandedEnums()
    {
        return EnumSet.allOf(ExpandedNumberRangeFormatterDefDO.class);
    }

    /**
     * get list of all enums
     * @return
     */
    @Transient
    public final EnumSet<NumberRangeFormatterDefDO> getAllEnums()
    {
        return EnumSet.allOf(NumberRangeFormatterDefDO.class);
    }
    
}
