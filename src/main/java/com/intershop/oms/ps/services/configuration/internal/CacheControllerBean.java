package com.intershop.oms.ps.services.configuration.internal;

import java.sql.Timestamp;

import javax.annotation.PostConstruct;
import javax.ejb.EJB;
import javax.ejb.Schedule;
import javax.ejb.Singleton;
import javax.ejb.Startup;

import com.intershop.oms.ps.services.configuration.ConfigurationLogicService;

import bakery.persistence.service.configuration.ApplicationPersistenceService;

/**
 * Scheduled Controller that validates / resets custom (singleton) caches.
 *
 * @author PBorchert
 *
 */
@Singleton
@Startup
public class CacheControllerBean
{
    @EJB
    private ConfigurationLogicService configurationLogicService;

    @EJB(lookup = ApplicationPersistenceService.PERSISTENCE_APPLICATIONPERSISTENCEBEAN)
    private ApplicationPersistenceService applicationPersistenceService;

    private Timestamp lastConfigDate;

    /**
     * After the Singleton has been loaded, the managed caches are filled + the
     * cache timestamp is updated.
     */
    @PostConstruct
    public void init()
    {
        lastConfigDate = applicationPersistenceService.getPlatformCongfigDOLastConfigDate();
        configurationLogicService.resetCache();
    }

    /**
     * Checks the lastConfigDate of the PlatformConfigDO and triggers a cache
     * reset if required.
     */
    @Schedule(persistent = false, hour = "*", minute = "*/1", second = "10")
    public void checkCacheState()
    {
        Timestamp lastConfigDateDB = applicationPersistenceService.getPlatformCongfigDOLastConfigDate();
        if (lastConfigDate.equals(lastConfigDateDB))
        {
            return;
        }

        configurationLogicService.resetCache();
        lastConfigDate = lastConfigDateDB;
    }

}
