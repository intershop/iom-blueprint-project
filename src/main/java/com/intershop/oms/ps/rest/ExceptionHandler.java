package com.intershop.oms.ps.rest;

import jakarta.ws.rs.ForbiddenException;
import jakarta.ws.rs.NotAllowedException;
import jakarta.ws.rs.NotAuthorizedException;
import jakarta.ws.rs.NotFoundException;
import jakarta.ws.rs.core.HttpHeaders;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.intershop.oms.rolemgmt.capi.OMSAuthorizeException;

import bakery.util.exception.NoObjectException;

@Provider
public class ExceptionHandler implements ExceptionMapper<Exception>
{
    private static final Logger log = LoggerFactory.getLogger(ExceptionHandler.class);

    /**
     * returns true if the given exception is equal to the given exceptionClazz
     * or is caused by it
     *
     * @param e
     * @return true if the given exception is equal the given exceptionClazz or
     *         is caused by it
     */
    private boolean isCausedBy(Exception exception, Class<? extends Exception> exceptionClazz)
    {
        if (exceptionClazz.isAssignableFrom(exception.getClass()))
        {
            return true;
        }

        if (exception.getCause() != null && exceptionClazz.isAssignableFrom(exception.getCause().getClass()))
        {
            return true;
        }

        return false;
    }

    @Override
    public Response toResponse(Exception e)
    {
        if (isCausedBy(e, NoObjectException.class))
        {
            log.warn(e.getMessage());
            return Response.status(Response.Status.NOT_FOUND).entity(notNullString(e.getMessage()))
                            .type(MediaType.TEXT_PLAIN).build();
        }
        else if (isCausedBy(e, NotAuthorizedException.class))
        {
            log.warn(e.getMessage());
            return Response.status(Response.Status.UNAUTHORIZED)
                            .header(HttpHeaders.WWW_AUTHENTICATE, "Basic realm=\"PP API\"").entity(e.getMessage())
                            .type(MediaType.TEXT_PLAIN_TYPE).build();
        }
        else if (isCausedBy(e, NotAllowedException.class))
        {
            log.warn(e.getMessage());
            return Response.status(Response.Status.METHOD_NOT_ALLOWED).entity(notNullString(e.getMessage()))
                            .type(MediaType.TEXT_PLAIN).build();
        }
        else if (isCausedBy(e, NotFoundException.class) || isCausedBy(e, IllegalArgumentException.class)
                        || isCausedBy(e, JsonProcessingException.class))
        {
            log.error(e.getMessage());
            return Response.status(Response.Status.BAD_REQUEST).entity(notNullString(e.getMessage()))
                            .type(MediaType.TEXT_PLAIN).build();
        }
        else if (isCausedBy(e, OMSAuthorizeException.class))
        {
            log.warn(e.getMessage());
            return Response.status(Response.Status.FORBIDDEN).entity(notNullString(e.getMessage()))
                            .type(MediaType.TEXT_PLAIN).build();
        }
        else if (isCausedBy(e, ForbiddenException.class))
        {
            log.warn(e.getMessage());
            return Response.status(Response.Status.FORBIDDEN).entity(notNullString(e.getMessage()))
                            .type(MediaType.TEXT_PLAIN).build();
        }
        else
        {
            log.error(e.getMessage(), e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(notNullString(e.getMessage())).build();
        }
    }

    private String notNullString(String message)
    {
        return message != null ? message : "Unknown Error Message";
    }
}
