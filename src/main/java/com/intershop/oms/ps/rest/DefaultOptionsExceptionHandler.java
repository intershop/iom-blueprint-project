package com.intershop.oms.ps.rest;

import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

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
