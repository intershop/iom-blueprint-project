package com.intershop.oms.enums.expand;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Transient;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.configuration.connections.DecisionBeanDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.StringUtils;

@PersistedEnumerationTable(DecisionBeanDefDO.class)
public enum ExpandedDecisionBeanDefDO implements EnumInterface
{

    /**
     * Start with 10000 to avoid conflict with DecisionBeanDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */

    // general 1xxxx
    GENERAL_DECISION_BEAN(Integer.valueOf(-10000), "java:global/iom-blueprint-project/TBD"),
    INVOICING_DECISION_BEAN(Integer.valueOf(10001), "java:global/iom-blueprint-project/InvoicingDecisionBean"),

    // order approval 2xxxx
    COD_PAYMENT_DECISION_BEAN(Integer.valueOf(20000), "java:global/iom-blueprint-project/CashOnDeliveryApprovalDecisionBean"),
    MAX_ORDER_VALUE_DECISION_BEAN(Integer.valueOf(20001), "java:global/iom-blueprint-project/OrderValueApprovalDecisionBean"),

    // rma approval 3xxxx
    RMA_DECISION_BEAN(Integer.valueOf(-30000), "java:global/iom-blueprint-project/TBD"),

    // export|transmissions 4xxxx
    ORDER_TRANSMISSION_DECISION_BEAN(Integer.valueOf(40000), "java:global/iom-blueprint-project/OrderTransmissionDecisionBean"),
    SUPPLIER_TRANSMISSION_DECISION_BEAN(Integer.valueOf(41000), "java:global/iom-blueprint-project/SupplierTransmissionDecisionBean")
    ;

    private Integer id;
    private String jndiName;

    private ExpandedDecisionBeanDefDO(Integer id, String jndiName)
    {
        this.id = id;
        this.jndiName = jndiName;
    }

    @Override
    @Id
    public Integer getId()
    {
        return this.id;
    }

    @Override
    @Column(name = "`description`")
    public String getName()
    {
        return StringUtils.constantToHungarianNotation(this.name(), StringUtils.FLAG_FIRST_LOWER);
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return this.jndiName;
    }

}
