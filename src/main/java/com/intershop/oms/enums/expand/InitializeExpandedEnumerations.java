package com.intershop.oms.enums.expand;

import java.util.TreeSet;
import java.util.stream.Collectors;

import javax.annotation.PostConstruct;
import javax.ejb.EJB;
import javax.ejb.Singleton;
import javax.ejb.Startup;
import javax.interceptor.InvocationContext;

import org.reflections.Reflections;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.EnumUtil;

@Singleton
@Startup
public class InitializeExpandedEnumerations
{

    @EJB(lookup = EnumUtil.JNDI_NAME)
    private EnumUtil util;

    private static final Logger log = LoggerFactory.getLogger(InitializeExpandedEnumerations.class);

    private static final String[] PACKAGES = { "com.intershop.oms.enums.expand" };

    @PostConstruct
    void init(InvocationContext ctx)
    {
        log.info("InitializeExpandedEnumerations starting");

        Reflections reflections = new Reflections((Object[])PACKAGES);

        TreeSet<Class<?>> annotatedClasses = new TreeSet<>(
                        (c1, c2) -> c1.getSimpleName().compareTo(c2.getSimpleName()));
        annotatedClasses.addAll(reflections.getTypesAnnotatedWith(PersistedEnumerationTable.class));

        log.info(annotatedClasses.stream().map(Class::getSimpleName)
                        .collect(Collectors.joining(",\n", "\nExpanded classes: ", ".")));

        assert annotatedClasses.size() == ExpandEnumerations.DEFDO_COUNT;

        try
        {
            this.util.fillEnumerations(annotatedClasses);
            /**
             * Expanding Enums
             */
            ExpandEnumerations.expand();
        }
        catch(Exception e)
        {
            log.error("There has been an Error during InitializeExpandedEnumerations", e);
        }
        finally
        {
            log.info("InitializeExpandedEnumerations finished");
        }
    }

}
