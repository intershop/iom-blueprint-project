package com.intershop.oms.enums.expand; 

import java.util.ArrayList;
import java.util.List;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.connections.ExecutionBeanDefDO;
import bakery.persistence.dataobject.configuration.connections.ExecutionBeanKeyDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.persistence.expand.ExecutionBeanDefDOEnumInterface;
import bakery.persistence.expand.ExecutionBeanKeyDefDOEnumInterface;
import bakery.util.StringUtils;

@ExpandedEnum(ExecutionBeanDefDO.class)
public enum ExpandedExecutionBeanDefDO implements ExecutionBeanDefDOEnumInterface
{

    /**
     * Start with 10000 to avoid conflict with ExecutionBeanDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */
    SHOP_MESSAGE_TRANSMITTER(Integer.valueOf(10000), "java:global/iom-blueprint-project/ShopMessageTransmitterBean!bakery.logic.service.transmission.MessageTransmitter", null),
    SUPPLIER_MESSAGE_TRANSMITTER(Integer.valueOf(20000), "java:global/iom-blueprint-project/SupplierMessageTransmitterBean!bakery.logic.service.transmission.MessageTransmitter", null),
    CUSTOM_MAIL_TRANSMITTER(Integer.valueOf(30000), "java:global/iom-blueprint-project/AnotherMailTransmitterBean!bakery.logic.service.transmission.MessageTransmitter", null),
    ;

    private Integer id;
    private String jndiName;
    private EnumInterface decisionBeanDefDO;

    private ExpandedExecutionBeanDefDO(Integer id, String jndiName, EnumInterface decisionBeanDefDO)
    {
        this.id = id;
        this.jndiName = jndiName;
        this.decisionBeanDefDO = decisionBeanDefDO;
    }

    @Override
    public Integer getId()
    {
        return id;
    }

    @Override
    public String getName()
    {
        return StringUtils.constantToHungarianNotation(this.name(), StringUtils.FLAG_FIRST_LOWER);
    }

    @Override
    public String getJndiName()
    {
        return jndiName;
    }

    @Override
    public EnumInterface getDecisionBean()
    {
        return this.decisionBeanDefDO;
    }

    @Override
    public List<ExecutionBeanKeyDefDOEnumInterface> getExecutionBeanKeyList()
    {
        final List<ExecutionBeanKeyDefDOEnumInterface> executionBeanKeyList = new ArrayList<>();

        for (final ExecutionBeanKeyDefDOEnumInterface executionBeanKeyDefDO : ExecutionBeanKeyDefDO.getValues())
        {
            if (executionBeanKeyDefDO.getExecutionBeanDefRef().equals(this.getId()))
            {
                executionBeanKeyList.add(executionBeanKeyDefDO);
            }
        }

        return executionBeanKeyList;
    }

}
