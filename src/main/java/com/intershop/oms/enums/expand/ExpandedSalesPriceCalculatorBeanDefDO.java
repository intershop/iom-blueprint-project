package com.intershop.oms.enums.expand;

import java.util.EnumSet;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.salesprice.SalesPriceCalculatorBeanDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.DeploymentConfig;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Transient;

@ExpandedEnum(SalesPriceCalculatorBeanDefDO.class)
public enum ExpandedSalesPriceCalculatorBeanDefDO implements EnumInterface {

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
        this.jndiName = String.format(jndiName, DeploymentConfig.APP_VERSION);
    }

    @Override
    @Id
    public Integer getId(){
        
        return this.id;
    }

    @Override
    @Column(name = "description")
    public String getName()
    {
        return this.name();
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return this.jndiName;
    }

    /**
     * get list of expanded enums
     * 
     * @return
     */
    @Transient
    public final EnumSet<ExpandedSalesPriceCalculatorBeanDefDO> getExpandedEnums()
    {
        return EnumSet.allOf(ExpandedSalesPriceCalculatorBeanDefDO.class);
    }

    /**
     * get list of all enums
     * 
     * @return
     */
    @Transient
    public final EnumSet<SalesPriceCalculatorBeanDefDO> getAllEnums()
    {
        return EnumSet.allOf(SalesPriceCalculatorBeanDefDO.class);
    }
    
}