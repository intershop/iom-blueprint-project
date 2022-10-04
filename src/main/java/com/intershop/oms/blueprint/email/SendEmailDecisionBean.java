package com.intershop.oms.blueprint.email;

import java.util.EnumSet;
import java.util.List;

import javax.ejb.EJB;
import javax.ejb.Stateless;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.blueprint.BlueprintConstants;

import bakery.logic.service.util.AbstractExecutionDecider;
import bakery.logic.service.util.OrderHelper;
import bakery.persistence.dataobject.common.PropertyOwner;
import bakery.persistence.dataobject.configuration.common.InvoicingTypeDefDO;
import bakery.persistence.dataobject.configuration.common.ResponseTypeDefDO;
import bakery.persistence.dataobject.configuration.common.ReturnReasonDefDO;
import bakery.persistence.dataobject.configuration.common.ReturnTypeDefDO;
import bakery.persistence.dataobject.configuration.connections.TransmissionTypeDefDO;
import bakery.persistence.dataobject.configuration.mail.MailEventRegistryEntryDO;
import bakery.persistence.dataobject.configuration.states.InvoicingTransmissionStatesDefDO;
import bakery.persistence.dataobject.invoicing.InvoicingDO;
import bakery.persistence.dataobject.invoicing.InvoicingTransmissionDO;
import bakery.persistence.dataobject.order.DispatchDO;
import bakery.persistence.dataobject.order.OrderDO;
import bakery.persistence.dataobject.order.ResponseDO;
import bakery.persistence.dataobject.order.ReturnDO;
import bakery.persistence.dataobject.rma.ReturnAnnouncementDO;

/**
 * Checks if an email should be send to the customer.
 * Fails/skips if custom level property is given as group|key|value = ...|email|fail or no receiver email is given.
 */
@Stateless
public class SendEmailDecisionBean extends AbstractExecutionDecider<MailEventRegistryEntryDO>
{
    private static final Logger logger = LoggerFactory.getLogger(SendEmailDecisionBean.class);

    @EJB(lookup = OrderHelper.LOGIC_ORDERHELPERBEAN)
    private OrderHelper orderHelperLogicService;

    @Override
    public boolean isExecutionRequired(OrderDO orderDO, MailEventRegistryEntryDO eventRegistry)
    {
        // has email and not contains the custom property
        return hasEmailAddress(orderDO) && (!hasCustomProperty(orderDO, BlueprintConstants.PROPERTY_ORDER,
                        BlueprintConstants.PROPERTY_EMAIL, BlueprintConstants.PROPERTY_VALUE_FALSE));
    }
    
    @Override
    public boolean isExecutionRequired(ResponseDO responseDO, MailEventRegistryEntryDO eventRegistry)
    {
        // has email
        if (!hasEmailAddress(responseDO.getOrderDO()))
        {
            return false;
        }

        // determine type of mail by type of response
        ResponseTypeDefDO responseType = responseDO.getResponseTypeDefDO();
        switch (responseType)
        {
            case TEMPORARY:
                return eventRegistry
                        .getTransmissionTypeDefDO() == TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RESPONSE_TEMPORARY;
            case INITIAL:
                return eventRegistry
                        .getTransmissionTypeDefDO() == TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RESPONSE_INITIAL;
            case CONTINUOUS:
                return eventRegistry
                        .getTransmissionTypeDefDO() == TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RESPONSE_CONTINUOUS;
            case INTERNAL:
            default:
                logger.error("Transmission type of response type " + responseType.name() + " is not supported.");
                return false;
        }
    }

    /**
     * Does not differ
     *      TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_DISPATCH
     *      and
     *      TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_DISPATCH_IMMATERIAL yet.
     */
    @Override
    public boolean isExecutionRequired(DispatchDO dispatchDO, MailEventRegistryEntryDO eventRegistry)
    {
        // has email and not contains the custom property
        return hasEmailAddress(dispatchDO.getOrderDO()) && (!hasCustomProperty(dispatchDO,
                        BlueprintConstants.PROPERTY_DISPATCH, BlueprintConstants.PROPERTY_EMAIL,
                        BlueprintConstants.PROPERTY_VALUE_FALSE));
    }

