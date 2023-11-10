package com.intershop.oms.blueprint.transmitter;

import jakarta.ejb.Stateless;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.blueprint.BlueprintConstants;

import bakery.logic.service.util.AbstractExecutionDecider;
import bakery.persistence.dataobject.configuration.connections.CommunicationPartnerDO;
import bakery.persistence.dataobject.configuration.states.ReturnAnnouncementStatesDefDO;
import bakery.persistence.dataobject.order.OrderDO;
import bakery.persistence.dataobject.rma.ReturnAnnouncementDO;
import bakery.persistence.dataobject.rma.ReturnAnnouncementPropertyDO;
import bakery.util.exception.TechnicalException;

/**
 * Transmission of a shop-related message should be executed or not.
 */
@Stateless
public class ShopTransmissionDecisionBean extends AbstractExecutionDecider<CommunicationPartnerDO>
{
    
    private Logger log = LoggerFactory.getLogger(ShopTransmissionDecisionBean.class);
    
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
     * RMA request/ ReturnAnnouncementDO should not be exported if:
     * - approval rejected
     * - OR custom return request property is given as group|key|value = ""|export|false.
     */
    @Override
    public boolean isExecutionRequired(ReturnAnnouncementDO returnAnnouncementDO, CommunicationPartnerDO communicationPartner)
    {
        if (null == returnAnnouncementDO)
        {
            throw new TechnicalException(ReturnAnnouncementDO.class, "ReturnAnnouncementDO is null");
        }

        // true if the return announcement is/was in status ACCEPTED
        boolean accepted = returnAnnouncementDO.getReturnAnnouncementStateHistoryList() != null
                        ? returnAnnouncementDO.getReturnAnnouncementStateHistoryList().stream().anyMatch(
                                        rma -> rma.getTargetState() == ReturnAnnouncementStatesDefDO.STATE_ACCEPTED)
                        : false;

        // not accepted yet or declined
        if(!accepted)
        {
            return false;
        }

        // check custom properties
        String value = returnAnnouncementDO.getPropertyValue(ReturnAnnouncementPropertyDO.DEFAULT_GROUP, BlueprintConstants.PROPERTY_EXPORT);
        if ((value != null) && value.equals(BlueprintConstants.PROPERTY_VALUE_FALSE))
        {
            log.debug(
                    "Skipping order export, because custom order property group|key|value = "
                            + String.format("%s|%s|%s",
                                    ReturnAnnouncementPropertyDO.DEFAULT_GROUP,
                                    BlueprintConstants.PROPERTY_EXPORT,
                                    BlueprintConstants.PROPERTY_VALUE_FALSE)
                            + " found.");
            return false;   // skip
        }
        
        return true;        // export
    }

}
