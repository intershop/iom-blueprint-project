package com.intershop.oms.ps.rest.logging;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.zip.GZIPInputStream;

import jakarta.ws.rs.client.ClientResponseContext;
import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.core.HttpHeaders;
import jakarta.ws.rs.ext.WriterInterceptorContext;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.client.entity.EntityBuilder;
import org.apache.http.entity.ContentType;

public class LoggingIOStreamHandler
{
    public static String readEntity(ClientResponseContext responseContext) throws IOException
    {
        InputStream inputStream = responseContext.getEntityStream();

        byte[] bytes = new byte[1024];

        int read = -1;
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        while((read = inputStream.read(bytes)) != -1)
        {
            bos.write(bytes, 0, read);
        }

        String responseContent;

        if (StringUtils.equals("gzip", responseContext.getHeaderString(HttpHeaders.CONTENT_ENCODING)))
        {
            try (InputStream isCompressed = new GZIPInputStream(new ByteArrayInputStream(bos.toByteArray())))
            {
                ByteArrayOutputStream bosUncompressed = new ByteArrayOutputStream();
                while((read = isCompressed.read(bytes)) != -1)
                {
                    bosUncompressed.write(bytes, 0, read);
                }

                responseContent = bosUncompressed.toString("UTF-8");

            }

        }
        else
        {
            responseContent = bos.toString("UTF-8");
        }

        responseContext.setEntityStream(new ByteArrayInputStream(bos.toByteArray()));
        return responseContent;
    }

    public static String readEntity(HttpResponse response) throws IOException
    {
        InputStream inputStream = response.getEntity().getContent();
        
        byte[] bytes = new byte[1024];

        int read = -1;
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        while((read = inputStream.read(bytes)) != -1)
        {
            bos.write(bytes, 0, read);
        }
        
        String responseContent;
        
        Header encodingHeader = response.getFirstHeader(HttpHeaders.CONTENT_ENCODING);
        
        if (encodingHeader != null && StringUtils.equals("gzip", encodingHeader.getValue()))
        {
            try (InputStream isCompressed = new GZIPInputStream(new ByteArrayInputStream(bos.toByteArray())))
            {
                ByteArrayOutputStream bosUncompressed = new ByteArrayOutputStream();
                while((read = isCompressed.read(bytes)) != -1)
                {
                    bosUncompressed.write(bytes, 0, read);
                }
                responseContent = bosUncompressed.toString("UTF-8");
            }
        }
        else
        {
            responseContent = bos.toString("UTF-8");
        }

        response.setEntity(EntityBuilder.create().setStream(new ByteArrayInputStream(bos.toByteArray()))
                        .setContentType(ContentType.get(response.getEntity())).build());
        
        return responseContent;
    }

    public static String readEntity(ContainerRequestContext requestContext) throws IOException
    {
        InputStream inputStream = requestContext.getEntityStream();

        byte[] bytes = new byte[1024];

        int read = -1;
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        while((read = inputStream.read(bytes)) != -1)
        {
            bos.write(bytes, 0, read);
        }

        String responseContent = bos.toString("UTF-8");

        requestContext.setEntityStream(new ByteArrayInputStream(responseContent.getBytes()));

        return responseContent;

    }

    public static String readEntity(WriterInterceptorContext writerInterceptorContext) throws IOException
    {
        OutputStream outputStream = writerInterceptorContext.getOutputStream();

        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        writerInterceptorContext.setOutputStream(byteArrayOutputStream);

        writerInterceptorContext.proceed();

        byte[] byteArray = byteArrayOutputStream.toByteArray();
        outputStream.write(byteArray);
        writerInterceptorContext.setOutputStream(outputStream);

        String payloadBody = new String(byteArray);

        return payloadBody;

    }

}