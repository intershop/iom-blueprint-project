package com.intershop.oms.enums.expand;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Transient;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.configuration.common.OrderSupplierEvaluationRuleDefDO;
import bakery.persistence.expand.OrderSupplierEvaluationRuleDefDOEnumInterface;

@PersistedEnumerationTable(OrderSupplierEvaluationRuleDefDO.class)
public enum ExpandedOrderSupplierEvaluationRuleDefDO implements OrderSupplierEvaluationRuleDefDOEnumInterface
{

    /**
     * Start with 10000 to avoid conflict with OrderSupplierEvaluationRuleDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */
    
    ONE_SUPPLIER_ONLY_CHECK(10000, "SupplierHasStockCheckPTBean", "Filters for suppliers that have stock to deliver.", "java:global/iom-blueprint-project/SupplierHasStockCheckPTBean!bakery.logic.service.order.task.OrderSupplierCheckPT", 1000, false)
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
    @Id
    public Integer getId()
    {
        return this.id;
    }

    protected void setId(Integer id)
    {
        this.id = id;
    }

    @Override
    @Column(name = "`name`", length = 50, nullable = false)
    public String getName()
    {
        return this.name;
    }

    public void setName(String name)
    {
        this.name = name;
    }

    /**
     * Sorted priority the rule should be check in.
     */
    @Override
    @Column(name = "`rank`", nullable = false)
    public int getRank()
    {
        return this.rank;
    }

    public void setRank(int rank)
    {
        this.rank = rank;
    }

    /**
     * @return Whether the rule must not be disabled or not. 
     */
    @Override
    @Column(name = "`mandatory`", nullable = false)
    public boolean isMandatory()
    {
        return this.mandatory;
    }

    public void setMandatory(boolean mandatory)
    {
        this.mandatory = mandatory;
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return this.jndiName;
    }

    @Override
    @Column(name = "`description`", length = 100, nullable = false)
    public String getDescription()
    {
        return this.description;
    }

    public void setDescription(String description)
    {
        this.description = description;
    }
    
}
