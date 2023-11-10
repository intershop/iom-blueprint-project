package com.intershop.oms.blueprint.approval;

import jakarta.ejb.Stateless;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;

import bakery.logic.service.util.AbstractExecutionDecider;
import bakery.persistence.dataobject.common.PaymentDefDO;
import bakery.persistence.dataobject.configuration.supplier.Shop2Supplier2ApprovalTypeDefDO;
import bakery.persistence.dataobject.order.OrderDO;

/**
 * Approval is required for orders with payment method cash on delivery.
 */
@Stateless
@TransactionAttribute(TransactionAttributeType.REQUIRED)
public class CashOnDeliveryApprovalDecisionBean extends AbstractExecutionDecider<Shop2Supplier2ApprovalTypeDefDO>
{    
    
    @Override
    public boolean isExecutionRequired(OrderDO orderDO, Shop2Supplier2ApprovalTypeDefDO shop2Supplier2ApprovalTypeDefDO)
    {
        return orderDO.getPaymentDefDO().equals(PaymentDefDO.CASH_ON_DELIVERY);
    }

}
