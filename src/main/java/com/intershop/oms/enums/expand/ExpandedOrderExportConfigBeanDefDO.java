package com.intershop.oms.enums.expand;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Transient;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.configuration.order.OrderExportConfigBeanDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.StringUtils;

@PersistedEnumerationTable(OrderExportConfigBeanDefDO.class)
public enum ExpandedOrderExportConfigBeanDefDO implements EnumInterface
{

    /**
     * Minimum ID for custom entries: 1000
     */
    EXAMPLE(-999, "java:global/blueprint-app/blueprint-ejb/ExampleOrderExportConfigBean!bakery.logic.job.transformation.Transformer")
    ;


    private Integer id;
    private String jndiName;

    private ExpandedOrderExportConfigBeanDefDO(Integer id, String jndiName)
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
