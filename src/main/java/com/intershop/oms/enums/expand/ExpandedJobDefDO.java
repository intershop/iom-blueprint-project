package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.job.Job;
import bakery.persistence.dataobject.job.JobDefDO;
import bakery.persistence.expand.JobDefDOEnumInterface;
import bakery.util.DeploymentConfig;
import bakery.util.StringUtils;
import bakery.util.ejb.EJBHelper;
import jakarta.persistence.Column;
import jakarta.persistence.Id;
import jakarta.persistence.Transient;

@ExpandedEnum(JobDefDO.class)
public enum ExpandedJobDefDO implements JobDefDOEnumInterface
{
    /**
     * Start with 10000 to avoid conflict with JobDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */

    PAYPAL_CHECK_REFUND_JOB(-9999, "java:global/example-app/PayPalCheckRefundJob!bakery.persistence.dataobject.job.Job", "Check for refunds via Pay Pal")
    ;

    private static final long serialVersionUID = 1;

    private String jndiName;
    private Integer id;
    private String description;

    private ExpandedJobDefDO(Integer id, String jndiName, String description)
    {
        this.id = id;
        this.jndiName = String.format(jndiName, DeploymentConfig.APP_VERSION);
        this.description = description;
    }

    @Override
    @Id
    public Integer getId()
    {
        return id;
    }

    @Override
    @Column(name = "name", length = 50, nullable = false)
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
    @Column(name = "description", nullable = true)
    public String getDescription()
    {
        return description;
    }

    @SuppressWarnings("unused")
    private void setDescription(String description)
    {
        // dummy setter for the needs of hibernate
    }

    @Transient
    @Override
    public Job getInstance()
    {
        final EJBHelper ejbHelper = new EJBHelper();
        final Job expectedBean = ejbHelper.getExpectedBean(jndiName, Job.class);
        return expectedBean;
    }

    @Override
    @Transient
    public String getJndiName()
    {
        return this.jndiName;
    }
    
}
