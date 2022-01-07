package com.intershop.oms.enums.expand;

import java.util.EnumSet;

import bakery.persistence.dataobject.configuration.process.ProcessTaskDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.DeploymentConfig;

public enum ExpandedProcessTaskDefDO implements EnumInterface
{
    /**
     * PLEASE START AFTER EXAMPLE WITH ID 1000 and go up THATS IMPORTANT !!!
     */
    EXAMPLE_PT(-999, "CheckSendDebitorPT", "java:global/example-app/SkipSendDebitorPTBean")
    ;

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

    /**
     * get list of expanded enums
     *
     * @return
     */
    public final EnumSet<ExpandedProcessTaskDefDO> getExpandedEnums()
    {
        return EnumSet.allOf(ExpandedProcessTaskDefDO.class);
    }

    /**
     * get list of all enums
     *
     * @return
     */
    public final EnumSet<ProcessTaskDefDO> getAllEnums()
    {
        return EnumSet.allOf(ProcessTaskDefDO.class);
    }
}
