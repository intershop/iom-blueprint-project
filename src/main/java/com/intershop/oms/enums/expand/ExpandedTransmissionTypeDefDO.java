package com.intershop.oms.enums.expand;

import java.util.ArrayList;
import java.util.Collection;
import java.util.EnumSet;
import java.util.Set;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.common.RoleDefDO;
import bakery.persistence.dataobject.configuration.connections.TransmissionTypeDefDO;
import bakery.persistence.dataobject.mail.ShopCustomerMailTransmissionDO;
import bakery.persistence.dataobject.order.AbstractTransmission;
import bakery.persistence.expand.MessageTypeDefDOEnumInterface;
import bakery.persistence.expand.TransmissionTypeDefDOEnumInterface;
import jakarta.persistence.Column;
import jakarta.persistence.Transient;

@ExpandedEnum(TransmissionTypeDefDO.class)
public enum ExpandedTransmissionTypeDefDO implements TransmissionTypeDefDOEnumInterface {
    /**
     * Start with 10000 to avoid conflict with TransmissionTypeDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't
     * get persisted within the database).
     */

    // e-mails to customers of a shop
    APPROVAL_NOTIFICATION(Integer.valueOf(10000), "E-mail approval notification", RoleDefDO.BAKERY,
            ExpandedMessageTypeDefDO.APPROVAL_NOTIFICATION, "Approval notification e-mail.",
            ShopCustomerMailTransmissionDO.class);

    private Integer id;
    private String name;
    private RoleDefDO roleDefDO;
    private Integer roleDefRef;
    private MessageTypeDefDOEnumInterface messageTypeDefDO;
    private String description;
    @SuppressWarnings("unused")
    private String messageTypeName;
    private Collection<Class<? extends AbstractTransmission>> transmissionTypeGroups = new ArrayList<>();

    private ExpandedTransmissionTypeDefDO(int id, String name, RoleDefDO roleDefDO,
            MessageTypeDefDOEnumInterface messageTypeDefDO, String description,
            Class<? extends AbstractTransmission> transmissionTypeGroup)
    {
        this.name = name;
        this.id = Integer.valueOf(id);
        this.description = description;
        this.setRoleDefDO(roleDefDO);
        this.messageTypeDefDO = messageTypeDefDO;
        this.messageTypeName = messageTypeDefDO.getName();
        transmissionTypeGroups.add(transmissionTypeGroup);
    }

    @Override
    public Integer getId()
    {
        return this.id;
    }

    @Override
    @Column(name = "name", length = 100, nullable = false)
    public String getName()
    {
        return this.name;
    }

    @Override
    @Column(name = "description")
    public String getDescription()
    {
        return this.description;
    }

    protected void setDescription(String description)
    {
        // dummy setter for the needs of hibernate
    }

    @Override
    public RoleDefDO getRoleDefDO()
    {
        return this.roleDefDO;
    }

    @Override
    @Column(name = "`roleDefRef`", nullable = false)
    public Integer getRoleDefRef()
    {
        return this.roleDefRef;
    }

    protected void setRoleDefRef(Integer roleDefRef)
    {
        this.roleDefRef = roleDefRef;
        this.roleDefDO = RoleDefDO.valueOf(roleDefRef);
    }

    @Deprecated
    public void setRoleDefDO(RoleDefDO roleDefDO)
    {
        this.roleDefRef = roleDefDO.getId();
        this.roleDefDO = RoleDefDO.valueOf(this.roleDefRef);
    }

    @Override
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

    // used to persist a reference to the related enum within the database
    @Column(name = "`messageTypeName`")
    private String getMessageTypeName() {
        return this.messageTypeDefDO.getName();
    }

    @SuppressWarnings("unused")
    private void setMessageTypeName(String typeName)
    {
        this.messageTypeName = typeName;
    }

    /**
     * get list of expanded enums
     *
     * @return
     */
    @Transient
    public final Set<ExpandedTransmissionTypeDefDO> getExpandedEnums()
    {
        return EnumSet.allOf(ExpandedTransmissionTypeDefDO.class);
    }

    @Override
    @Transient
    public Collection<Class<? extends AbstractTransmission>> getTransmissionTypeGroups()
    {
        return transmissionTypeGroups;
    }
}
