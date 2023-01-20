package com.intershop.oms.blueprint.approval;

import java.math.BigDecimal;

import jakarta.ejb.Stateless;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;

import bakery.logic.service.util.AbstractExecutionDecider;
import bakery.persistence.dataobject.configuration.supplier.Shop2Supplier2ApprovalTypeDefDO;
import bakery.persistence.dataobject.order.OrderDO;

/**
 * Approval is required for shop total gross of the order > 1000. 
 */
@Stateless
@TransactionAttribute(TransactionAttributeType.REQUIRED)
public class OrderValueApprovalDecisionBean extends AbstractExecutionDecider<Shop2Supplier2ApprovalTypeDefDO>
{
    private static final BigDecimal ORDER_VALUE_1000 = new BigDecimal("1000");
    
    @Override
    public boolean isExecutionRequired(OrderDO orderDO, Shop2Supplier2ApprovalTypeDefDO shop2Supplier2ApprovalTypeDefDO)
    {
        return orderDO.getShopTotalGross().compareTo(ORDER_VALUE_1000) == 1 ? true : false;        
    }

}
