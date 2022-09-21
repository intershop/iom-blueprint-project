package com.intershop.oms.enums.expand;

import bakery.persistence.annotation.ExpandedEnum;
import bakery.persistence.dataobject.job.Job;
import bakery.persistence.dataobject.job.JobDefDO;
import bakery.persistence.expand.JobDefDOEnumInterface;
import bakery.util.StringUtils;
import bakery.util.ejb.EJBHelper;

@ExpandedEnum(JobDefDO.class)
public enum ExpandedJobDefDO implements JobDefDOEnumInterface
{
    /**
     * Start with 10000 to avoid conflict with JobDefDO.
     * The name must be unique across both classes.
     * Values with negative id are meant as syntax example and are ignored (won't get persisted within the database).
     */

    PAYPAL_CHECK_REFUND_JOB(-999, "java:global/example-app/PayPalCheckRefundJob!bakery.persistence.dataobject.job.Job")
    ;

    private String jndiName;
    private Integer id;

    private ExpandedJobDefDO(Integer id, String jndiName)
    {
        this.id = id;
        this.jndiName = jndiName;
    }

    @Override
    public Integer getId()
    {
        return this.id;
    }

    @Override
    public String getName()
    {
        return StringUtils.constantToHungarianNotation(this.name(), StringUtils.FLAG_FIRST_LOWER);
    }

    @Override
    public Job getInstance()
    {
        final EJBHelper ejbHelper = new EJBHelper();
        final Job expectedBean = ejbHelper.getExpectedBean(this.jndiName, Job.class);
        return expectedBean;
    }

    @Override
    public String getJndiName()
    {
        return this.jndiName;
    }
}
