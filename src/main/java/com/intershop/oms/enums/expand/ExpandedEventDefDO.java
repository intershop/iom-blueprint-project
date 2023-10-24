package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.event.EventDefDO;
import bakery.persistence.expand.EventDefDOEnumInterface;

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
    public Integer getId()
    {
        return id;
    }

    @Override
    public String getDescription()
    {
        return this.description;
    }

    /**
     * @return the JNDI-name of the event
     */
    @Override
    public String getName()
    {
        return String.format(this.jndiName, bakery.util.DeploymentConfig.APP_VERSION);
    }

}
