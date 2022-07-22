package com.intershop.oms.blueprint.transmitter;

import javax.ejb.EJB;
import javax.ejb.Stateless;

import com.intershop.oms.ps.services.configuration.ConfigurationLogicService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.theberlinbakery.types.v1_2.StoreOrder;
import com.theberlinbakery.types.v2_0.ReturnAnnouncementExport;

import bakery.logic.communication.mapper.out.OrderMapperOut;
import bakery.logic.communication.mapper.out.ReturnAnnouncementMapperOut;
import bakery.logic.service.transmission.MessageTransmitter;
import bakery.logic.service.transmission.TransmissionWrapper;
import bakery.logic.service.transmission.TransmissionWrapperFactory;
import bakery.persistence.dataobject.order.AbstractTransmission;
import bakery.persistence.dataobject.order.OrderTransmissionDO;
import bakery.persistence.dataobject.rma.ReturnAnnouncementTransmissionDO;
import bakery.util.DeploymentConfig;
import bakery.util.exception.TechnicalException;
import bakery.util.exception.ValidationException;

/**
 * Exports a shop message (order, rma) to a 3rd party system by REST API call.
 */
@Stateless
public class ShopMessageTransmitterBean implements MessageTransmitter
{
    private static final Logger log = LoggerFactory.getLogger(ShopMessageTransmitterBean.class);

    //@EJB(lookup=OrderMapperOut.LOGIC_ORDERMAPPEROUT)
    @EJB(lookup = "java:global/bakery.base-app-" + DeploymentConfig.APP_VERSION + "/bakery.logic-core-"
                    + DeploymentConfig.APP_VERSION
                    + "/OrderMapperOutBean_v1_1!bakery.logic.communication.mapper.out.OrderMapperOut")
    private OrderMapperOut orderMapperOut;

    @EJB(lookup=ReturnAnnouncementMapperOut.JNDI_NAME_V2_0)
    private ReturnAnnouncementMapperOut returnAnnouncementMapperOut;

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

        // order transmission
        if (abstractTransmission instanceof OrderTransmissionDO)
        {
            OrderTransmissionDO orderTransmissionDO = (OrderTransmissionDO)abstractTransmission;

            return transmitOrder(orderTransmissionDO);
        }

        // rma transmission
        if (abstractTransmission instanceof ReturnAnnouncementTransmissionDO)
        {
            ReturnAnnouncementTransmissionDO returnAnnouncementTransmissionDO = (ReturnAnnouncementTransmissionDO)abstractTransmission;

            return transmitReturnAnnouncement(returnAnnouncementTransmissionDO);
        }

        return abstractTransmission;
    }

    private OrderTransmissionDO transmitOrder(OrderTransmissionDO transmissionDO)
    {
        StoreOrder storeOrder;
        
        Long orderId = transmissionDO.getOrderDO().getId();        
        log.debug("Started transmitting order " + orderId);

        TransmissionWrapper transmissionWrapper = transmissionWrapperFactory.getTransmissionWrapper(transmissionDO);
        try
        {
            storeOrder = (StoreOrder)orderMapperOut.mapOrder(transmissionDO, transmissionWrapper);
        }
        catch(ValidationException e)
        {
            log.error("Failed to map order: {}", e.getMessage());
            throw new TechnicalException("Failed to map order: {}" + e);
        }

        /**
         * If desired, add more data to storeOrder
         */
        
        /**
         * Make 3rd party API call using storeOrder
         */
        
        log.debug("Finished transmitting order " + orderId);
        
        return transmissionDO;
    }

    private ReturnAnnouncementTransmissionDO transmitReturnAnnouncement(ReturnAnnouncementTransmissionDO transmissionDO)
    {
        ReturnAnnouncementExport returnAnnouncementExport;
        
        Long orderId = transmissionDO.getOrderDO().getId();
        Long returnAnnouncementId = transmissionDO.getReturnAnnouncementDO().getId();
        log.debug("Started transmitting return annoucement " + returnAnnouncementId + " for order " + orderId);

//        TransmissionWrapper transmissionWrapper = transmissionWrapperFactory.getTransmissionWrapper(transmissionDO);
//        try
//        {
            returnAnnouncementExport = (ReturnAnnouncementExport)returnAnnouncementMapperOut.mapReturnAnnouncement(transmissionDO);
//        }
//        catch(ValidationException e)
//        {
//            log.error("Failed to map order: {}", e.getMessage());
//            throw new TechnicalException("Failed to map order: {}" + e);
//        }

        /**
         * If desired, add more data to returnAnnouncementExport
         */
        
        /**
         * Make 3rd party API call using returnAnnouncementExport
         */
        
        log.debug("Finished transmitting return annoucement " + returnAnnouncementId + " for order " + orderId);
        
        return transmissionDO;
    }

    @Override
    public String getTransmissionMedium()
    {
        return TransmissionMedium.Http.toString();
    }

}
