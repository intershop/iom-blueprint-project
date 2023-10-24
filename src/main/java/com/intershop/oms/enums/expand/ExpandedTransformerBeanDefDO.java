package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.persistence.dataobject.transformer.TransformerBeanDefDO;
import bakery.util.StringUtils;

@ExpandedEnum(TransformerBeanDefDO.class)
public enum ExpandedTransformerBeanDefDO implements EnumInterface
{

    /**
     * Start with 1000 to avoid conflict with TransformerBeanDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */

    ICM_TO_IOM_TRANSFORMER(10000, "java:global/iom-blueprint-project/ICMToIOMTransformer!bakery.logic.job.transformation.Transformer"),
    OPENTRANS_DISPATCH_TRANSFORMER(10200, "java:global/iom-blueprint-project/OpenTransDispatchTransformer!bakery.logic.job.transformation.Transformer");

    private Integer id;
    private String jndiName;

    private ExpandedTransformerBeanDefDO(Integer id, String jndiName)
    {
        this.id = id;
        this.jndiName = jndiName;
    }

    @Override
    public Integer getId()
    {
        return this.id;
    }

    @Override
    public String getName()
    {
        return StringUtils.constantToHungarianNotation(this.name(), false);
    }

    @Override
    public String getJndiName()
    {
        return this.jndiName;
    }

}
