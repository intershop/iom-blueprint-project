package com.intershop.oms.blueprint.approval;

import javax.ejb.Stateless;
import javax.ejb.TransactionAttribute;
import javax.ejb.TransactionAttributeType;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.blueprint.BlueprintConstants;

import bakery.logic.service.util.AbstractExecutionDecider;
import bakery.persistence.dataobject.configuration.common.ApprovalTypeDefDO;
import bakery.persistence.dataobject.configuration.supplier.Shop2Supplier2ApprovalTypeDefDO;
import bakery.persistence.dataobject.rma.ReturnAnnouncementDO;
import bakery.persistence.dataobject.rma.ReturnAnnouncementPropertyDO;

@Stateless
@TransactionAttribute(TransactionAttributeType.SUPPORTS)
public class RmaApprovalDecisionBean extends AbstractExecutionDecider<Shop2Supplier2ApprovalTypeDefDO>
{
    private Logger log = LoggerFactory.getLogger(RmaApprovalDecisionBean.class);
    
    @Override
    public boolean isExecutionRequired(ReturnAnnouncementDO returnAnnouncementDO, Shop2Supplier2ApprovalTypeDefDO shop2Supplier2ApprovalTypeDefDO)
    {
        // prevent from being executed by another type than ApprovalTypeDefDO.RETURN_ANNOUNCEMENT
        if (!shop2Supplier2ApprovalTypeDefDO.getApprovalTypeDefDO().equals(ApprovalTypeDefDO.RETURN_ANNOUNCEMENT))
        {
            return false;
        }
        
        // check if custom property is given to skip approval
        String value = returnAnnouncementDO.getPropertyValue(ReturnAnnouncementPropertyDO.DEFAULT_GROUP, BlueprintConstants.PROPERTY_APPROVAL);
        if ((value != null) && value.equals(BlueprintConstants.PROPERTY_VALUE_FALSE))
        {
            log.debug(
                    "Skipping rma approval, because custom return announcement property group|key|value = "
                            + String.format("%s|%s|%s",
                                    ReturnAnnouncementPropertyDO.DEFAULT_GROUP,
                                    BlueprintConstants.PROPERTY_APPROVAL,
                                    BlueprintConstants.PROPERTY_VALUE_FALSE)
                            + " found.");
            return false;   // skip
        }
        
        return true; // approval        
    }

}
