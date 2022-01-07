package com.intershop.oms.enums.expand;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Transient;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.Configuration;
import bakery.persistence.dataobject.configuration.common.DocumentMapperDefDO;
import bakery.persistence.expand.DocumentMapperDefDOEnumInterface;
import bakery.util.StringUtils;
import bakery.util.ejb.EJBHelper;

@Entity
@Table(name = "`DocumentMapperDefDO`")
@Configuration
@PersistedEnumerationTable(DocumentMapperDefDO.class)
public enum ExpandedDocumentMapperDefDO implements DocumentMapperDefDOEnumInterface
{
    // start with 1000 to avoid conflicts with DocumentMapperDefDO
    // the name must be unique across both classes
    // values with negative id are meant as syntax example and are ignored
    // (won't get persisted within the DB)
    EXAMPLE(-999, "java:global/example-app/ExampleReturnSlipMapperBean", "example document mapper discription")
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

    /**
     * @return Id of the document mapper
     */
    @Override
    @Id
    public Integer getId()
    {
        return this.id;
    }

    /**
     * @param the Id of the document mapper
     */
    protected void setId(Integer id)
    {
        this.id = id;
    }

    @Override
    @Transient
    public String getDescription()
    {
        return this.description;
    }

    /**
     * @return the name of the document mapper
     */
    @Override
    @Column(name = "\"name\"", length = 50, nullable = false)
    public String getName()
    {
        return StringUtils.constantToHungarianNotation(this.name(), true);
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
        return new EJBHelper().getExpectedBean(String.format(this.jndiName, bakery.util.DeploymentConfig.APP_VERSION),
                        type);
    }

}
