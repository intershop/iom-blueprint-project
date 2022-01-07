package com.intershop.oms.ps.rest.logging.sl4j;

import static org.apache.commons.lang3.StringUtils.left;

import java.io.IOException;

import javax.annotation.Priority;
import javax.ws.rs.Priorities;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.container.ContainerResponseContext;
import javax.ws.rs.container.ContainerResponseFilter;
import javax.ws.rs.container.ResourceInfo;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.UriInfo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.ps.rest.logging.LoggingIOStreamHandler;
import com.intershop.oms.ps.rest.logging.MaskedHeaders;

@Priority(Priorities.USER + 1)
public class SLF4JContainerLoggingHandler implements ContainerResponseFilter, ContainerRequestFilter
{

    private static final Logger log = LoggerFactory.getLogger(SLF4JContainerLoggingHandler.class);

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
        log.debug("Response - StateCode: {}, Headers: {}", responseContext.getStatus(),
                        MaskedHeaders.of(responseContext.getHeaders()));
    }

    /**
     * @see javax.ws.rs.container.ContainerRequestFilter#filter(javax.ws.rs.container.ContainerRequestContext)
     */
    @Override
    public void filter(ContainerRequestContext requestContext) throws IOException
    {
        log.debug("Request - URL: {}, StateCode: {}, Headers: {}, Body:\n{}", uriInfo.getRequestUri(),
                        requestContext.getMethod(), MaskedHeaders.of(requestContext.getHeaders()),
                        left(LoggingIOStreamHandler.readEntity(requestContext), 10000));

    }
}
