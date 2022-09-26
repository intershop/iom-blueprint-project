package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.common.ApprovalTypeDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.StringUtils;

@ExpandedEnum(ApprovalTypeDefDO.class)
public enum ExpandedApprovalTypeDefDO implements EnumInterface
{

    /**
     * Start with 10000 to avoid conflict with ApprovalTypeDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */
    PAYMENT_METHOD(Integer.valueOf(10000), "") // uses a decision bean instead of jndi
    ;

    private Integer id;
    private String jndiName;

    private ExpandedApprovalTypeDefDO(Integer id, String jndiName)
    {
        this.id = id;
        this.jndiName = jndiName;
    }

    @Override
    public Integer getId()
    {
        return this.id;
    }

    @Override
    public String getName()
    {
        return StringUtils.constantToHungarianNotation(this.name(), false);
    }

    @Override
    public String getJndiName()
    {
        return this.jndiName;
    }

}
