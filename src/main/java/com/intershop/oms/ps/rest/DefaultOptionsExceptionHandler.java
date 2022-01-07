package com.intershop.oms.ps.rest;

import javax.ws.rs.core.Response;
import javax.ws.rs.ext.ExceptionMapper;
import javax.ws.rs.ext.Provider;

import org.jboss.resteasy.spi.DefaultOptionsMethodException;

@Provider
public class DefaultOptionsExceptionHandler implements ExceptionMapper<DefaultOptionsMethodException>
{
    @Override
    public Response toResponse(DefaultOptionsMethodException e)
    {
        return e.getResponse();
    }
}
