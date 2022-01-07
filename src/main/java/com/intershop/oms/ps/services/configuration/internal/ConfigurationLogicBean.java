package com.intershop.oms.ps.services.configuration.internal;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;
import javax.ejb.Lock;
import javax.ejb.LockType;
import javax.ejb.Singleton;
import javax.ejb.Startup;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import org.reflections.Reflections;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.collect.BiMap;
import com.google.common.collect.HashBiMap;
import com.intershop.oms.ps.services.configuration.AbstractConfigurationVO;
import com.intershop.oms.ps.services.configuration.ConfigurationLogicService;
import com.intershop.oms.ps.services.configuration.CustomConfiguration;
import com.intershop.oms.ps.services.configuration.CustomConfigurationDO;

import bakery.util.exception.ConfigurationException;

@Singleton
@Startup
@Lock(LockType.READ)
public class ConfigurationLogicBean implements ConfigurationLogicService
{
    private Map<String, List<? extends AbstractConfigurationVO>> shopTypeConfig;
    private Map<String, List<? extends AbstractConfigurationVO>> supplierTypeConfig;
    private Map<String, List<? extends AbstractConfigurationVO>> shopSupplierTypeConfig;
    private BiMap<String, Class<? extends AbstractConfigurationVO>> configTypeMap = HashBiMap.create();

    @PersistenceContext
    private EntityManager em;

    private static final Logger log = LoggerFactory.getLogger(ConfigurationLogicBean.class);

    @PostConstruct
    public void init()
    {
        Reflections reflections = new Reflections("com.intershop.oms");

        List<Class<? extends AbstractConfigurationVO>> classes = new ArrayList<>();
        classes.addAll(reflections.getSubTypesOf(AbstractConfigurationVO.class));

        for (Class<? extends AbstractConfigurationVO> clazz : classes)
        {
            CustomConfiguration customConfiguration = clazz.getAnnotation(CustomConfiguration.class);
            if (customConfiguration == null)
            {
                log.warn("found subclass of AbstractConfigurationVO without CustomConfiguration annotation - ignoring: "
                                + clazz.getCanonicalName());
                continue;
            }

            log.debug("registering config type: " + clazz.getCanonicalName());
            configTypeMap.put(customConfiguration.identifier(), clazz);
        }

    }

    @Override
    public <T extends AbstractConfigurationVO> T getTypedConfigurationDO(Class<T> type, Long shopRef, Long supplierRef)
    {
        List<T> configDOs = getConfigDOs(type, shopRef, supplierRef);
        if (configDOs.size() > 1)
        {
            throw new ConfigurationException(
                            "there may not be more than one CustomConfigurationDO for a specific shop/supplier/type combination: "
                                            + shopRef + " / " + supplierRef + " / " + type.getTypeName());
        }

        else if (configDOs.isEmpty())
        {
            return null;
        }

        return configDOs.get(0);
    }

    @Override
    public <T extends AbstractConfigurationVO> List<T> getTypedConfigurationDOList(Class<T> type, Long shopRef,
                    Long supplierRef)
    {
        return getConfigDOs(type, shopRef, supplierRef);
    }

    @SuppressWarnings("unchecked")
    private <T extends AbstractConfigurationVO> List<T> getConfigDOs(Class<T> type, Long shopRef, Long supplierRef)
    {
        List<? extends AbstractConfigurationVO> configs;
        String typeName = configTypeMap.inverse().get(type);
        if (shopRef == null)
        {
            configs = supplierTypeConfig.get(supplierRef.toString() + "_" + typeName);
        }
        else if (supplierRef == null)
        {
            configs = shopTypeConfig.get(shopRef.toString() + "_" + typeName);
        }
        else
        {
            configs = shopSupplierTypeConfig.get(shopRef.toString() + "_" + supplierRef.toString() + "_" + typeName);
        }

        return configs == null ? new ArrayList<>() : (ArrayList<T>)configs;

    }

    @Override
    @Lock(LockType.WRITE)
    public void resetCache()
    {
        log.debug("Starting cache refresh");

        List<CustomConfigurationDO> configs = em.createQuery("FROM CustomConfigurationDO", CustomConfigurationDO.class)
                        .getResultList();

        shopTypeConfig = new HashMap<>();
        supplierTypeConfig = new HashMap<>();
        shopSupplierTypeConfig = new HashMap<>();

        for (CustomConfigurationDO configDO : configs)
        {
            AbstractConfigurationVO configVO = mapConfigDO(configDO);
            if (configVO == null)
            {
                continue;
            }
            upsert(shopTypeConfig, configDO.getShop2SupplierDO().getShopDO().getId().toString(), configVO);
            upsert(supplierTypeConfig, configDO.getShop2SupplierDO().getSupplierDO().getId().toString(), configVO);
            upsert(shopSupplierTypeConfig,
                            configDO.getShop2SupplierDO().getShopDO().getId().toString() + "_"
                                            + configDO.getShop2SupplierDO().getSupplierDO().getId().toString(),
                            configVO);
        }

        log.debug("Finished cache refresh with #entries: " + configs.size());
    }

    private <T extends AbstractConfigurationVO> void upsert(Map<String, List<? extends AbstractConfigurationVO>> map,
                    String keyprefix, T config)
    {
        @SuppressWarnings("unchecked")
        List<T> list = (List<T>)map.get(keyprefix + "_" + config.getConfigType());
        if (list == null)
        {
            list = new ArrayList<>();
            map.put(keyprefix + "_" + config.getConfigType(), list);
        }

        list.add(config);
    }

    @SuppressWarnings("unchecked")
    private <T extends AbstractConfigurationVO> T mapConfigDO(CustomConfigurationDO config)
    {
        Class<? extends AbstractConfigurationVO> configClazz = configTypeMap.get(config.getConfigType());
        if (configClazz == null)
        {
            log.warn("found config with unknown config type: " + config.getConfigType());
            return null;
        }
        try
        {
            return (T)configClazz.getDeclaredConstructor(CustomConfigurationDO.class).newInstance(config);
        }
        catch(InstantiationException | IllegalAccessException | IllegalArgumentException | InvocationTargetException
                        | NoSuchMethodException | SecurityException e)
        {
            log.error("", e);
            return null;
        }
    }

}
