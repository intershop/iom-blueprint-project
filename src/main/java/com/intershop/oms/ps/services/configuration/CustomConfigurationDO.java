package com.intershop.oms.ps.services.configuration;

import java.util.HashMap;
import java.util.Map;

import javax.persistence.Access;
import javax.persistence.AccessType;
import javax.persistence.CollectionTable;
import javax.persistence.Column;
import javax.persistence.ElementCollection;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.MapKeyColumn;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import bakery.persistence.dataobject.configuration.supplier.Shop2SupplierDO;
import bakery.util.IdOwner;

@Entity
@Table(name = "\"CustomConfigurationDO\"", schema = "oms")
@Access(AccessType.PROPERTY)
@SequenceGenerator(name = "CustomConfigurationDOIdGenerator", sequenceName = "\"CustomConfigurationDO_id_seq\"", initialValue = 1, allocationSize = 1)
public class CustomConfigurationDO implements IdOwner<Long>
{

    private Long id;
    private Shop2SupplierDO shop2SupplierDO;
    private String configType;

    @Access(AccessType.FIELD)
    @ElementCollection(fetch = FetchType.EAGER)
    @MapKeyColumn(name = "\"key\"", nullable = false, insertable = false, updatable = false)
    @CollectionTable(schema = "oms", name = "\"CustomConfigurationDO_AV\"", joinColumns = @JoinColumn(name = "\"customConfigurationRef\"", nullable = false, insertable = false, updatable = false))
    @Column(name = "\"value\"", nullable = false, insertable = false, updatable = false)
    private Map<String, String> attributes = new HashMap<>();

    @Override
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "CustomConfigurationDOIdGenerator")
    public Long getId()
    {
        return id;
    }

    protected void setId(Long id)
    {
        this.id = id;
    }

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "\"shop2SupplierRef\"")
    public Shop2SupplierDO getShop2SupplierDO()
    {
        return shop2SupplierDO;
    }

    public void setShop2SupplierDO(Shop2SupplierDO shop2SupplierDO)
    {
        this.shop2SupplierDO = shop2SupplierDO;
    }

    @Column(name = "\"configType\"", nullable = false)
    public String getConfigType()
    {
        return configType;
    }

    public void setConfigType(String atpType)
    {
        this.configType = atpType;
    }

    public String getAttributeValue(String key)
    {
        return attributes.get(key);
    }
}
