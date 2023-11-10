package com.intershop.oms.ps.rest.logging.sl4j;

import java.io.IOException;

import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.ext.WriterInterceptor;
import jakarta.ws.rs.ext.WriterInterceptorContext;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.ps.rest.logging.LoggingIOStreamHandler;

/**
 * - client side interceptor to get the REQUEST body - server side interceptor
 * to get the RESPONSE body
 *
 * @author PBorchert
 *
 */
public class SLF4JWriterInterceptor implements WriterInterceptor
{
    private static final Logger log = LoggerFactory.getLogger(SLF4JWriterInterceptor.class);

    /**
     * @see javax.ws.rs.ext.WriterInterceptor#aroundWriteTo(javax.ws.rs.ext.WriterInterceptorContext)
     */
    @Override
    public void aroundWriteTo(WriterInterceptorContext writerInterceptorContext)
                    throws IOException, WebApplicationException
    {
        log.debug("Payload body: {}", LoggingIOStreamHandler.readEntity(writerInterceptorContext));
    }

}
