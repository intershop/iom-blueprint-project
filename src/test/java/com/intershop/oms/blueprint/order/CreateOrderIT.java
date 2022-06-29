package com.intershop.oms.blueprint.order;

import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.junit.jupiter.api.Test;

import com.intershop.oms.test.businessobject.OMSSupplier;
import com.intershop.oms.test.businessobject.communication.OMSDispatch;
import com.intershop.oms.test.businessobject.communication.OMSReturn;
import com.intershop.oms.test.businessobject.communication.OMSReturnPosition;
import com.intershop.oms.test.businessobject.order.OMSOrder;
import com.intershop.oms.test.servicehandler.ServiceHandlerFactory;
import com.intershop.oms.test.servicehandler.omsdb.OMSDbHandler;
import com.intershop.oms.test.servicehandler.orderservice.OMSOrderServiceHandler;
import com.intershop.oms.test.servicehandler.supplierservice.OMSSupplierServiceHandler;
import com.intershop.oms.test.util.SupplierServiceUtil;

import bakery.persistence.dataobject.configuration.common.ReturnReasonDefDO;
import bakery.persistence.dataobject.configuration.states.DispatchStatesDefDO;
import bakery.persistence.dataobject.configuration.states.OrderStatesDefDO;
import bakery.persistence.dataobject.configuration.states.ReturnStatesDefDO;

public class CreateOrderIT
{
    @Test
    void testOrderHappyPath() throws Exception
    {
        // create an order
        OMSOrderServiceHandler orderServiceHandler = ServiceHandlerFactory.getOrderServiceHandler("default");
        OMSOrder testOrder = B2BTestOrder.createSimpleOrder("7257201");
        testOrder = orderServiceHandler.createOrder(testOrder, OrderStatesDefDO.STATE_COMMISSIONED.getId());

        // dispatch full order
        List<OMSDispatch> dispatches = SupplierServiceUtil.prepareFullDispatch(testOrder, true);
        OMSSupplierServiceHandler supplierServiceHandler = ServiceHandlerFactory.getSupplierServiceHandler("default");
        supplierServiceHandler.createDispatches(dispatches, DispatchStatesDefDO.STATE_CLOSED.getId());

        OMSDbHandler dbHandler = ServiceHandlerFactory.getDbHandler();
        Map<OMSSupplier, Collection<OMSReturnPosition>> returnPositionsForOrder = dbHandler
                        .getReturnPositionsForOrder(testOrder, false);

        // prepare returns - one per position
        for (Entry<OMSSupplier, Collection<OMSReturnPosition>> entry : returnPositionsForOrder.entrySet())
        {
            for (OMSReturnPosition omsReturnPosition : entry.getValue())
            {
                OMSReturn omsReturn = SupplierServiceUtil.prepareReturn(testOrder.getShop(), entry.getKey(),
                                testOrder.getShopOrderNumber(), Arrays.asList(omsReturnPosition), null);
                omsReturn.setReason(ReturnReasonDefDO.RET010.name());
                supplierServiceHandler.createReturn(omsReturn, ReturnStatesDefDO.STATE_CLOSED.getId());
            }

        }

    }

}
