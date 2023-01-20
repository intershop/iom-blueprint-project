package com.intershop.oms.ps.services.configuration;

import java.util.HashMap;
import java.util.Map;

import jakarta.persistence.Access;
import jakarta.persistence.AccessType;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapKeyColumn;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;

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
