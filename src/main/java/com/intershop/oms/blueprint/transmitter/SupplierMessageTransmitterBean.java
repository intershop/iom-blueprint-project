package com.intershop.oms.blueprint.transmitter;

import javax.ejb.EJB;
import javax.ejb.Stateless;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.ps.services.configuration.ConfigurationLogicService;
import com.theberlinbakery.types.v1_0.StoreDispatch;
import com.theberlinbakery.types.v1_0.StoreResponse;
import com.theberlinbakery.types.v1_0.StoreReturn;

import bakery.logic.communication.mapper.out.DispatchMapperOut;
import bakery.logic.communication.mapper.out.ResponseMapperOut;
import bakery.logic.communication.mapper.out.ReturnMapperOut;
import bakery.logic.service.transmission.MessageTransmitter;
import bakery.logic.service.transmission.TransmissionWrapper;
import bakery.logic.service.transmission.TransmissionWrapperFactory;
import bakery.persistence.dataobject.order.AbstractTransmission;
import bakery.persistence.dataobject.order.DispatchTransmissionDO;
import bakery.persistence.dataobject.order.ResponseTransmissionDO;
import bakery.persistence.dataobject.order.ReturnTransmissionDO;
import bakery.util.DeploymentConfig;
import bakery.util.exception.TechnicalException;
import bakery.util.exception.ValidationException;

/**
 * Exports a supplier message (response, dispatch, return) to a 3rd party system by API call.
 */
@Stateless
public class SupplierMessageTransmitterBean implements MessageTransmitter
{
    private static final Logger log = LoggerFactory.getLogger(SupplierMessageTransmitterBean.class);

    @EJB(lookup = "java:global/bakery.base-app-" + DeploymentConfig.APP_VERSION + "/bakery.logic-core-"
                    + DeploymentConfig.APP_VERSION
                    + "/ResponseMapperOutBean!bakery.logic.communication.mapper.out.ResponseMapperOut")
    private ResponseMapperOut responseMapperOut;
    
    @EJB(lookup = DispatchMapperOut.LOGIC_DISPATCHMAPPEROUT)
    private DispatchMapperOut dispatchMapperOut;
    
    @EJB(lookup = "java:global/bakery.base-app-" + DeploymentConfig.APP_VERSION + "/bakery.logic-core-"
                    + DeploymentConfig.APP_VERSION
                    + "/ReturnMapperOutBean!bakery.logic.communication.mapper.out.ReturnMapperOut")
    private ReturnMapperOut returnMapperOut;

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

        if (abstractTransmission instanceof ResponseTransmissionDO)
        {
            ResponseTransmissionDO responseTransmissionDO = (ResponseTransmissionDO)abstractTransmission;

            return transmitResponse(responseTransmissionDO);
        }
        
        if (abstractTransmission instanceof DispatchTransmissionDO)
        {
            DispatchTransmissionDO dispatchTransmissionDO = (DispatchTransmissionDO)abstractTransmission;

            return transmitDispatch(dispatchTransmissionDO);
        }
        
        if (abstractTransmission instanceof ReturnTransmissionDO)
        {
            ReturnTransmissionDO returnTransmissionDO = (ReturnTransmissionDO)abstractTransmission;

            return transmitReturn(returnTransmissionDO);
        }

        return abstractTransmission;
    }

    private ResponseTransmissionDO transmitResponse(ResponseTransmissionDO responseTransmissionDO)
    {
        StoreResponse storeResponse;
        
        Long orderId = responseTransmissionDO.getOrderDO().getId();
        Long responseId = responseTransmissionDO.getResponseDO().getId();
        log.debug("Started transmitting response " + responseId + " for order " + orderId + ".");

        /**
         * Map to API-object.
         */
        TransmissionWrapper transmissionWrapper = transmissionWrapperFactory.getTransmissionWrapper(responseTransmissionDO);
        try
        {
            storeResponse = (StoreResponse)responseMapperOut.mapResponse(responseTransmissionDO, transmissionWrapper);
        }
        catch(ValidationException e)
        {
            log.error("Failed to map response: {}", e.getMessage());
            throw new TechnicalException("Failed to map response: {}" + e);
        }

        /**
         * If required storeResponse can be extended storeResponse-object using the related responseTransmissionDO.getResponseDO().
         */
        
        /**
         * Make 3rd party API call using storeResponse-object.
         */
        
        log.debug("Finished transmitting response " + responseId + " for order " + orderId + ".");
        
        return responseTransmissionDO;
    }
    
    private DispatchTransmissionDO transmitDispatch(DispatchTransmissionDO dispatchTransmissionDO)
    {
        StoreDispatch storeDispatch;
        
        Long orderId = dispatchTransmissionDO.getOrderDO().getId();
        Long dispatchId = dispatchTransmissionDO.getDispatchDO().getId();
        log.debug("Started transmitting dispatch " + dispatchId + " for order " + orderId + ".");

        /**
         * Map to API-object.
         */
        TransmissionWrapper transmissionWrapper = transmissionWrapperFactory.getTransmissionWrapper(dispatchTransmissionDO);
        try
        {
            storeDispatch = (StoreDispatch)dispatchMapperOut.mapDispatch(dispatchTransmissionDO, transmissionWrapper);
        }
        catch(ValidationException e)
        {
            log.error("Failed to map dispatch: {}", e.getMessage());
            throw new TechnicalException("Failed to map dispatch: {}" + e);
        }

        /**
         * If required storeDispatch can be extended storeDispatch-object using the related dispatchTransmissionDO.getDispatchDO()
         */
        
        /**
         * Make 3rd party API call using storeDispatch-object.
         */
        
        log.debug("Finished transmitting dispatch " + dispatchId + " for order " + orderId + ".");
        
        return dispatchTransmissionDO;
    }
    
    private ReturnTransmissionDO transmitReturn(ReturnTransmissionDO returnTransmissionDO)
    {
        StoreReturn storeReturn;
        
        Long orderId = returnTransmissionDO.getOrderDO().getId();
        Long returnId = returnTransmissionDO.getReturnDO().getId();
        log.debug("Started transmitting return " + returnId + " for order " + orderId);

        /**
         * Map to API-object.
         */
        TransmissionWrapper transmissionWrapper = transmissionWrapperFactory.getTransmissionWrapper(returnTransmissionDO);
        storeReturn = (StoreReturn)returnMapperOut.mapReturn(returnTransmissionDO, transmissionWrapper);

        /**
         * If required storeReturn can be extended storeReturn-object using the related returnTransmissionDO.getReturnDO()
         */
        
        /**
         * Make 3rd party API call using storeReturn-object.
         */
        
        log.debug("Finished transmitting return " + returnId + " for order " + orderId);
        
        return returnTransmissionDO;
    }

    @Override
    public String getTransmissionMedium()
    {
        return TransmissionMedium.Http.toString();
    }

}
