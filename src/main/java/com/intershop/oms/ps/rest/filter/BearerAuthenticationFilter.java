package com.intershop.oms.ps.rest.filter;

import static org.apache.commons.lang3.StringUtils.isNotBlank;

import java.io.IOException;

import javax.annotation.Priority;
import javax.ws.rs.Priorities;
import javax.ws.rs.client.ClientRequestContext;
import javax.ws.rs.client.ClientRequestFilter;

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
