package com.intershop.oms.enums.expand;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Transient;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.configuration.connections.ExecutionBeanKeyDefDO;
import bakery.persistence.dataobject.configuration.connections.ParameterTypeDefDO;
import bakery.persistence.expand.ExecutionBeanKeyDefDOEnumInterface;

@PersistedEnumerationTable(ExecutionBeanKeyDefDO.class)
public enum ExpandedExecutionBeanKeyDefDO implements ExecutionBeanKeyDefDOEnumInterface
{

    /**
     * Start with 10000 to avoid conflict with ExecutionBeanKeyDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */

	 CUSTOM_WISH(-1, ExpandedExecutionBeanDefDO.CUSTOM_ORDER_MESSAGE_TRANSMITTER.getId(), "customWish", ParameterTypeDefDO.UNSPECIFIED, false, null );
   //  EXAMPLE_SHOPCUSTOMERMAILSENDERBEAN_SHOP_EMAIL_ADDRESS( 10001, ExpandedExecutionBeanDefDO.CUSTOM_ORDER_MESSAGE_TRANSMITTER.getId(), "shopEmailAddress", ParameterTypeDefDO.EMAIL, ExecutionBeanKeyDefDO.Flag.OPTIONAL, null);
	
    private Integer id;
    private Integer executionBeanDefRef;
    private String parameterKey;
    private ParameterTypeDefDO parameterTypeDefDO;
    private Boolean mandatory;
    private String defaultValue;
    @Deprecated (since="4.1.0", forRemoval=true)
    private Boolean activeOMT=false;

    private ExpandedExecutionBeanKeyDefDO(int id, Integer executionBeanDefRef, String parameterKey,
                    ParameterTypeDefDO parameterTypeDefDO, boolean mandatory, String defaultValue)
    {
        this.id = Integer.valueOf(id);
        this.executionBeanDefRef = executionBeanDefRef;
        this.parameterKey = parameterKey;
        this.setParameterTypeDefDO(parameterTypeDefDO);
        this.mandatory = Boolean.valueOf(mandatory);
        this.defaultValue = defaultValue;
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
    @Column(name = "`executionBeanDefRef`")
    public Integer getExecutionBeanDefRef()
    {
        return this.executionBeanDefRef;
    }

    protected void setExecutionBeanDefRef(Integer executionBeanDefRef)
    {
        this.executionBeanDefRef = executionBeanDefRef;
    }

    @Override
    @Column(name = "`parameterKey`", length = ExecutionBeanKeyDefDO.KEY_LENGTH)
    public String getParameterKey()
    {
        return this.parameterKey;
    }

    protected void setParameterKey(String parameterKey)
    {
        this.parameterKey = parameterKey;
    }

    @Override
    @Column(name = "`parameterTypeDefRef`")
    public Integer getParameterTypeDefRef()
    {
        return this.parameterTypeDefDO.getId();
    }

    protected void setParameterTypeDefRef(Integer paramterTypeDefRef)
    {
        this.parameterTypeDefDO = ParameterTypeDefDO.valueOf(paramterTypeDefRef);
    }

    @Override
    @Transient
    public ParameterTypeDefDO getParameterTypeDefDO()
    {
        return this.parameterTypeDefDO;
    }

    protected void setParameterTypeDefDO(ParameterTypeDefDO parameterTypeDefDO)
    {
        this.parameterTypeDefDO = parameterTypeDefDO;
    }

    @Override
    @Column(name = "`mandatory`")
    public Boolean getMandatory()
    {
        return this.mandatory;
    }

    protected void setMandatory(Boolean mandatory)
    {
        this.mandatory = mandatory;
    }

    /**
     * Default parameter value of parameterKey.
     * Max accepted length {@value ExecutionBeanKeyDefDO#VALUE_LENGTH}.
     */
    @Override
    @Column(name = "`defaultValue`", length = ExecutionBeanKeyDefDO.VALUE_LENGTH)
    public String getDefaultValue()
    {
        return this.defaultValue;
    }

    protected void setDefaultValue(String defaultValue)
    {
        this.defaultValue = defaultValue;
    }
    @Deprecated (since="4.1.0", forRemoval=true)
    @Column(name = "`activeOMT`")
    public Boolean isActiveOMT()
    {
        return this.activeOMT;
    }

    @Deprecated (since="4.1.0", forRemoval=true)
    public void setActiveOMT(Boolean activeOMT)
    {
        this.activeOMT = activeOMT;
    }

}
