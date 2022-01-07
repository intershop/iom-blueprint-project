package com.intershop.oms.enums.expand;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Transient;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.configuration.common.OrderValidationRuleDefDO;
import bakery.persistence.expand.OrderValidationRuleDefDOEnumInterface;

@PersistedEnumerationTable(OrderValidationRuleDefDO.class)
public enum ExpandedOrderValidationRuleDefDO implements OrderValidationRuleDefDOEnumInterface
{

    /**
     * Minimum ID for custom entries: 1000 length restriction for name: 50
     */
    VALIDATE_PROPERTIES(-9999, "ValidateMandatoryPropertiesPTBean", "java:global/example-app/ValidateMandatoryPropertiesPTBean!bakery.logic.service.order.task.ValidateOrderPT", 999, false)
    ;
    
    private Integer id;
    private String name;
    private String jndiName;
    private int rank;
    private boolean mandatory;

    private ExpandedOrderValidationRuleDefDO(Integer id, String name, String jndiName, int rank, boolean mandatory)
    {
        this.id = id;
        this.name = name;
        this.jndiName = jndiName;
        this.rank = rank;
        this.mandatory = mandatory;
    }

    /**
     * Id der Pruefungsart
     */
    @Override
    @Id
    public Integer getId()
    {
        return this.id;
    }

    /**
     * Id der Pruefungsart
     */
    protected void setId(Integer id)
    {
        this.id = id;
    }

    /**
     * Namen der Pruefungsregel
     */
    @Override
    @Column(name = "`name`", length = 50, nullable = false)
    public String getName()
    {
        return this.name;
    }

    /**
     * Namen der Pruefungsregel
     */
    public void setName(String name)
    {
        this.name = name;
    }

    /**
     * Ranking (Reihenfolge) der Pruefung
     */
    @Override
    @Column(name = "`rank`", nullable = false)
    public int getRank()
    {
        return this.rank;
    }

    /**
     * Ranking (Reihenfolge) der Pruefung
     */
    public void setRank(int rank)
    {
        this.rank = rank;
    }

    /**
     * Gibt an ob dieser Parameter abgeschaltet werden darf.
     *
     * @return <b>true</b> oder <b>false</b>
     */
    @Override
    @Column(name = "`mandatory`", nullable = false)
    public boolean isMandatory()
    {
        return this.mandatory;
    }

    /**
     * Gibt an ob dieser Parameter abgeschaltet werden darf.
     *
     * @param mandatory
     *            <b>true</b> oder <b>false</b>
     */
    public void setMandatory(boolean mandatory)
    {
        this.mandatory = mandatory;
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return this.jndiName;
    }

}
