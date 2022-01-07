package com.intershop.oms.ps.rest.filter;

import java.io.IOException;

import javax.annotation.Priority;
import javax.ws.rs.Priorities;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerResponseContext;
import javax.ws.rs.container.ContainerResponseFilter;
import javax.ws.rs.ext.Provider;

@Provider
@Priority(Priorities.HEADER_DECORATOR)
public class CORSFilter implements ContainerResponseFilter
{

    @Override
    public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext)
                    throws IOException
    {
        responseContext.getHeaders().add("Access-Control-Allow-Origin", "*");
        responseContext.getHeaders().add("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH");
        responseContext.getHeaders().add("Access-Control-Max-Age", "-1");
        responseContext.getHeaders().add("Access-Control-Allow-Headers",
                        "Authorization, Origin, X-Requested-With, Content-Type, Accept, X-API-Token");
    }

}
