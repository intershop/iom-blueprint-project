package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.connections.MessageTypeDefDO;
import bakery.persistence.expand.MessageTypeDefDOEnumInterface;

@ExpandedEnum(MessageTypeDefDO.class)
public enum ExpandedMessageTypeDefDO implements MessageTypeDefDOEnumInterface
{

    /**
     * Start with 10000 to avoid conflict with MessageTypeDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
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
