package com.intershop.oms.ps.services.configuration;

import java.util.List;

import javax.ejb.Local;

@Local
public interface ConfigurationLogicService
{
    public <T extends AbstractConfigurationVO> T getTypedConfigurationDO(Class<T> type, Long shopRef, Long supplierRef);

    public <T extends AbstractConfigurationVO> List<T> getTypedConfigurationDOList(Class<T> type, Long shopRef,
                    Long supplierRef);

    public void resetCache();

}
