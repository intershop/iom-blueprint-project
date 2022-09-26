/**
 *
 */
package com.intershop.oms.enums.expand;

import java.util.Collection;
import java.util.Set;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.common.RoleDefDO;
import bakery.persistence.dataobject.configuration.connections.TransmissionTypeDefDO;
import bakery.persistence.dataobject.mail.ShopCustomerMailTransmissionDO;
import bakery.persistence.dataobject.order.AbstractTransmission;
import bakery.persistence.expand.MessageTypeDefDOEnumInterface;
import bakery.persistence.expand.TransmissionTypeDefDOEnumInterface;

@ExpandedEnum(TransmissionTypeDefDO.class)
public enum ExpandedTransmissionTypeDefDO implements TransmissionTypeDefDOEnumInterface
{

    /**
     * Start with 10000 to avoid conflict with TransmissionTypeDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */

    // Mails to customers of a shop
    EXAMPLE_SEND_CUSTOMER_MAIL_ORDER(-9999, "exampleSendCustomerMailOrder", RoleDefDO.CUSTOMER, ExpandedMessageTypeDefDO.EXAMPLE_SEND_CUSTOMER_MAIL_ORDER, "send customer order mail", Set
                    .of(ShopCustomerMailTransmissionDO.class));

    private Integer id;
    private String name;
    private RoleDefDO roleDefDO;
    private Integer roleDefRef;
    private MessageTypeDefDOEnumInterface messageTypeDefDO;
    private String description;
    private Collection<Class<? extends AbstractTransmission>> transmissionTypeGroups;

    private ExpandedTransmissionTypeDefDO(Integer id, String name, RoleDefDO roleDefDO,
                    MessageTypeDefDOEnumInterface messageTypeDefDO, String description,
                    Collection<Class<? extends AbstractTransmission>> transmissionTypeGroups)
    {
        this.name = name;
        this.id = id;
        this.roleDefDO = roleDefDO;
        this.roleDefRef = roleDefDO.getId();
        this.messageTypeDefDO = messageTypeDefDO;
        this.description = description;
        this.transmissionTypeGroups = transmissionTypeGroups;
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
    public RoleDefDO getRoleDefDO()
    {
        return this.roleDefDO;
    }

    @Override
    public Integer getRoleDefRef()
    {
        return this.roleDefRef;
    }

    @Override
    public MessageTypeDefDOEnumInterface getMessageTypeDefDO()
    {
        return this.messageTypeDefDO;
    }

    @Override
    public String getFieldName()
    {
        return this.name();
    }

    @Override
    public String getDescription()
    {
        return description;
    }

    @Override
    public Collection<Class<? extends AbstractTransmission>> getTransmissionTypeGroups()
    {
        return transmissionTypeGroups;
    }

}
