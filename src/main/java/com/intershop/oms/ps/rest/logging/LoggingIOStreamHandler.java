package com.intershop.oms.ps.rest.logging;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.zip.GZIPInputStream;

import javax.ws.rs.client.ClientResponseContext;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.ext.WriterInterceptorContext;

import org.apache.commons.lang3.StringUtils;

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
