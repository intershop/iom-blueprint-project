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
    // start with 1000 to avoid conflicts with ChargeTypeDefDO
    // the name must be unique across both classes
	CONTAINER_SERVICE_CHARGE(Integer.valueOf(1000), "Container Service Charge", "Container Charge", "Container Service Charges");



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

    /**
     * @return Id of the charge type
     */
    @Override
    @Id
    public Integer getId()
    {
        return this.id;
    }
    
    /**
     * @param id
     *      the Id of the charge type
     */
    public void setId(Integer id)
    {
        this.id = id;
    }

    /**
     * @return the name of the charge type
     */
    @Override
    @Column(name="`name`", length = 50, nullable = false)
    public String getName()
    {
        return this.name;
    }
    
    /**
     * @param name
     *      the name of the charge type
     */
    public void setName(String name)
    {
        this.name = name;
    }
    
    /**
     * @param description
     *      the description of the charge type
     */
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

    /**
     * @return the type of charge
     */
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
    @Transient // persisted since 4.1.0, as @Column(name = "`chargeType`")
    public String getEnumName()
    {
        return name();
    }

    public void setEnumName(String enumName)
    {
        //required by hibernate
    }
    
}