    @Override
    public boolean isExecutionRequired(ReturnAnnouncementDO returnAnnouncementDO, MailEventRegistryEntryDO eventRegistry)
    {
        // has email and not contains the custom property
        return hasEmailAddress(returnAnnouncementDO.getOrder()) && (!hasCustomProperty(returnAnnouncementDO,
                        BlueprintConstants.PROPERTY_RMA, BlueprintConstants.PROPERTY_EMAIL,
                        BlueprintConstants.PROPERTY_VALUE_FALSE));
    }

    @Override
    public boolean isExecutionRequired(ReturnDO returnDO, MailEventRegistryEntryDO eventRegistry)
    {
        // skip if has no email
        if(!hasEmailAddress(returnDO.getOrderDO()))
        {
            return false;
        }
        
        // skip if contains special custom property
        if(hasCustomProperty(returnDO,
                BlueprintConstants.PROPERTY_RETURN, BlueprintConstants.PROPERTY_EMAIL,
                BlueprintConstants.PROPERTY_VALUE_FALSE))
        {
            return false;
        }
        
        // determine type of mail
        TransmissionTypeDefDO transmissionTypeDefDO = null;
        TransmissionTypeDefDO transmissionTypeCreditNoteDefDO = null;
        ReturnReasonDefDO returnReasonDefDO = returnDO.getReturnReasonDefDO();

        // determine transmission type by return reason - consider credit notes
        switch(returnReasonDefDO)
        {
            case RCL010:
                transmissionTypeDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL010;
                transmissionTypeCreditNoteDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL010_CREDITNOTE;
                break;
            case RCL020:
            case RCL041:
                transmissionTypeDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL020;
                transmissionTypeCreditNoteDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL020_CREDITNOTE;
                break;
            case RCL045:
                transmissionTypeDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL045;
                transmissionTypeCreditNoteDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL045_CREDITNOTE;
                break;
            case RCL980:
                transmissionTypeDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL980;
                transmissionTypeCreditNoteDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL980_CREDITNOTE;
                break;
            case RCL021:
                transmissionTypeDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL021;
                transmissionTypeCreditNoteDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL021_CREDITNOTE;
                break;
            case RET200:
                transmissionTypeDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_REJECTED;
                break;
            default:
                logger.info("Failed to determine transmission type for return reason " + returnReasonDefDO.name()
                        + ". Try to find using return type.");
            }

        // determine transmission type by return type - consider credit notes
        if((transmissionTypeDefDO == null) || (transmissionTypeDefDO != eventRegistry.getTransmissionTypeDefDO()))
        {
            ReturnTypeDefDO returnTypeDefDO = returnReasonDefDO.getReturnTypeDefDO();

            switch (returnTypeDefDO)
            {
                case CAN:
                    transmissionTypeDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_CAN;
                    transmissionTypeCreditNoteDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_CAN_CREDITNOTE;
                    break;
                case DEF:
                    transmissionTypeDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_DEF;
                    transmissionTypeCreditNoteDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_DEF_CREDITNOTE;
                    break;
                case INV:
                    transmissionTypeDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_INV;
                    transmissionTypeCreditNoteDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_INV_CREDITNOTE;
                    break;
                case RCL:
                    transmissionTypeDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL;
                    transmissionTypeCreditNoteDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL_CREDITNOTE;
                    break;
                case RET:
                    transmissionTypeDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RET;
                    transmissionTypeCreditNoteDefDO = TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RET_CREDITNOTE;
                    break;
                default:
                    logger.error("No transmission type configured for return type "
                            + (returnTypeDefDO != null ? returnTypeDefDO.name() : "null"));
                          
            }
        }

        return transmissionTypeDefDO == eventRegistry.getTransmissionTypeDefDO()
                || transmissionTypeCreditNoteDefDO == eventRegistry.getTransmissionTypeDefDO();
    }

