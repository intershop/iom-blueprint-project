package com.intershop.oms.ps.rest.logging.database;

import java.io.IOException;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.ws.rs.WebApplicationException;
import javax.ws.rs.ext.WriterInterceptor;
import javax.ws.rs.ext.WriterInterceptorContext;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.ps.rest.logging.LoggingIOStreamHandler;

import bakery.logic.communication.messagelog.MessageLogContext;
import bakery.logic.communication.messagelog.MessageLogException;
import bakery.logic.communication.messagelog.MessageLogManager;
import bakery.persistence.dataobject.order.OrderMessageLogDO;

public abstract class DatabaseWriterInterceptor implements WriterInterceptor
{
    private final boolean serverMode;
    private final Logger log = LoggerFactory.getLogger(getClass());

    public DatabaseWriterInterceptor(boolean serverMode)
    {
        this.serverMode = serverMode;
    }

    @Override
    public void aroundWriteTo(WriterInterceptorContext writerInterceptorContext)
                    throws IOException, WebApplicationException
    {
        String payloadBody = LoggingIOStreamHandler.readEntity(writerInterceptorContext);

        /*
         * wenn schon eine Response aus dem ContainerResponseFilter im
         * OrderMessageLog vorhanden ist, hänge den ResponseBody an
         */
        OrderMessageLogDO orderMessageLogDO = MessageLogContext.safeGetOrderMessageLog();

        if (serverMode)
        {

            String responseHeader = orderMessageLogDO.getResponse();

            String response = null;

            if (responseHeader == null)
            {
                response = payloadBody;
            }
            else
            {
                response = String.format("%s\n%s", responseHeader, payloadBody);
            }

            orderMessageLogDO.setResponse(response);
        }
        else
        {
            orderMessageLogDO.setRequest(StringUtils.join(orderMessageLogDO.getRequest(), "\n", payloadBody));
        }

        try
        {

            javax.naming.Context initialContext = new InitialContext();
            MessageLogManager messageLogManager = (MessageLogManager)initialContext
                            .lookup(MessageLogManager.LOGIC_COMMUNICATION_MESSAGELOGMANAGERBEAN);
            if (serverMode)
            {
                messageLogManager.storeResponse();
            }
            else
            {
                messageLogManager.storeRequest();
            }
        }
        catch(NamingException | MessageLogException e)
        {
            log.error("Error while saving the MessageLog", e);
        }

    }

    public static class DatabaseClientWriterIntercepter extends DatabaseWriterInterceptor
    {
        public DatabaseClientWriterIntercepter()
        {
            super(false);
        }
    }

    public static class DatabaseServerWriterIntercepter extends DatabaseWriterInterceptor
    {
        public DatabaseServerWriterIntercepter()
        {
            super(true);
        }
    }
}
