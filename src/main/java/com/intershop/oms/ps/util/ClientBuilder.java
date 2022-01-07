package com.intershop.oms.ps.util;

import static org.apache.commons.lang3.StringUtils.isNotBlank;

import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.SSLContext;
import javax.ws.rs.client.Client;

import com.intershop.oms.ps.rest.filter.BasicAuthenticationFilter;
import com.intershop.oms.ps.rest.filter.ClientCorrelationIdFilter;
import com.intershop.oms.ps.rest.logging.database.DatabaseClientLoggingHandler;
import com.intershop.oms.ps.rest.logging.database.DatabaseWriterInterceptor.DatabaseClientWriterIntercepter;
import com.intershop.oms.ps.rest.logging.sl4j.SLF4JClientLoggingHandler;
import com.intershop.oms.ps.rest.logging.sl4j.SLF4JWriterInterceptor;

import bakery.logic.communication.messagelog.MessageLogContext;
import bakery.persistence.expand.MessageTypeDefDOEnumInterface;

public class ClientBuilder
{
    private String remoteURL;
    private boolean logToConsole = true;
    private boolean logToDatabase = false;
    private Long timeOutInMillis;
    private BasicAuthenticationFilter basicAuthFilter;
    private String correlationId;

    private ClientBuilder()
    {
    };

    private ClientBuilder(String remoteURL)
    {
        this.remoteURL = remoteURL;
    }

    public static ClientBuilder create(String remoteURL)
    {
        return new ClientBuilder(remoteURL);
    }

    /**
     * WARNING: This will clear the current MessageLogContext!
     *
     * @deprecated please use
     *             {@link #enableDatabaseLogging(MessageTypeDefDOEnumInterface, Long)}
     *             instead. the OrderMessageLog should only be used for
     *             transactional communication (e.g. order export), i.e. the
     *             parameters for message type and object id should be known. If
     *             you find a valid usecase where this is not applicable please
     *             revert the deprecation and document the reason here.
     * @return
     */
    @Deprecated
    public ClientBuilder enableDatabaseLogging()
    {
        this.logToDatabase = true;
        return this;
    }

    /**
     * Initialized database logging with the provided message type and objectId
     * (e.g. id of the transmission object)
     *
     * WARNING: This will clear the current MessageLogContext!
     *
     * @return
     */
    public ClientBuilder enableDatabaseLogging(MessageTypeDefDOEnumInterface messageType, Long objectId)
    {
        this.logToDatabase = true;
        return this;
    }

    public ClientBuilder disableConsoleLogging()
    {
        this.logToConsole = false;
        return this;
    }

    public ClientBuilder setTimeout(Long millis)
    {
        this.timeOutInMillis = millis;
        return this;
    }

    public ClientBuilder setBasicAuthentication(String username, String password)
    {
        this.basicAuthFilter = new BasicAuthenticationFilter(username, password);
        return this;
    }

    public ClientBuilder overrideCorrelationId(String correlationId)
    {
        this.correlationId = correlationId;
        return this;
    }

    public Client build()
    {
        boolean isSecure = remoteURL.toLowerCase().startsWith("https://");
        javax.ws.rs.client.ClientBuilder cb = javax.ws.rs.client.ClientBuilder.newBuilder();
        // ClientBuilder cb = ClientBuilder.newBuilder();
        if (timeOutInMillis != null)
        {
            cb = cb.connectTimeout(timeOutInMillis, TimeUnit.MILLISECONDS).readTimeout(timeOutInMillis,
                            TimeUnit.MILLISECONDS);
        }

        if (isSecure)
        {
            SSLContext ctx;
            try
            {
                ctx = SSLContext.getInstance("TLS");
                ctx.init(null, null, null);
            }
            catch(NoSuchAlgorithmException | KeyManagementException e)
            {
                throw new RuntimeException(e);
            }
            cb = cb.sslContext(ctx);
        }

        Client webClient = cb.build();

        if (logToConsole)
        {
            webClient.register(SLF4JClientLoggingHandler.class);
            webClient.register(SLF4JWriterInterceptor.class);
        }

        if (logToDatabase)
        {
            MessageLogContext.clear();
            webClient.register(DatabaseClientLoggingHandler.class);
            webClient.register(DatabaseClientWriterIntercepter.class);
        }

        if (basicAuthFilter != null)
        {
            webClient.register(basicAuthFilter);
        }

        webClient.register(new ClientCorrelationIdFilter(
                        isNotBlank(correlationId) ? correlationId : UUID.randomUUID().toString()));

        return webClient;

    }

}
