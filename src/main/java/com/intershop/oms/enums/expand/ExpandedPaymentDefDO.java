package com.intershop.oms.enums.expand;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Transient;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.common.PaymentDefDO;
import bakery.persistence.expand.PaymentDefDOEnumInterface;

@PersistedEnumerationTable(PaymentDefDO.class)
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
    @Column(name = "`id`")
    public Integer getId()
    {
        return this.id;
    }

    @Override
    @Column(name = "`name`", length = 30, nullable = false)
    public String getName()
    {
        return this.name;
    }

    @Override
    @Column(name = "`description`", length = 50, nullable = false)
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

    @Override
    @Transient
    public String getPayment()
    {
        return this.payment;
    }

    @Override
    @Column(name = "`paymentGroupRef`")
    public Integer getPaymentGroupRef()
    {
        return this.paymentGroupRef;
    }

    @Override
    @Transient
    public String getFieldName()
    {
        return this.name();
    }

}
