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
     * Minimum ID for custom entries: 10000
     */
    EXAMPLE(-10010, "")
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
