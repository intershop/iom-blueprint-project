package com.intershop.oms.enums.expand;

import java.util.EnumSet;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.persistence.dataobject.transformer.TransformerBeanDefDO;
import bakery.util.DeploymentConfig;
import bakery.util.StringUtils;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Transient;

@ExpandedEnum(TransformerBeanDefDO.class)
public enum ExpandedTransformerBeanDefDO implements EnumInterface
{

    /**
     * Start with 10000 to avoid conflict with TransformerBeanDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't
     * get persisted within the database).
     */
     
    BLUEPRINT_ICM_TRANSFORMER(Integer.valueOf(10000), "java:global/iom-blueprint-project/BlueprintIcmTransformer"),
    OPENTRANS_DISPATCH_TRANSFORMER(Integer.valueOf(10200),
            "java:global/iom-blueprint-project/OpenTransDispatchTransformer!bakery.logic.job.transformation.Transformer");

    private Integer id;
    private String jndiName;

    private ExpandedTransformerBeanDefDO(Integer id, String jndiName)
    {
        this.id = id;
        this.jndiName = String.format(jndiName, DeploymentConfig.APP_VERSION);
    }

    @Override
    @Id
    public Integer getId()
    {
        return id;
    }

    @Override
    @Column(name = "name")
    public String getName()
    {
        return StringUtils.constantToHungarianNotation(name(), false);
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return jndiName;
    }

    /**
     * get list of expanded enums
     * 
     * @return
     */
    @Transient
    public final EnumSet<ExpandedTransformerBeanDefDO> getExpandedEnums()
    {
        return EnumSet.allOf(ExpandedTransformerBeanDefDO.class);
    }

    /**
     * get list of all enums
     * 
     * @return
     */
    @Transient
    public final EnumSet<TransformerBeanDefDO> getAllEnums()
    {
        return EnumSet.allOf(TransformerBeanDefDO.class);
    }
}
