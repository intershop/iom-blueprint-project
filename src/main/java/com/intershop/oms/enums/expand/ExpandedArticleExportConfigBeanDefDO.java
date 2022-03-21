package com.intershop.oms.enums.expand;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Transient;

import bakery.persistence.annotation.PersistedEnumerationTable;
import bakery.persistence.dataobject.article.export.ArticleExportConfigBeanDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.StringUtils;

@PersistedEnumerationTable(ArticleExportConfigBeanDefDO.class)
public enum ExpandedArticleExportConfigBeanDefDO implements EnumInterface
{

    /**
     * Start with 10000 to avoid conflict with ArticleExportConfigBeanDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */
    EXAMPLE(-999, "java:global/example-app/example-ejb/ExampleExportCSVBean");

    private Integer id;
    private String jndiName;

    private ExpandedArticleExportConfigBeanDefDO(Integer id, String jndiName)
    {
        this.id = id;
        this.jndiName = jndiName;
    }

    @Override
    @Id
    public Integer getId()
    {
        return this.id;
    }

    @Override
    @Column(name = "`description`")
    public String getName()
    {
        return StringUtils.constantToHungarianNotation(this.name(), StringUtils.FLAG_FIRST_LOWER);
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return this.jndiName;
    }

}
