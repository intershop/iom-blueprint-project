/**
 *
 */
package com.intershop.oms.enums.expand;

import javax.persistence.Transient;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.configuration.common.RoleDefDO;
import bakery.persistence.dataobject.configuration.connections.TransmissionTypeDefDO;
import bakery.persistence.expand.MessageTypeDefDOEnumInterface;
import bakery.persistence.expand.TransmissionTypeDefDOEnumInterface;

@PersistedEnumerationTable(TransmissionTypeDefDO.class)
public enum ExpandedTransmissionTypeDefDO implements TransmissionTypeDefDOEnumInterface
{

    /**
     * Start with 10000 to avoid conflict with TransmissionTypeDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */
    
    // Mails to customers of a shop
    EXAMPLE_SEND_CUSTOMER_MAIL_ORDER( -9999, "exampleSendCustomerMailOrder", RoleDefDO.CUSTOMER, ExpandedMessageTypeDefDO.EXAMPLE_SEND_CUSTOMER_MAIL_ORDER )
    ;

    private Integer id;
    private String name;
    private RoleDefDO roleDefDO;
    private Integer roleDefRef;
    private MessageTypeDefDOEnumInterface messageTypeDefDO;

    private ExpandedTransmissionTypeDefDO(Integer id, String name, RoleDefDO roleDefDO,
                    MessageTypeDefDOEnumInterface messageTypeDefDO)
    {
        this.name = name;
        this.id = id;
        this.roleDefDO = roleDefDO;
        this.roleDefRef = roleDefDO.getId();
        this.messageTypeDefDO = messageTypeDefDO;
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
    @Transient
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
    @Transient
    public MessageTypeDefDOEnumInterface getMessageTypeDefDO()
    {
        return this.messageTypeDefDO;
    }

    @Override
    @Transient
    public String getFieldName()
    {
        return this.name();
    }

}
