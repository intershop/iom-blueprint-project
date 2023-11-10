package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.salesprice.SalesPriceCalculatorBeanDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.StringUtils;

@ExpandedEnum(SalesPriceCalculatorBeanDefDO.class)
public enum ExpandedSalesPriceCalculatorBeanDefDO implements EnumInterface
{

    /**
     * Start with 10000 to avoid conflict with SalesPriceCalculatorBeanDefDO.
     * The name must be unique across both classes. Values with negative id are
     * meant as syntax example and are ignored (won't get persisted within the
     * database).
     */

    EXAMPLE(-9999, "java:global/example-app/ExampleCalculatorBean!bakery.logic.service.util.SalesPriceCalculator");

    private Integer id;
    private String jndiName;

    private ExpandedSalesPriceCalculatorBeanDefDO(Integer id, String jndiName)
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
        return StringUtils.constantToHungarianNotation(this.name(), StringUtils.FLAG_FIRST_LOWER);
    }

    @Override
    public String getJndiName()
    {
        return this.jndiName;
    }

}
