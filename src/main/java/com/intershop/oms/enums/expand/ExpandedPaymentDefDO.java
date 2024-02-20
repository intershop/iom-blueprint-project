package com.intershop.oms.enums.expand;

import java.util.EnumSet;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.common.PaymentDefDO;
import bakery.persistence.expand.PaymentDefDOEnumInterface;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Transient;

@ExpandedEnum(PaymentDefDO.class)
public enum ExpandedPaymentDefDO implements PaymentDefDOEnumInterface
{

    /**
     * Start with 10000 to avoid conflict with PaymentDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */

    TEST(-9999, "AfterPay", "AfterPay", null, "AfterPay")
    ;

    private Integer id;
    private String name;
    private String description;
    private PaymentDefDOEnumInterface paymentGroup;
    private Integer paymentGroupRef;
    private String payment;

    private ExpandedPaymentDefDO(Integer id, String name, String description, PaymentDefDO paymentGroup, String payment)
    {
        this.payment = payment;
        this.id = id;
        this.name = name;
        this.description = description;
        this.paymentGroup = paymentGroup;
    }

    @Override
    @Id
    @Column(name = "id")
    public Integer getId()
    {
        return this.id;
    }

    @Override
    @Column(name = "name", length = 30, nullable = false)
    public String getName()
    {
        return this.name;
    }

    @Override
    @Column(name = "description")
    public String getDescription()
    {
        return this.description;
    }

    @Override
    @Transient
    public PaymentDefDOEnumInterface getPaymentGroup()
    {
        return (this.paymentGroup != null ? this.paymentGroup : this);
    }

    /**
     * Sets the payment method group of a payment method.
     *
     * @param paymentGroup
     *      the payment group of a payment method to set
     */
    public void setPaymentGroup(PaymentDefDO paymentGroup)
    {
        if (paymentGroup != null)
        {
            this.paymentGroupRef = paymentGroup.getId();
            this.paymentGroup = PaymentDefDO.getPaymentDefDO(this.paymentGroupRef);
        }
        else
        {
            this.paymentGroupRef = null;
            this.paymentGroup = null;
        }
    }

    @Override
    @Column(name = "payment", length = 100, nullable = false)
    public String getPayment()
    {
        return this.payment;
    }

    /**
     * @return the id of the payment method group
     */
    @Override
    @Column( name = "`paymentGroupRef`" )
    public Integer getPaymentGroupRef()
    {
        return this.paymentGroupRef;
    }

    @Override
    @Column(name = "`paymentName`", length = 100, nullable = false)
    public String getFieldName()
    {
        return this.name();
    }

    /**
     * get list of expanded enums
     *
     * @return
     */
    @Transient
    public final EnumSet<ExpandedPaymentDefDO> getExpandedEnums()
    {
        return EnumSet.allOf(ExpandedPaymentDefDO.class);
    }

}
