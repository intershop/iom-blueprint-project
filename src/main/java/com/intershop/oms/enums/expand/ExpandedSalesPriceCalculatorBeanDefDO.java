package com.intershop.oms.enums.expand;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Transient;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.configuration.salesprice.SalesPriceCalculatorBeanDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.StringUtils;

@PersistedEnumerationTable(SalesPriceCalculatorBeanDefDO.class)
public enum ExpandedSalesPriceCalculatorBeanDefDO implements EnumInterface
{
    /**
     * PLEASE START AFTER EXAMPLE WITH ID 1000 and go up THATS IMPORTANT !!!
     */
    EXAMPLE(-999, "java:global/blueprint-app/blueprint-ejb/ExampleCalculatorBean!bakery.logic.service.util.SalesPriceCalculator")
    ;

    private Integer id;
    private String jndiName;

    private ExpandedSalesPriceCalculatorBeanDefDO(Integer id, String jndiName)
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
