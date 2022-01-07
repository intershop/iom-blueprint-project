package com.intershop.oms.ps.services.configuration;

import java.net.URL;
import java.util.Date;

import bakery.persistence.dataobject.configuration.supplier.Shop2SupplierDO;
import bakery.util.exception.ConfigurationException;

public abstract class AbstractConfigurationVO
{
    protected CustomConfigurationDO delegate;

    @SuppressWarnings("unused")
    private AbstractConfigurationVO()
    {
    };

    public AbstractConfigurationVO(CustomConfigurationDO delegate)
    {
        if (delegate == null)
        {
            throw new IllegalArgumentException();
        }

        this.delegate = delegate;
    }

    public Shop2SupplierDO getShop2SupplierDO()
    {
        return delegate.getShop2SupplierDO();
    }

    public Long getId()
    {
        return delegate.getId();
    }

    public String getConfigType()
    {
        return delegate.getConfigType();
    }

    protected String getAttributeValue(String key)
    {
        return delegate.getAttributeValue(key);
    }

    /**
     * @param key
     * @param clazz
     * @throws ConfigurationException
     *             in case the provided key/value can not be mapped to the
     *             supplied datatype.
     * @return
     */
    @SuppressWarnings("unchecked")
    protected <T> T getTypedAttributeValue(String key, Class<T> clazz)
    {
        if (clazz == null || key == null)
        {
            throw new IllegalArgumentException();
        }

        String value = getAttributeValue(key);

        if (clazz.isAssignableFrom(String.class))
        {
            return (T)value;
        }

        if (null == value)
        {
            return null;
        }

        /*
         * In case you extend this, please add a test for the data type to
         * AbstractConfigurationVOTest
         */

        Object ret = null;
        try
        {
            if (clazz.isAssignableFrom(Integer.class))
            {
                ret = Integer.valueOf(value);
            }
            else if (clazz.isAssignableFrom(Long.class))
            {
                ret = Long.parseLong(value);
            }
            else if (clazz.isAssignableFrom(Date.class))
            {
                ret = new Date(Long.parseLong(value));
            }
            else if (clazz.isAssignableFrom(URL.class))
            {
                ret = new URL(value);
            }
        }
        catch(Exception e)
        {
            StringBuilder sb = new StringBuilder();
            sb.append("Wrong datatype found for configuration type ");
            sb.append(delegate.getConfigType());
            sb.append(" / Property key: ");
            sb.append(key);
            sb.append(" / expected type: ");
            sb.append(clazz.getSimpleName());
            sb.append(" / found value: ");
            sb.append(value);

            throw new ConfigurationException(sb.toString(), e);
        }

        return clazz.isInstance(ret) ? clazz.cast(ret) : null;
    }

    @Override
    public boolean equals(Object obj)
    {
        return (null != obj && this.getClass().isAssignableFrom(obj.getClass())
                        && ((AbstractConfigurationVO)obj).hashCode() == this.hashCode());
    }

    @Override
    public int hashCode()
    {
        if (delegate.getId() <= Integer.MAX_VALUE)
        {
            return delegate.getId().intValue();
        }
        // well....
        return super.hashCode();
    }
}
