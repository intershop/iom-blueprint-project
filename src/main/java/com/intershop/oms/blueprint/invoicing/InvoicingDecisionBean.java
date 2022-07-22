package com.intershop.oms.blueprint.invoicing;

import java.util.Arrays;
import java.util.List;

import javax.ejb.Stateless;
import javax.ejb.TransactionAttribute;
import javax.ejb.TransactionAttributeType;

import com.intershop.oms.blueprint.BlueprintConstants;

import bakery.logic.service.util.AbstractExecutionDecider;
import bakery.logic.service.util.ExecutionDecider;
import bakery.persistence.dataobject.configuration.common.InvoicingTypeDefDO;
import bakery.persistence.dataobject.configuration.common.ReturnTypeDefDO;
import bakery.persistence.dataobject.configuration.invoicing.InvoicingEventRegistryEntryDO;
import bakery.persistence.dataobject.order.DispatchDO;
import bakery.persistence.dataobject.order.ReturnDO;

@Stateless
@TransactionAttribute(TransactionAttributeType.REQUIRED)
public class InvoicingDecisionBean extends AbstractExecutionDecider<InvoicingEventRegistryEntryDO>
                implements ExecutionDecider<InvoicingEventRegistryEntryDO>
{
    public static final List<ReturnTypeDefDO> RETURN_TYPES_WITH_INVOICE = Arrays.asList(ReturnTypeDefDO.RET,
                    ReturnTypeDefDO.INV, ReturnTypeDefDO.DEF);

    @Override
    public boolean isExecutionRequired(DispatchDO dispatchDO,
                    InvoicingEventRegistryEntryDO invoicingEventRegistryEntryDO)
    {
        if (InvoicingTypeDefDO.CREDITNOTE.equals(invoicingEventRegistryEntryDO.getInvoicingTypeDefDO()))
        {
            // for CREDITNOTE not expected
            return false;
        }

        // check for special dispatch property
        String createInvoiceProperty = dispatchDO.getPropertyValue(BlueprintConstants.PROPERTY_DISPATCH,
                        BlueprintConstants.PROPERTY_CREATE_INVOICE);
        if (Boolean.FALSE.toString().equals(createInvoiceProperty))
        {
            return false;
        }

        // invoice for every dispatch / for all payment methods
        return true;
    }

    @Override
    public boolean isExecutionRequired(ReturnDO returnDO, InvoicingEventRegistryEntryDO invoicingEventRegistryEntryDO)
    {
        if (InvoicingTypeDefDO.INVOICE.equals(invoicingEventRegistryEntryDO.getInvoicingTypeDefDO()))
        {
            // for INVOICE not expected
            return false;
        }

        return RETURN_TYPES_WITH_INVOICE.contains(returnDO.getReturnReasonDefDO().getReturnTypeDefDO());
    }

}
