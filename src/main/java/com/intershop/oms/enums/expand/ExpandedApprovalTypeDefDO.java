package com.intershop.oms.enums.expand;

import java.util.EnumSet;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.common.ApprovalTypeDefDO;
import bakery.persistence.dataobject.configuration.common.ObjectTypeDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.DeploymentConfig;
import bakery.util.StringUtils;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Transient;

@ExpandedEnum(ApprovalTypeDefDO.class)
public enum ExpandedApprovalTypeDefDO implements EnumInterface
{
    /**
     * Start with 10000 to avoid conflict with ApprovalTypeDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */
    PAYMENT_METHOD(Integer.valueOf(10000), "" /* uses a decision bean instead of jndi */,
            "ExampleApproval Description", ObjectTypeDefDO.ORDER);

    private Integer id;
    private String jndiName;
    private String description;
    private ObjectTypeDefDO objectTypeDefDO;

    private ExpandedApprovalTypeDefDO( Integer id, String jndiName, String description, ObjectTypeDefDO objectTypeDefDO)
    {
        this.id = id;
        this.description = description;
        if ( jndiName != null )
        {
            this.jndiName = String.format( jndiName, DeploymentConfig.APP_VERSION );
        }
        this.objectTypeDefDO = objectTypeDefDO;
    }

    @Override
    @Id
    public Integer getId()
    {
        return this.id;
    }

    @Override
    @Column( name = "`name`" )
    public String getName()
    {
        return StringUtils.constantToHungarianNotation( name(), false );
    }

    @Column(name = "`description`")
    public String getDescription()
    {
        return this.description;
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return this.jndiName;
    }

    /**
     * get list of expanded enums
     * @return
     */
    @Transient
    public final EnumSet<ExpandedApprovalTypeDefDO> getExpandedEnums()
    {
        return EnumSet.allOf( ExpandedApprovalTypeDefDO.class );
    }

    @Override
    @Transient
    public ObjectTypeDefDO getObjectTypeDefDO()
    {
        return objectTypeDefDO;
    }

    /**
     * get list of all enums
     * @return
     */
    @Transient
    public final EnumSet<ApprovalTypeDefDO> getAllEnums()
    {
        return EnumSet.allOf( ApprovalTypeDefDO.class );
    }

    // persist a reference to the  ObjectType within the database too
    @Column(name = "`ObjectTypeName`")
    public String getObjectTypeName()
    {
        return this.getObjectTypeDefDO().getName();
    }
    
}
