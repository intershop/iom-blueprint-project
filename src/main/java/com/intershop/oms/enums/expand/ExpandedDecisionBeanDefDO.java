package com.intershop.oms.enums.expand;

import java.util.EnumSet;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.connections.DecisionBeanDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.DeploymentConfig;
import bakery.util.StringUtils;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Transient;

@ExpandedEnum(DecisionBeanDefDO.class)
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
    RMA_DECISION_BEAN(Integer.valueOf(30000), "java:global/iom-blueprint-project/RmaApprovalDecisionBean"),

    // export|transmissions 4xxxx
    SHOP_TRANSMISSION_DECISION_BEAN(Integer.valueOf(40000), "java:global/iom-blueprint-project/ShopTransmissionDecisionBean"),
    SUPPLIER_TRANSMISSION_DECISION_BEAN(Integer.valueOf(41000), "java:global/iom-blueprint-project/SupplierTransmissionDecisionBean"),

    // emails 5xxxx
    SEND_EMAIL_DECISION_BEAN(Integer.valueOf(50000), "java:global/iom-blueprint-project/SendEmailDecisionBean")
    ;

    private Integer id;
    private String jndiName;

    private ExpandedDecisionBeanDefDO( Integer id, String jndiName )
    {
        this.id = id;
        this.jndiName = String.format( jndiName, DeploymentConfig.APP_VERSION );
    }

    @Override
    @Id
    public Integer getId()
    {
        return id;
    }

    @Override
    @Column( name = "`description`" )
    public String getName()
    {
        return StringUtils.constantToHungarianNotation( name(), StringUtils.FLAG_FIRST_LOWER );
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return jndiName;
    }

    /**
     * get list of expanded enums
     * @return
     */
    @Transient
    public final EnumSet<ExpandedDecisionBeanDefDO> getExpandedEnums()
    {
        return EnumSet.allOf( ExpandedDecisionBeanDefDO.class );
    }

    /**
     * get list of all enums
     * @return
     */
    @Transient
    public final EnumSet<DecisionBeanDefDO> getAllEnums()
    {
        return EnumSet.allOf( DecisionBeanDefDO.class );
    }

}
