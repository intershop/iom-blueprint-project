package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.event.EventDefDO;
import bakery.persistence.expand.EventDefDOEnumInterface;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Transient;

@ExpandedEnum(EventDefDO.class)
public enum ExpandedEventDefDO implements EventDefDOEnumInterface
{

    /**
     * Start with 10000 to avoid conflict with EventDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */
    CUSTOM_MAIL_EVENT_MANAGER(-9999, "CUSTOM_MAIL_EVENT_MANAGER_BEAN", "java:global/example-app/CustomMailEventManagerBean");

    private Integer id;
    private String description;
    private String jndiName;

    private ExpandedEventDefDO(Integer id, String description, String jndiName)
    {
        this.id = id;
        this.description = description;
        this.jndiName = jndiName;
    }

    @Override
    @Id
    public Integer getId()
    {
        return id;
    }

    protected void setId(Integer id)
    {
        this.id = id;
    }

    @Override
    @Column(name = "`description`")
    public String getDescription()
    {
        return description;
    }

    public void setDescription(String description)
    {
        this.description = description;
    }

    /**
     * @return the JNDI-name of the event.
     */
    @Override
    @Transient
    public String getName()
    {
        return this.getJndiName();
    }

    @Transient
    public String getJndiName()
    {
        return String.format(jndiName, bakery.util.DeploymentConfig.APP_VERSION);
    }
    
}

