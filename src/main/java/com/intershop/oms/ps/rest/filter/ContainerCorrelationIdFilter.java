package com.intershop.oms.ps.rest.filter;

import static org.apache.commons.lang3.StringUtils.isNotBlank;

import java.io.IOException;
import java.util.UUID;

import javax.annotation.Priority;
import javax.ws.rs.Priorities;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerResponseContext;
import javax.ws.rs.container.ContainerResponseFilter;
import javax.ws.rs.ext.Provider;

@Provider
@Priority(Priorities.HEADER_DECORATOR)
public class ContainerCorrelationIdFilter implements ContainerResponseFilter
{

    @Override
    public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext)
                    throws IOException
    {
        if (isNotBlank(responseContext.getHeaderString(ClientCorrelationIdFilter.X_CORRELATION_ID_HEADER)))
        {
            return;
        }
        String correlationId;
        if (requestContext != null && isNotBlank(
                        requestContext.getHeaderString(ClientCorrelationIdFilter.X_CORRELATION_ID_HEADER)))
        {
            correlationId = requestContext.getHeaderString(ClientCorrelationIdFilter.X_CORRELATION_ID_HEADER);
        }
        else
        {
            correlationId = UUID.randomUUID().toString();
        }

        responseContext.getHeaders().putSingle(ClientCorrelationIdFilter.X_CORRELATION_ID_HEADER, correlationId);

    }

}
