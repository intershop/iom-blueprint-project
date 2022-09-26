package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.common.PaymentDefDO;
import bakery.persistence.expand.PaymentDefDOEnumInterface;

@ExpandedEnum(PaymentDefDO.class)
public enum ExpandedPaymentDefDO implements PaymentDefDOEnumInterface
{

    /**
     * Start with 10000 to avoid conflict with PaymentDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */

    TEST(-999, "AfterPay", "AfterPay", null, "AfterPay")
    ;

    private Integer id;
    private String name;
    private String description;
    private PaymentDefDOEnumInterface paymentGroup;
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
    public String getDescription()
    {
        return this.description;
    }

    @Override
    public PaymentDefDOEnumInterface getPaymentGroup()
    {
        return (this.paymentGroup != null ? this.paymentGroup : this);
    }

    @Override
    public String getPayment()
    {
        return this.payment;
    }

    /**
    * @return the id of the payment method group
    */
    @Override
    public Integer getPaymentGroupRef()
    {
	    return ( paymentGroup == null ? null : paymentGroup.getId() );
    }

    @Override
    public String getFieldName()
    {
	    return this.name();
    }

}
