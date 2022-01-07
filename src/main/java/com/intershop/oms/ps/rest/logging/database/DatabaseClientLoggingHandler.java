package com.intershop.oms.ps.rest.logging.database;

import java.io.IOException;

import javax.annotation.Priority;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.ws.rs.Priorities;
import javax.ws.rs.client.ClientRequestContext;
import javax.ws.rs.client.ClientRequestFilter;
import javax.ws.rs.client.ClientResponseContext;
import javax.ws.rs.client.ClientResponseFilter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.ps.rest.logging.LoggingIOStreamHandler;
import com.intershop.oms.ps.rest.logging.MaskedHeaders;

import bakery.logic.communication.messagelog.MessageLogContext;
import bakery.logic.communication.messagelog.MessageLogException;
import bakery.logic.communication.messagelog.MessageLogManager;
import bakery.persistence.dataobject.order.OrderMessageLogDO;

@Priority(Priorities.USER + 1)
public class DatabaseClientLoggingHandler implements ClientResponseFilter, ClientRequestFilter
{
    private static final Logger log = LoggerFactory.getLogger(DatabaseClientLoggingHandler.class);

    @Override
    public void filter(ClientRequestContext requestContext, ClientResponseContext responseContext) throws IOException
    {
        String responseHeader = String.format("StateCode: [%s], Headers: [%s]", responseContext.getStatus(),
                        MaskedHeaders.of(responseContext.getHeaders()));

        OrderMessageLogDO orderMessageLogDO = MessageLogContext.safeGetOrderMessageLog();

        orderMessageLogDO.setResponse(responseHeader + "\n" + LoggingIOStreamHandler.readEntity(responseContext));
        orderMessageLogDO.setHttpCode(responseContext.getStatus());

        try
        {
            javax.naming.Context initialContext = new InitialContext();
            MessageLogManager messageLogManager = (MessageLogManager)initialContext
                            .lookup(MessageLogManager.LOGIC_COMMUNICATION_MESSAGELOGMANAGERBEAN);

            messageLogManager.storeResponse();
        }
        catch(NamingException | MessageLogException e)
        {
            log.error("Fehler beim Speichern des MessageLogs", e);
        }

    }

    @Override
    public void filter(ClientRequestContext requestContext) throws IOException
    {
        String uri = requestContext.getUri().toString();

        OrderMessageLogDO orderMessageLogDO = MessageLogContext.safeGetOrderMessageLog();

        orderMessageLogDO.setConnection(uri);
        orderMessageLogDO.setRequest(MaskedHeaders.of(requestContext.getHeaders()).toString());

    }
}
