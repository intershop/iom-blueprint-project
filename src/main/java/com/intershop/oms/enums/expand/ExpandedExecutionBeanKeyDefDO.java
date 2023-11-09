package com.intershop.oms.enums.expand;

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

	// CUSTOM_WISH(-9999, ExpandedExecutionBeanDefDO.CUSTOM_ORDER_MESSAGE_TRANSMITTER.getId(), "customWish", ParameterTypeDefDO.UNSPECIFIED, false, null );
    // EXAMPLE_SHOPCUSTOMERMAILSENDERBEAN_SHOP_EMAIL_ADDRESS(Integer.valueOf(10001), ExpandedExecutionBeanDefDO.CUSTOM_ORDER_MESSAGE_TRANSMITTER.getId(), "shopEmailAddress", ParameterTypeDefDO.EMAIL, ExecutionBeanKeyDefDO.Flag.OPTIONAL, null);
    ;

    private Integer id;
    private Integer executionBeanDefRef;
    private String parameterKey;
    private ParameterTypeDefDO parameterTypeDefDO;
    private Boolean mandatory;
    private String defaultValue;

    private ExpandedExecutionBeanKeyDefDO(int id, Integer executionBeanDefRef, String parameterKey,
                    ParameterTypeDefDO parameterTypeDefDO, boolean mandatory, String defaultValue)
    {
        this.id = Integer.valueOf(id);
        this.executionBeanDefRef = executionBeanDefRef;
        this.parameterKey = parameterKey;
        this.parameterTypeDefDO = parameterTypeDefDO;
        this.mandatory = Boolean.valueOf(mandatory);
        this.defaultValue = defaultValue;
    }

    @Override
    public Integer getId()
    {
        return this.id;
    }


    @Override
    public Integer getExecutionBeanDefRef()
    {
        return this.executionBeanDefRef;
    }

    @Override
    public String getParameterKey()
    {
        return this.parameterKey;
    }

    @Override
    public Integer getParameterTypeDefRef()
    {
        return this.parameterTypeDefDO.getId();
    }

    @Override
    public ParameterTypeDefDO getParameterTypeDefDO()
    {
        return this.parameterTypeDefDO;
    }

    @Override
    public Boolean getMandatory()
    {
        return this.mandatory;
    }

    /**
     * Default parameter value of parameterKey.
     * Max accepted length {@value ExecutionBeanKeyDefDO#VALUE_LENGTH}.
     */
    @Override
    public String getDefaultValue()
    {
        return this.defaultValue;
    }

}
