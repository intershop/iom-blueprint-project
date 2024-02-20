package com.intershop.oms.enums.expand;

import java.util.EnumSet;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.order.OrderExportConfigBeanDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.DeploymentConfig;
import bakery.util.StringUtils;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Transient;

@ExpandedEnum(OrderExportConfigBeanDefDO.class)
public enum ExpandedOrderExportConfigBeanDefDO implements EnumInterface
{

    /**
     * Start with 10000 to avoid conflict with OrderExportConfigBeanDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */

    EXAMPLE(-9999, "java:global/blueprint-app/blueprint-ejb/ExampleOrderExportConfigBean!bakery.logic.job.transformation.Transformer")
    ;

    private Integer id;
    private String jndiName;

    private ExpandedOrderExportConfigBeanDefDO(Integer id, String jndiName)
    {
        this.id = id;
        this.jndiName = String.format(jndiName, DeploymentConfig.APP_VERSION);
    }

    @Override
    @Id
    public Integer getId()
    {
        return id;
    }

    @Override
    @Column(name = "description")
    public String getName()
    {
        return StringUtils.constantToHungarianNotation(name(), StringUtils.FLAG_FIRST_LOWER);
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
    public final EnumSet<ExpandedOrderExportConfigBeanDefDO> getExpandedEnums()
    {
        return EnumSet.allOf(ExpandedOrderExportConfigBeanDefDO.class);
    }

    /**
     * get list of all enums
     * @return
     */
    @Transient
    public final EnumSet<OrderExportConfigBeanDefDO> getAllEnums()
    {
        return EnumSet.allOf(OrderExportConfigBeanDefDO.class);
    }

}
