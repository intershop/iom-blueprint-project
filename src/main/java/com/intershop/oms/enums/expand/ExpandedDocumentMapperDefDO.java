package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.configuration.common.DocumentMapperDefDO;
import bakery.persistence.expand.DocumentMapperDefDOEnumInterface;
import bakery.util.StringUtils;
import bakery.util.ejb.EJBHelper;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Transient;

@ExpandedEnum(DocumentMapperDefDO.class)
public enum ExpandedDocumentMapperDefDO implements DocumentMapperDefDOEnumInterface
{

    /**
     * Start with 10000 to avoid conflict with DocumentMapperDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */
    EXAMPLE(-9999, "java:global/example-app/ExampleReturnSlipMapperBean", "example document mapper discription")
    ;

    private Integer id;
    private String jndiName;
    private String description;

    private ExpandedDocumentMapperDefDO(Integer id, String jndiName, String description)
    {
        this.id = id;
        this.jndiName = jndiName;
        this.description = description;
    }

    @Override
    @Id
    public Integer getId()
    {
        return id;
    }

    protected void setId(Integer id)
    {
        this.id = id;
    }

    @Override
    @Transient
    public String getDescription()
    {
        return description;
    }

    @Override
    @Column(name = "\"name\"", length = 50, nullable = false)
    public String getName()
    {
        return StringUtils.constantToHungarianNotation(name(), StringUtils.FLAG_FIRST_LOWER);
    }

    @SuppressWarnings("unused")
    private void setName(String name)
    {
        // dummy setter for the needs of hibernate
    }

    @Override
    @Transient
    public <T> T getDocumentMapper(Class<T> type)
    {
        return new EJBHelper().getExpectedBean(String.format(jndiName, bakery.util.DeploymentConfig.APP_VERSION), type);
    }
    
}