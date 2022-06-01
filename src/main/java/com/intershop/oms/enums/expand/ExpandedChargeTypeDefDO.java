package com.intershop.oms.enums.expand;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Transient;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.configuration.common.ChargeTypeDefDO;
import bakery.persistence.expand.ChargeTypeDefDOEnumInterface;

@PersistedEnumerationTable(ChargeTypeDefDO.class)
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
    @Id
    public Integer getId()
    {
        return this.id;
    }
    
    public void setId(Integer id)
    {
        this.id = id;
    }

    @Override
    @Column(name="`name`", length = 50, nullable = false)
    public String getName()
    {
        return this.name;
    }
    
    public void setName(String name)
    {
        this.name = name;
    }
    
    @Override
    @Column(name = "`description`")
    public String getDescription()
    {
        return this.description;
    }

    @SuppressWarnings( "unused" )
    protected void setDescription(String description)
    {
        //dummy setter for the needs of hibernate
    }

    @Override
    @Transient
    public String getChargeType()
    {
        return this.chargeType;
    }
    
    /**
    * @return the enum name of the charge type
    */
    @Override
    @Column(name = "`chargeType`")
    public String getEnumName()
    {
    	return name();
    }

    public void setEnumName(String enumName)
    {
        //required by hibernate
    }
    
}
