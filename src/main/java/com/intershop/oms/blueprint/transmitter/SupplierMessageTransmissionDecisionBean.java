package com.intershop.oms.blueprint.transmitter;

import javax.ejb.Stateless;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import bakery.logic.service.util.AbstractExecutionDecider;
import bakery.logic.service.util.ExecutionDecider;
import bakery.persistence.dataobject.configuration.connections.CommunicationPartnerDO;
import bakery.persistence.dataobject.order.DispatchDO;
import bakery.persistence.dataobject.order.ResponseDO;
import bakery.persistence.dataobject.order.ReturnDO;
import bakery.util.exception.TechnicalException;

/**
 * Message (response, dispatch, return) should not be exported if custom root level property is given as group|key|value = <response|dispatch|return>|export|false
 */
@Stateless
public class SupplierMessageTransmissionDecisionBean extends AbstractExecutionDecider<CommunicationPartnerDO> implements ExecutionDecider<CommunicationPartnerDO>
{
    
    private static final String GROUP_RES   = "response";
    private static final String GROUP_DIS   = "dispatch";
    private static final String GROUP_RET   = "return";
    private static final String KEY         = "export";
    private static final String VALUE       = "false";
    
    private Logger log = LoggerFactory.getLogger(SupplierMessageTransmissionDecisionBean.class);
    
    @Override
    public boolean isExecutionRequired(ResponseDO responseDO, CommunicationPartnerDO communicationPartner)
    {
       
        if (null == responseDO)
        {
            throw new TechnicalException(ResponseDO.class, "ResponseDO is null");
        }

        String value = responseDO.getPropertyValue(GROUP_RES, KEY);
        if ((value != null) && value.equals(VALUE))
        {
            log.debug("Skipping response export, because custom property group|key|value = " + String.format("%s|%s|%s", GROUP_RES, KEY, VALUE) + " found.");
            return false;
        }
        
        return true;
      
    }
    
    @Override
    public boolean isExecutionRequired(DispatchDO dispatchDO, CommunicationPartnerDO communicationPartner)
    {
        
        if (null == dispatchDO)
        {
            throw new TechnicalException(DispatchDO.class, "DispatchDO is null");
        }

        String value = dispatchDO.getPropertyValue(GROUP_DIS, KEY);
        if ((value != null) && value.equals(VALUE))
        {
            log.debug("Skipping dispatch export, because custom property group|key|value = " + String.format("%s|%s|%s", GROUP_DIS, KEY, VALUE) + " found.");
            return false;
        }
        
        return true;
      
    }
    
    @Override
    public boolean isExecutionRequired(ReturnDO returnDO, CommunicationPartnerDO communicationPartner)
    {
        
        if (null == returnDO)
        {
            throw new TechnicalException(DispatchDO.class, "ReturnDO is null");
        }

        String value = returnDO.getPropertyValue(GROUP_RET, KEY);
        if ((value != null) && value.equals(VALUE))
        {
            log.debug("Skipping return export, because custom property group|key|value = " + String.format("%s|%s|%s", GROUP_RET, KEY, VALUE) + " found.");
            return false;
        }
        
        return true;
      
    }

}
