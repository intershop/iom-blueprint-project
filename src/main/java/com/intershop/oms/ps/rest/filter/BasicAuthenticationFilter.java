package com.intershop.oms.ps.rest.filter;

import static org.apache.commons.lang3.StringUtils.isNotBlank;

import java.io.IOException;
import java.util.Base64;

import jakarta.annotation.Priority;
import jakarta.ws.rs.Priorities;
import jakarta.ws.rs.client.ClientRequestContext;
import jakarta.ws.rs.client.ClientRequestFilter;

@Priority(Priorities.AUTHENTICATION)
public class BasicAuthenticationFilter implements ClientRequestFilter
{
    private String username, password;

    public BasicAuthenticationFilter(String username, String password)
    {
        this.username = username;
        this.password = password;
    }

    @Override
    public void filter(ClientRequestContext requestContext) throws IOException
    {
        if (isNotBlank(username) && isNotBlank(password))
        {
            requestContext.getHeaders().add("authorization", "Basic "
                            + Base64.getEncoder().encodeToString((username + ":" + password).getBytes("UTF-8")));
        }
    }

}
