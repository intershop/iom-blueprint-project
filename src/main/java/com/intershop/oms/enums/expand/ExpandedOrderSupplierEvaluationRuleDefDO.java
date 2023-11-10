package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.common.OrderSupplierEvaluationRuleDefDO;
import bakery.persistence.expand.OrderSupplierEvaluationRuleDefDOEnumInterface;

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

    private ExpandedOrderSupplierEvaluationRuleDefDO(Integer id, String name, String description, String jndiName, int rank, boolean mandatory)
    {
        this.id = id;
        this.name = name;
        this.jndiName = jndiName;
        this.description = description;
        this.rank = rank;
        this.mandatory = mandatory;
    }

    @Override
    public Integer getId()
    {
        return this.id;
    }

    @Override
    public String getName()
    {
        return this.name;
    }

    /**
     * Sorted priority the rule should be check in.
     */
    @Override
    public int getRank()
    {
        return this.rank;
    }

    /**
     * @return Whether the rule must not be disabled or not.
     */
    @Override
    public boolean isMandatory()
    {
        return this.mandatory;
    }

    @Override
    public String getJndiName()
    {
        return this.jndiName;
    }

    @Override
    public String getDescription()
    {
        return this.description;
    }

}
