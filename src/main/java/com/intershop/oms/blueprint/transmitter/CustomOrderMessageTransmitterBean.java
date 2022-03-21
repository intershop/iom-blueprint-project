package com.intershop.oms.blueprint.transmitter;

import javax.ejb.EJB;
import javax.ejb.Stateless;

import com.intershop.oms.ps.services.configuration.ConfigurationLogicService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.theberlinbakery.types.v1_2.StoreOrder;

import bakery.logic.communication.mapper.out.OrderMapperOut;
import bakery.logic.service.transmission.MessageTransmitter;
import bakery.logic.service.transmission.TransmissionWrapper;
import bakery.logic.service.transmission.TransmissionWrapperFactory;
import bakery.persistence.dataobject.order.AbstractTransmission;
import bakery.persistence.dataobject.order.OrderTransmissionDO;
import bakery.util.DeploymentConfig;
import bakery.util.exception.TechnicalException;
import bakery.util.exception.ValidationException;

/**
 * Exports an order to a 3rd party system by HTTP API call.
 */
@Stateless
public class CustomOrderMessageTransmitterBean implements MessageTransmitter
{
    private static final Logger log = LoggerFactory.getLogger(CustomOrderMessageTransmitterBean.class);

    @EJB(lookup = "java:global/bakery.base-app-" + DeploymentConfig.APP_VERSION + "/bakery.logic-core-"
                    + DeploymentConfig.APP_VERSION
                    + "/OrderMapperOutBean_v1_1!bakery.logic.communication.mapper.out.OrderMapperOut")
    private OrderMapperOut orderMapperOut;

    @EJB(lookup = TransmissionWrapperFactory.LOGIC_TRANSMISSIONFACTORYBEAN)
    private TransmissionWrapperFactory transmissionWrapperFactory;
    
    @EJB
    private ConfigurationLogicService configurationLogicService;

    @Override
    public AbstractTransmission transmit(AbstractTransmission abstractTransmission)
    {
        if (abstractTransmission == null)
        {
            throw new IllegalArgumentException("Transmission object is null.");
        }

        if (abstractTransmission instanceof OrderTransmissionDO)
        {
            OrderTransmissionDO orderTransmissionDO = (OrderTransmissionDO)abstractTransmission;

            return this.transmitOrder(orderTransmissionDO);
        }

        return abstractTransmission;
    }

    private OrderTransmissionDO transmitOrder(OrderTransmissionDO orderTransmissionDO)
    {
        StoreOrder storeOrder;
        
        Long orderId = orderTransmissionDO.getOrderDO().getId();        
        log.debug("Started transmitting order " + orderId);

        TransmissionWrapper transmissionWrapper = transmissionWrapperFactory.getTransmissionWrapper(orderTransmissionDO);
        try
        {
            storeOrder = (StoreOrder)orderMapperOut.mapOrder(orderTransmissionDO, transmissionWrapper);
        }
        catch(ValidationException e)
        {
            log.error("Failed to map order: {}", e.getMessage());
            throw new TechnicalException("Failed to map order: {}" + e);
        }

        /**
         * If required storeOrder can be extended storeOrder-object using the related orderTransmissionDO.getOrder()
         */
        
        /**
         * Make 3rd party API call using storeOrder-object.
         */
        
        log.debug("Finished transmitting order " + orderId);
        
        return orderTransmissionDO;
    }

    @Override
    public String getTransmissionMedium()
    {
        return TransmissionMedium.Http.toString();
    }

}
