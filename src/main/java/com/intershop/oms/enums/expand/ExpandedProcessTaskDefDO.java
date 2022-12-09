package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.process.ProcessTaskDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.DeploymentConfig;

@ExpandedEnum(ProcessTaskDefDO.class)
public enum ExpandedProcessTaskDefDO implements EnumInterface
{
    /**
     * Start with 10000 to avoid conflict with ProcessTaskDefDO. The name must
     * be unique across both classes. Values with negative id are meant as
     * syntax example and are ignored (won't get persisted within the database).
     */

    EXAMPLE_PT(-999, "CheckSendDebitorPT", "java:global/example-app/SkipSendDebitorPTBean");

    private Integer id;
    private String name;
    private String jndiName;

    private ExpandedProcessTaskDefDO(Integer id, String name, String jndiName)
    {
        this.id = id;
        this.name = name;
        this.jndiName = String.format(jndiName, DeploymentConfig.APP_VERSION);

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
    public String getJndiName()
    {
        return this.jndiName;
    }

}
