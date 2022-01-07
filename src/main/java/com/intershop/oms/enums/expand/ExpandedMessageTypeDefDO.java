package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.configuration.connections.MessageTypeDefDO;
import bakery.persistence.expand.MessageTypeDefDOEnumInterface;

@PersistedEnumerationTable(MessageTypeDefDO.class)
public enum ExpandedMessageTypeDefDO implements MessageTypeDefDOEnumInterface
{

    /**
     * Minimum ID for custom entries: 1000
     */
    EXAMPLE_SEND_CUSTOMER_MAIL_ORDER( -9999, "Send customer mail - order" )
    ;


    private Integer id;
    private String description;

    private ExpandedMessageTypeDefDO(Integer id, String description)
    {
        this.id = id;
        this.description = description;
    }

    @Override
    public Integer getId()
    {
        return id;
    }

    @Override
    public String getName()
    {
        return name();
    }

    @Override
    public String getDescription()
    {
        return description;
    }

}
