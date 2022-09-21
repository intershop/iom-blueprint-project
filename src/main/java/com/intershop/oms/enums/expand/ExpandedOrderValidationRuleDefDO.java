package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.common.OrderValidationRuleDefDO;
import bakery.persistence.expand.OrderValidationRuleDefDOEnumInterface;

@ExpandedEnum(OrderValidationRuleDefDO.class)
public enum ExpandedOrderValidationRuleDefDO implements OrderValidationRuleDefDOEnumInterface
{

    /**
     * Start with 10000 to avoid conflict with OrderValidationRuleDefDO. The
     * name must be unique across both classes. Values with negative id are
     * meant as syntax example and are ignored (won't get persisted within the
     * database).
     */

    CUSTOM_PROPERTY_VALIDATION(Integer.valueOf(
                    10000), "ValidateCustomOrderPropertiesPTBean", "java:global/iom-blueprint-project/ValidateCustomOrderPropertiesPTBean!bakery.logic.service.order.task.ValidateOrderPT", 1000, false, "Validation fails if custom order level property group|key|value = order|validation|fail-syncrounously is given.");

    private Integer id;
    private String name;
    private String jndiName;
    private int rank;
    private boolean mandatory;
    private String description;

    private ExpandedOrderValidationRuleDefDO(Integer id, String name, String jndiName, int rank, boolean mandatory,
                    String description)
    {
        this.id = id;
        this.name = name;
        this.jndiName = jndiName;
        this.rank = rank;
        this.mandatory = mandatory;
        this.description = description;
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

    /**
     * Sorted priority the rule should be check in.
     */
    @Override
    public int getRank()
    {
        return this.rank;
    }

    /**
     * Whether the rule is mandatory and must not be disabled.
     */
    @Override
    public boolean isMandatory()
    {
        return this.mandatory;
    }

    @Override
    public String getJndiName()
    {
        return String.format(this.jndiName, bakery.util.DeploymentConfig.APP_VERSION);
    }
}
