package com.intershop.oms.enums.expand;

import java.util.EnumSet;
import java.util.Set;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.connections.MessageTypeDefDO;
import bakery.persistence.expand.MessageTypeDefDOEnumInterface;
import jakarta.persistence.Column;
import jakarta.persistence.Transient;

@ExpandedEnum(MessageTypeDefDO.class)
public enum ExpandedMessageTypeDefDO implements MessageTypeDefDOEnumInterface
{
    /**
     * Start with 10000 to avoid conflict with MessageTypeDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */
    APPROVAL_NOTIFICATION (10000, "Approval notification");

    private Integer id;
    private String name;
    private String description;

    private ExpandedMessageTypeDefDO(int id, String description)
    {
        this.id = Integer.valueOf(id);
        this.name = this.name();
        this.description = description;
    }

    @Override
    public Integer getId()
    {
        return this.id;
    }

    @Override
    @Column( name = "name")
    public String getName()
    {
        return this.name;
    }

    @Override
    @Column( name = "description" )
    public String getDescription()
    {
        return this.description;
    }

    /**
     * get list of expanded enums
     * 
     * @return
     */
    @Transient
    public final Set<ExpandedMessageTypeDefDO> getExpandedEnums()
    {
        return EnumSet.allOf(ExpandedMessageTypeDefDO.class);
    }
    
    /**
     * get list of all enums
     * 
     * @return
     */
    @Transient
    public final Set<MessageTypeDefDO> getAllEnums()
    {
        return EnumSet.allOf(MessageTypeDefDO.class);
    }

}
