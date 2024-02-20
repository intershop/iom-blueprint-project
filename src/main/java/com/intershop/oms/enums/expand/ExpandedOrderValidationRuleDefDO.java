package com.intershop.oms.enums.expand;

import java.util.EnumSet;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.common.OrderValidationRuleDefDO;
import bakery.persistence.expand.OrderValidationRuleDefDOEnumInterface;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Transient;

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

    private ExpandedOrderValidationRuleDefDO(Integer id, String name, String jndiName, int rank, boolean mandatory, String description)
    {
        this.id = id;
        this.name = name;
        this.jndiName = jndiName;
        this.rank = rank;
        this.mandatory = mandatory;
        this.description = description;
    }

    @Override
    @Id
    public Integer getId()
    {
        return this.id;
    }

    protected void setId(Integer id)
    {
        this.id = id;
    }

    @Override
    @Column(name = "name", length = 50, nullable = false)
    public String getName()
    {
        return name;
    }

    protected void setName(String name)
    {
        this.name = name;
    }

    @Column(name = "description")
    public String getDescription()
    {
        return description;
    }

    protected void setDescription(String description)
    {
        // dummy setter for the needs of hibernate
    }

    /**
     * Priority the rule should be checked.
     */
    @Override
    @Column(name = "rank", nullable = false)
    public int getRank()
    {
        return rank;
    }

    /**
     * Priority the rule should be checked.
     *
     * @param rank
     */
    protected void setRank(int rank)
    {
        this.rank = rank;
    }

    /**
     * Whether the rule is mandatory and must not be disabled.
     */
    @Override
    @Column(name = "mandatory", nullable = false)
    public boolean isMandatory()
    {
        return mandatory;
    }

    /**
     * Whether the rule is mandatory and must not be disabled.
     *
     * @param mandatory
     *            <b>true</b> oder <b>false</b>
     */
    protected void setMandatory(boolean mandatory)
    {
        this.mandatory = mandatory;
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return String.format(jndiName, bakery.util.DeploymentConfig.APP_VERSION);
    }

    @Transient
    public final EnumSet<ExpandedOrderValidationRuleDefDO> getExpandedEnums()
    {
        return EnumSet.allOf(ExpandedOrderValidationRuleDefDO.class);
    }

    @Transient
    public final EnumSet<OrderValidationRuleDefDO> getAllEnums()
    {
        return EnumSet.allOf(OrderValidationRuleDefDO.class);
    }
}
