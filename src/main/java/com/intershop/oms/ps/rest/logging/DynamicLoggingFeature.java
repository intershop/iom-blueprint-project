package com.intershop.oms.ps.rest.logging;

import java.util.Arrays;
import java.util.List;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.container.DynamicFeature;
import jakarta.ws.rs.container.ResourceInfo;
import jakarta.ws.rs.core.FeatureContext;
import jakarta.ws.rs.ext.Provider;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.ps.rest.logging.database.DatabaseContainerLoggingHandler;
import com.intershop.oms.ps.rest.logging.database.DatabaseWriterInterceptor.DatabaseServerWriterIntercepter;
import com.intershop.oms.ps.rest.logging.sl4j.SLF4JContainerLoggingHandler;
import com.intershop.oms.ps.rest.logging.sl4j.SLF4JWriterInterceptor;

@Provider
public class DynamicLoggingFeature implements DynamicFeature
{
    /*
     * WHY do we have to register those handlers manually? Because using
     * NameBindings is impossible, we would have to add the annotation to the
     * JaxRS INTERFACE which is GENERATED in some cases. Therefore we have to
     * "configure" (hardcode) the rules for logging in this class.
     */

    // REST services in this package (or subpackages) will not be logged to the
    // database in any case. use this to exclude high traffic services
    public static final List<String> DATABASE_LOGGING_PACKAGE_BLACKLIST = Arrays
                    .asList("com.intershop.oms.example.atp.service");

    private static final Logger log = LoggerFactory.getLogger(DynamicLoggingFeature.class);

    @Override
    public void configure(ResourceInfo resourceInfo, FeatureContext context)
    {
        log.debug("starting for class {}, method: {}", resourceInfo.getResourceClass().getSimpleName(),
                        resourceInfo.getResourceMethod().getName());

        log.debug("adding log file logger to all classes / methods");

        context.register(SLF4JContainerLoggingHandler.class);
        context.register(SLF4JWriterInterceptor.class);

        if (writeToDatabase(resourceInfo))
        {
            log.debug("registering database logging features");
            context.register(DatabaseContainerLoggingHandler.class);
            context.register(DatabaseServerWriterIntercepter.class);
        }
    }

    private boolean writeToDatabase(ResourceInfo resourceInfo)
    {
        // still a hardcoded condition to exclude GET requests from DB logging
        if (resourceInfo.getResourceMethod().getAnnotation(GET.class) != null)
        {
            log.debug("skipping feature, GET request");
            return false;
        }

        if (DATABASE_LOGGING_PACKAGE_BLACKLIST.stream()
                        .anyMatch(prefix -> resourceInfo.getResourceClass().getPackage().getName().startsWith(prefix)))
        {
            log.debug("skipping feature, blacklisted class");
            return false;
        }

        return true;
    }

}
