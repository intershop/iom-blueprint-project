package com.intershop.oms.ps.rest.filter;

import static org.apache.commons.lang3.StringUtils.isNotBlank;

import java.io.IOException;

import javax.annotation.Priority;
import javax.ws.rs.Priorities;
import javax.ws.rs.client.ClientRequestContext;
import javax.ws.rs.client.ClientRequestFilter;

@Priority(Priorities.HEADER_DECORATOR)
public class ClientCorrelationIdFilter implements ClientRequestFilter
{
    public static final String X_CORRELATION_ID_HEADER = "X-Correlation-ID";

    private String correlationId;

    public ClientCorrelationIdFilter(String correlationId)
    {
        this.correlationId = correlationId;
    }

    @Override
    public void filter(ClientRequestContext requestContext) throws IOException
    {
        if (isNotBlank(correlationId))
        {
            requestContext.getHeaders().add(X_CORRELATION_ID_HEADER, correlationId);
        }
    }

}
