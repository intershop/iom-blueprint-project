package com.intershop.oms.blueprint.transmitter;

import javax.ejb.Stateless;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.blueprint.BlueprintConstants;

import bakery.logic.service.util.AbstractExecutionDecider;
import bakery.logic.service.util.ExecutionDecider;
import bakery.persistence.dataobject.configuration.connections.CommunicationPartnerDO;
import bakery.persistence.dataobject.order.OrderDO;
import bakery.persistence.dataobject.rma.ReturnAnnouncementDO;
import bakery.util.exception.TechnicalException;

/**
 * Transmission of a shop-related message should be executed or not.
 */
@Stateless
public class OrderTransmissionDecisionBean extends AbstractExecutionDecider<CommunicationPartnerDO> implements ExecutionDecider<CommunicationPartnerDO>
{
    
    private Logger log = LoggerFactory.getLogger(OrderTransmissionDecisionBean.class);
    
    /**
     * Order should not be exported if custom order level property is given as group|key|value = order|export|false.
     */
    @Override
    public boolean isExecutionRequired(OrderDO orderDO, CommunicationPartnerDO communicationPartner)
    {
        if (null == orderDO)
        {
            throw new TechnicalException(OrderDO.class, "OrderDO is null");
        }

        String value = orderDO.getPropertyValue(BlueprintConstants.PROPERTY_ORDER, BlueprintConstants.PROPERTY_EXPORT);
        if ((value != null) && value.equals(BlueprintConstants.PROPERTY_VALUE_FALSE))
        {
            log.debug("Skipping order export, because custom order property group|key|value = "
                            + String.format("%s|%s|%s", BlueprintConstants.PROPERTY_ORDER,
                                    BlueprintConstants.PROPERTY_EXPORT, BlueprintConstants.PROPERTY_VALUE_FALSE)
                            + " found.");
            return false;
        }
        
        return true;
    }

    /**
     * RMA request/ ReturnAnnouncementDO should not be exported if custom return request property is given as group|key|value = rma|export|false.
     */
    @Override
    public boolean isExecutionRequired(ReturnAnnouncementDO returnAnnouncementDO, CommunicationPartnerDO communicationPartner)
    {
        if (null == returnAnnouncementDO)
        {
            throw new TechnicalException(ReturnAnnouncementDO.class, "ReturnAnnouncementDO is null");
        }

        // returnAnnouncementPropertyList
        String value = returnAnnouncementDO.getPropertyValue("", BlueprintConstants.PROPERTY_EXPORT);
        if ((value != null) && value.equals(BlueprintConstants.PROPERTY_VALUE_FALSE))
        {
            log.debug(
                    "Skipping order export, because custom order property group|key|value = "
                            + String.format("%s|%s|%s", "",
                                    BlueprintConstants.PROPERTY_EXPORT, BlueprintConstants.PROPERTY_VALUE_FALSE)
                            + " found.");
            return false;
        }
        
        return true;
    }

}
