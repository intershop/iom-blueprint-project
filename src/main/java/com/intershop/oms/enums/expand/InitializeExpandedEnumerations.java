package com.intershop.oms.enums.expand;

import javax.annotation.PostConstruct;
import javax.ejb.EJB;
import javax.ejb.Singleton;
import javax.ejb.Startup;

import bakery.persistence.dataobject.EnumUtil;
import bakery.persistence.expand.EnumInitializer;

@Singleton
@Startup
public class InitializeExpandedEnumerations extends EnumInitializer
{
    // packages to scan for enumerations
    private static final Object[] PACKAGES = { "com.intershop.oms.enums.expand" };

    @EJB(lookup = EnumUtil.JNDI_NAME)
    private EnumUtil util;

    @PostConstruct
    public void init()
    {
        util.registerEnumerations(getExpandedEnums(PACKAGES));
    }
}