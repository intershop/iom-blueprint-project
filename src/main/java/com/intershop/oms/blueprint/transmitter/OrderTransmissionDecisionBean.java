package com.intershop.oms.blueprint.transmitter;

import javax.ejb.Stateless;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import bakery.logic.service.util.AbstractExecutionDecider;
import bakery.logic.service.util.ExecutionDecider;
import bakery.persistence.dataobject.configuration.connections.CommunicationPartnerDO;
import bakery.persistence.dataobject.order.OrderDO;
import bakery.util.exception.TechnicalException;

/**
 * Order should not be exported if custom order level property is given as group|key|value = order|export|false
 */
@Stateless
public class OrderTransmissionDecisionBean extends AbstractExecutionDecider<CommunicationPartnerDO> implements ExecutionDecider<CommunicationPartnerDO>
{
    
    private static final String GROUP   = "order";
    private static final String KEY     = "export";
    private static final String VALUE   = "false";
    
    private Logger log = LoggerFactory.getLogger(OrderTransmissionDecisionBean.class);
    
    @Override
    public boolean isExecutionRequired(OrderDO orderDO, CommunicationPartnerDO communicationPartner)
    {
        if (null == orderDO)
        {
            throw new TechnicalException(OrderDO.class, "OrderDO is null");
        }

        String value = orderDO.getPropertyValue(GROUP, KEY);
        if ((value != null) && value.equals(VALUE))
        {
            log.debug("Skipping order export, because custom order property group|key|value = " + String.format("%s|%s|%s", GROUP, KEY, VALUE) + " found.");
            return false;
        }
        
        return true;
      
    }

}
