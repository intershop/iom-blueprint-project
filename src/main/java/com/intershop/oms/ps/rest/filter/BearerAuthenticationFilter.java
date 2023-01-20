package com.intershop.oms.ps.rest.filter;

import static org.apache.commons.lang3.StringUtils.isNotBlank;

import java.io.IOException;

import jakarta.annotation.Priority;
import jakarta.ws.rs.Priorities;
import jakarta.ws.rs.client.ClientRequestContext;
import jakarta.ws.rs.client.ClientRequestFilter;

@Priority(Priorities.AUTHENTICATION)
public class BearerAuthenticationFilter implements ClientRequestFilter
{
    private String token;

    public BearerAuthenticationFilter(String token)
    {
        this.token = token;
    }

    @Override
    public void filter(ClientRequestContext requestContext) throws IOException
    {
        if (isNotBlank(token))
        {
            requestContext.getHeaders().add("authorization", "Bearer " + token);
        }
    }

}
