package com.intershop.oms.ps.rest.logging.sl4j;

import java.io.IOException;

import javax.annotation.Priority;
import javax.ws.rs.Priorities;
import javax.ws.rs.client.ClientRequestContext;
import javax.ws.rs.client.ClientRequestFilter;
import javax.ws.rs.client.ClientResponseContext;
import javax.ws.rs.client.ClientResponseFilter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.ps.rest.logging.LoggingIOStreamHandler;
import com.intershop.oms.ps.rest.logging.MaskedHeaders;

@Priority(Priorities.USER + 1)
public class SLF4JClientLoggingHandler implements ClientResponseFilter, ClientRequestFilter
{

    private static final Logger log = LoggerFactory.getLogger(SLF4JClientLoggingHandler.class);

    @Override
    public void filter(ClientRequestContext requestContext, ClientResponseContext responseContext) throws IOException
    {
        log.debug("Response - StateCode: {}, Headers: {}, Body:\n{}", responseContext.getStatus(),
                        MaskedHeaders.of(responseContext.getHeaders()),
                        LoggingIOStreamHandler.readEntity(responseContext));

    }

    @Override
    public void filter(ClientRequestContext requestContext) throws IOException
    {
        log.debug("Request - URL: {}, Headers: {}", requestContext.getUri(),
                        MaskedHeaders.of(requestContext.getHeaders()));
    }
}