    @Override
    public boolean isExecutionRequired(InvoicingDO invoicingDO, MailEventRegistryEntryDO eventRegistry)
    {
        // has email ?
        if (StringUtils.isEmpty(invoicingDO.getEmailAddress()))
        {
            logger.debug("For customer number '{}' with invoice number '{}' no e-mail address exists. Could not send e-mail.",
                            invoicingDO.getShopCustomerNo(), invoicingDO.getInvoiceNo());
            return false;
        }

        // consider type of invoice vs. credit note
        InvoicingTypeDefDO invoicingTypeDefDO = invoicingDO.getInvoicingTypeDefDO();
        EnumSet<TransmissionTypeDefDO> transmissionTypes = null;

		switch (invoicingTypeDefDO)
        {
            case INVOICE:
                transmissionTypes = EnumSet.of(TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_INVOICE,
                        TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_DISPATCH_INVOICE);
                break;
            case CREDITNOTE:
                // the "manual" credit note is not a return mail
                if(invoicingDO.getReferenceId() != null)
                {
                    transmissionTypes = EnumSet.of(TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_CREDITNOTE);
                }
                else
                {
                    transmissionTypes = EnumSet.of(
                            TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_CREDITNOTE,
                            TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_CREDITNOTE,
                            TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_CAN_CREDITNOTE,
                            TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_DEF_CREDITNOTE,
                            TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_INV_CREDITNOTE,
                            TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL010_CREDITNOTE,
                            TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL020_CREDITNOTE,
                            TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL021_CREDITNOTE,
                            TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL045_CREDITNOTE,
                            TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL980_CREDITNOTE,
                            TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RCL_CREDITNOTE,
                            TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_RETURN_RET_CREDITNOTE);
                }
                break;
            default:
                logger.error("Invoicing type " + invoicingTypeDefDO.name() + " is not implemented yet.");
        }

        // transmission type is configured ?
        if (!transmissionTypes.contains(eventRegistry.getTransmissionTypeDefDO()))
        {
            logger.debug("Transmission type '{}' is not configured for e-mails. Could not send e-mail.",
                            eventRegistry.getTransmissionTypeDefDO());
            return false;
        }

        return true;
    }

    @Override
    public boolean isExecutionRequired(InvoicingTransmissionDO invoicingTransmissionDO, MailEventRegistryEntryDO eventRegistry)
    {
        // has email ?
        if (!this.hasEmailAddress(invoicingTransmissionDO.getInvoicingDO().getOrderList()))
        {
            return false;
        }

        /**
        * only execute if 1) type CREATE_DOCUMENT 2) and in status TRANSMISSIONED 3) and hosted invoiceDO should be executed
        */
        return ((invoicingTransmissionDO.getTransmissionTypeDefDO() == TransmissionTypeDefDO.CREATE_DOCUMENT)
                        && (invoicingTransmissionDO.getState() == InvoicingTransmissionStatesDefDO.STATE_TRANSMISSIONED)
                        && (this.isExecutionRequired(invoicingTransmissionDO.getInvoicingDO(), eventRegistry)));
    }

    /**
     * Whether the object contains the given custom properties or not.
     * @param owner
     * @param group
     * @param key
     * @param value
     * @return
     */
    private boolean hasCustomProperty(PropertyOwner owner, String group, String key, String value)
    {
        String currentValue = owner.getPropertyValue(group, key);
        return ( (currentValue != null) && currentValue.equals(value) );
    }

    /**
     * Whether the customer has an email address or not.
     *
     * @param orderDO the order to check
     * @return
     */
    private boolean hasEmailAddress(OrderDO orderDO)
    {
        String receiverEmailAddress = orderHelperLogicService.getReceiverEmailAddress4OrderOrCustomer(orderDO);

        if (!StringUtils.isEmpty(receiverEmailAddress))
        {
            return true;
        }

        logger.debug("For customer number '{}' with order number '{}' no email address exists. Couldn't send email.",
                        orderDO.getShopCustomerNo(), orderDO.getId());

        return false;
    }

    /**
     * Whether the customer has an email address or not.
     * 
     * @param orderDOs, a list of orders
     * @return
     */
    private boolean hasEmailAddress(List<OrderDO> orderDOs)
    {
        for (OrderDO orderDO : orderDOs)
        {
            if (hasEmailAddress(orderDO))
            {
                return true;
            }
        }
        return false;
    }
    
}