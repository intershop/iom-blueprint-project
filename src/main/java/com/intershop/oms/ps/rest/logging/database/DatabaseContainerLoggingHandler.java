package com.intershop.oms.ps.rest.logging.database;

import java.io.IOException;
import java.lang.reflect.Method;
import java.net.URI;

import jakarta.annotation.Priority;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import jakarta.ws.rs.Priorities;
import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.container.ContainerRequestFilter;
import jakarta.ws.rs.container.ContainerResponseContext;
import jakarta.ws.rs.container.ContainerResponseFilter;
import jakarta.ws.rs.container.ResourceInfo;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.UriInfo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.ps.rest.logging.LoggingIOStreamHandler;
import com.intershop.oms.ps.rest.logging.MaskedHeaders;

import bakery.logic.communication.messagelog.MessageLogContext;
import bakery.logic.communication.messagelog.MessageLogException;
import bakery.logic.communication.messagelog.MessageLogManager;
import bakery.persistence.dataobject.order.OrderMessageLogDO;

@Priority(Priorities.USER + 1)
public class DatabaseContainerLoggingHandler implements ContainerResponseFilter, ContainerRequestFilter
{
    private static final Logger log = LoggerFactory.getLogger(DatabaseContainerLoggingHandler.class);

    @Context
    private ResourceInfo resourceInfo;

    @Context
    private UriInfo uriInfo;

    /**
     * @see javax.ws.rs.container.ContainerResponseFilter#filter(javax.ws.rs.container.ContainerRequestContext,
     *      javax.ws.rs.container.ContainerResponseContext)
     */
    @Override
    public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext)
                    throws IOException
    {

        Integer status = responseContext.getStatus();
        String responseHeader = String.format("StateCode: %s, Headers: %s", status,
                        MaskedHeaders.of(responseContext.getHeaders()));

        OrderMessageLogDO orderMessageLogDO = MessageLogContext.safeGetOrderMessageLog();
        orderMessageLogDO.setResponse(responseHeader);
        orderMessageLogDO.setHttpCode(status);

        /*
         * bestimme den MessageType aus der @Method-Annotation der aufgerufenen
         * Methode
         */
        try
        {
            if (this.resourceInfo != null)
            {
                Method method = this.resourceInfo.getResourceMethod();

                if (method != null)
                {
                    /*
                     * Methoden- und Klassennamen für das MessageLog bestimmen
                     */
                    String className = method.getDeclaringClass().getSimpleName();
                    String methodName = method.getName();
                    String methodClassname = String.format("%s.%s", className, methodName);

                    orderMessageLogDO.setConnection(methodClassname);

                }
            }
        }
        catch(Exception e)
        {
            /*
             * wahrscheinlich Fehler beim Holen des ResourceInfo-Objekts
             */
            log.warn(e.getMessage());
        }

        try
        {
            javax.naming.Context initialContext = new InitialContext();
            MessageLogManager messageLogManager = (MessageLogManager)initialContext
                            .lookup(MessageLogManager.LOGIC_COMMUNICATION_MESSAGELOGMANAGERBEAN);
            /*
             * wenn der ResponseContext keine Daten für den ResponseBody
             * enthält, wird der WriterInterceptor nicht aufgerufen - in diesem
             * Falle rufe die Methode auf, welche auch den MessageLogContext
             * leert
             */
            if (responseContext.getEntity() != null)
            {
                messageLogManager.updateMessageLog();
            }
            else
            {
                messageLogManager.storeResponse();
            }
        }
        catch(NamingException | MessageLogException e)
        {
            log.error("Error while saving the MessageLog", e);
        }

    }

    /**
     * @see javax.ws.rs.container.ContainerRequestFilter#filter(javax.ws.rs.container.ContainerRequestContext)
     */
    @Override
    public void filter(ContainerRequestContext requestContext) throws IOException
    {
        URI uri = this.uriInfo.getRequestUri();
        String requestHeader = String.format("URI: %s, Method: %s, Headers: %s", uri, requestContext.getMethod(),
                        MaskedHeaders.of(requestContext.getHeaders()));

        String requestBody = LoggingIOStreamHandler.readEntity(requestContext);

        String request = null;

        if (requestBody.isEmpty())
        {
            request = requestHeader;
        }
        else
        {
            request = String.format("%s\n%s", requestHeader, requestBody);
        }

        MessageLogContext.clear();

        OrderMessageLogDO orderMessageLogDO = MessageLogContext.safeGetOrderMessageLog();
        orderMessageLogDO.setRequest(request);
        orderMessageLogDO.setUrlPath(uri.toString());
        orderMessageLogDO.setIncomingMessage(true);

        try
        {
            javax.naming.Context initialContext = new InitialContext();
            MessageLogManager messageLogManager = (MessageLogManager)initialContext
                            .lookup(MessageLogManager.LOGIC_COMMUNICATION_MESSAGELOGMANAGERBEAN);
            messageLogManager.storeRequest();
        }
        catch(NamingException | MessageLogException e)
        {
            log.error("Error while saving the messagelog", e);
        }

        log.debug("ContainerRequestFilter ended.");
    }

}
