package com.intershop.oms.enums.expand;

import java.util.EnumSet;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.article.export.ArticleExportConfigBeanDefDO;
import bakery.persistence.dataobject.transformer.EnumInterface;
import bakery.util.DeploymentConfig;
import bakery.util.StringUtils;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Transient;

@ExpandedEnum(ArticleExportConfigBeanDefDO.class)
public enum ExpandedArticleExportConfigBeanDefDO implements EnumInterface
{

    /**
     * Start with 10000 to avoid conflict with ArticleExportConfigBeanDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */
    EXAMPLE(-9999, "java:global/example-app/ExampleExportCSVBean");

    private Integer id;
    private String jndiName;

    private ExpandedArticleExportConfigBeanDefDO( Integer id, String jndiName )
    {
        this.id = id;
        this.jndiName = String.format( jndiName, DeploymentConfig.APP_VERSION );
    }

    @Override
    @Id
    public Integer getId()
    {
        return id;
    }

    @Override
    @Column( name = "`description`" )
    public String getName()
    {
        return StringUtils.constantToHungarianNotation(name(), StringUtils.FLAG_FIRST_LOWER );
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return jndiName;
    }

    /**
     * get list of expanded enums
     * @return
     */
    @Transient
    public final EnumSet<ExpandedArticleExportConfigBeanDefDO> getExpandedEnums()
    {
        return EnumSet.allOf( ExpandedArticleExportConfigBeanDefDO.class );
    }

    /**
     * get list of all enums
     * @return
     */
    @Transient
    public final EnumSet<ArticleExportConfigBeanDefDO> getAllEnums()
    {
        return EnumSet.allOf( ArticleExportConfigBeanDefDO.class );
    }
    
}