package com.intershop.oms.enums.expand;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Transient;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.configuration.common.ApprovalTypeDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.StringUtils;

@PersistedEnumerationTable(ApprovalTypeDefDO.class)
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
    @Id
    public Integer getId()
    {
        return this.id;
    }

    @Override
    @Column(name = "`name`")
    public String getName()
    {
        return StringUtils.constantToHungarianNotation(this.name(), false);
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return this.jndiName;
    }

}
