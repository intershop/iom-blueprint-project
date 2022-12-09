package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.common.ChargeTypeDefDO;
import bakery.persistence.expand.ChargeTypeDefDOEnumInterface;

@ExpandedEnum(ChargeTypeDefDO.class)
public enum ExpandedChargeTypeDefDO implements ChargeTypeDefDOEnumInterface
{
    /**
     * Start with 10000 to avoid conflict with DecisionBeanDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */
	CONTAINER_SERVICE_CHARGE(Integer.valueOf(1000), "Container Service Charge", "Container service charge", "Container service charges");

    private Integer id;
    private String name;
    private String chargeType;
    private String description;

    private ExpandedChargeTypeDefDO(Integer id, String name, String chargeType, String description)
    {
        this.id = id;
        this.name = name;
        this.chargeType = chargeType;
        this.description = description;
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

    @Override
    public String getDescription()
    {
        return this.description;
    }


    @Override
    public String getChargeType()
    {
        return this.chargeType;
    }

    /**
    * @return the enum name of the charge type
    */
    @Override
    public String getEnumName()
    {
    	return name();
    }

}
