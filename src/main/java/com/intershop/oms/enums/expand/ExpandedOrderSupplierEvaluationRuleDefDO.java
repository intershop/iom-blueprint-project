package com.intershop.oms.enums.expand;

import java.util.EnumSet;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.common.OrderSupplierEvaluationRuleDefDO;
import bakery.persistence.expand.OrderSupplierEvaluationRuleDefDOEnumInterface;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Transient;

@ExpandedEnum(OrderSupplierEvaluationRuleDefDO.class)
public enum ExpandedOrderSupplierEvaluationRuleDefDO implements OrderSupplierEvaluationRuleDefDOEnumInterface
{

    /**
     * Start with 10000 to avoid conflict with OrderSupplierEvaluationRuleDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */

    ONE_SUPPLIER_ONLY_CHECK(Integer.valueOf(10000), "SupplierHasStockCheckPTBean", "Filters for suppliers that have stock to deliver.", "java:global/iom-blueprint-project/SupplierHasStockCheckPTBean!bakery.logic.service.order.task.OrderSupplierCheckPT", 1000, false)
    ;

    private Integer id;
    private String name;
    private String description;
    private String jndiName;
    private int rank;
    private boolean mandatory;

    private ExpandedOrderSupplierEvaluationRuleDefDO(Integer id, String name, String description, String jndiName,
            int rank, boolean mandatory)
    {
        this.id = id;
        this.name = name;
        this.jndiName = jndiName;
        this.description = description;
        this.rank = rank;
        this.mandatory = mandatory;
    }

    @Override
    @Id
    public Integer getId()
    {
        return id;
    }

    protected void setId(Integer id)
    {
        this.id = id;
    }

    @Override
    @Column(name = "name", length = 50, nullable = false)
    public String getName()
    {
        return name;
    }

    public void setName(String name)
    {
        this.name = name;
    }

    @Override
    @Column(name = "rank", nullable = false)
    public int getRank()
    {
        return rank;
    }

    public void setRank(int rank)
    {
        this.rank = rank;
    }

    @Override
    @Column(name = "mandatory", nullable = false)
    public boolean isMandatory()
    {
        return mandatory;
    }

    public void setMandatory(boolean mandatory)
    {
        this.mandatory = mandatory;
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return String.format(this.jndiName, bakery.util.DeploymentConfig.APP_VERSION);
    }

    @Transient
    public final EnumSet<ExpandedOrderSupplierEvaluationRuleDefDO> getExpandedEnums()
    {
        return EnumSet.allOf(ExpandedOrderSupplierEvaluationRuleDefDO.class);
    }

    @Transient
    public final EnumSet<OrderSupplierEvaluationRuleDefDO> getAllEnums()
    {
        return EnumSet.allOf(OrderSupplierEvaluationRuleDefDO.class);
    }

    @Override
    @Column(name = "description", length = 100, nullable = false)
    public String getDescription()
    {
        return description;
    }

    public void setDescription(String description)
    {
        this.description = description;
    }
    
}