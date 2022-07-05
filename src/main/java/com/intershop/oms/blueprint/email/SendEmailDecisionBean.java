package com.intershop.oms.blueprint.email;

import javax.ejb.EJB;
import javax.ejb.Stateless;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.blueprint.BlueprintConstants;

import bakery.logic.service.util.AbstractExecutionDecider;
import bakery.logic.service.util.OrderHelper;
import bakery.persistence.dataobject.common.PropertyOwner;
import bakery.persistence.dataobject.configuration.connections.TransmissionTypeDefDO;
import bakery.persistence.dataobject.configuration.mail.MailEventRegistryEntryDO;
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
public class SendEmailDecisionBean extends AbstractExecutionDecider<MailEventRegistryEntryDO> // -> must be configured on MailEventRegistryEntryDO
{
    private static final Logger logger = LoggerFactory.getLogger(SendEmailDecisionBean.class);

    @EJB(lookup = OrderHelper.LOGIC_ORDERHELPERBEAN)
    private OrderHelper orderHelperLogicService;

    @Override
    public boolean isExecutionRequired(OrderDO orderDO, MailEventRegistryEntryDO eventRegistry)
    {   
        // valid email and not contains the custom property     
        return hasEmailAddress(orderDO) && (!hasCustomProperty(orderDO, BlueprintConstants.ORDER_PROPERTY_GROUP_ORDER, BlueprintConstants.PROPERTY_KEY_EMAIL, BlueprintConstants.PROPERTY_VALUE_FALSE));
    }

    @Override
    public boolean isExecutionRequired(ResponseDO responseDO, MailEventRegistryEntryDO eventRegistry)
    {
        // valid email and not contains the custom property     
        return hasEmailAddress(responseDO.getOrderDO()) && (!hasCustomProperty(responseDO, BlueprintConstants.RESPONSE_PROPERTY_GROUP_RESPONSE, BlueprintConstants.PROPERTY_KEY_EMAIL, BlueprintConstants.PROPERTY_VALUE_FALSE));
    }

    @Override
    public boolean isExecutionRequired(DispatchDO dispatchDO, MailEventRegistryEntryDO eventRegistry)
    {
        // invoice email on dispatch
//        if(TransmissionTypeDefDO.SEND_CUSTOMER_MAIL_INVOICE
//            .equals(eventRegistry.getTransmissionTypeDefDO()))
//        {
//            // valid email and not contains the custom property     
//            return hasEmailAddress(dispatchDO.getOrderDO()) && (!hasCustomProperty(dispatchDO, BlueprintConstants.DISPATCH_PROPERTY_GROUP_DISPATCH, BlueprintConstants.DISPATCH_PROPERTY_KEY_INVOICE_EMAIL, BlueprintConstants.PROPERTY_VALUE_FALSE));  
//        }

        // else
        // valid email and not contains the custom property     
        return hasEmailAddress(dispatchDO.getOrderDO()) && (!hasCustomProperty(dispatchDO, BlueprintConstants.DISPATCH_PROPERTY_GROUP_DISPATCH, BlueprintConstants.PROPERTY_KEY_EMAIL, BlueprintConstants.PROPERTY_VALUE_FALSE));
    }

    @Override
    public boolean isExecutionRequired(ReturnAnnouncementDO returnAnnouncementDO, MailEventRegistryEntryDO eventRegistry)
    {
        // valid email and not contains the custom property     
        return hasEmailAddress(returnAnnouncementDO.getOrder()) && (!hasCustomProperty(returnAnnouncementDO, BlueprintConstants.RMA_PROPERTY_GROUP_RMA, BlueprintConstants.PROPERTY_KEY_EMAIL, BlueprintConstants.PROPERTY_VALUE_FALSE));
    }

    @Override
    public boolean isExecutionRequired(ReturnDO returnDO, MailEventRegistryEntryDO eventRegistry)
    {
        // valid email and not contains the custom property     
        return hasEmailAddress(returnDO.getOrderDO()) && (!hasCustomProperty(returnDO, BlueprintConstants.RETURN_PROPERTY_GROUP_RETURN, BlueprintConstants.PROPERTY_KEY_EMAIL, BlueprintConstants.PROPERTY_VALUE_FALSE));
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
     * @param orderDO the OrderDO to check
     * @return returns true if order has a receiver email address, otherwise false
     */
    private boolean hasEmailAddress(OrderDO orderDO)
    {
        String receiverEmailAddress = this.orderHelperLogicService.getReceiverEmailAddress4OrderOrCustomer(orderDO);
        
        if (!StringUtils.isEmpty(receiverEmailAddress))
        {
            return true;
        }

        logger.debug("For customer: '{}' with order: '{}' no eMail address exists. Couldn't send email.",
                        orderDO.getShopCustomerNo(), orderDO.getId());

        return false;
    }
}