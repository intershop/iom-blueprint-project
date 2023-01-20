package com.intershop.oms.blueprint.orderrouting;

import java.util.List;

import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import bakery.atp.v2.Atp;
import bakery.logic.service.order.task.OrderSupplierCheckPT;
import bakery.logic.valueobject.ProcessContainer;
import bakery.persistence.dataobject.common.InitiatorDefDO;
import bakery.persistence.dataobject.common.OrderObject;
import bakery.persistence.dataobject.common.OrderPosition;
import bakery.persistence.dataobject.configuration.common.OrderEvaluationDefDO;
import bakery.persistence.dataobject.configuration.shop.ShopDO;
import bakery.persistence.dataobject.configuration.supplier.SupplierDO;
import bakery.persistence.dataobject.configuration.user.UserDO;
import bakery.persistence.dataobject.order.OrderSupplierEvaluationDO;
import bakery.persistence.exception.RequestedNoObjectException;
import bakery.persistence.service.article.atp.AtpPersistenceService;
import bakery.persistence.service.configuration.Shop2SupplierPersistenceService;
import bakery.persistence.service.configuration.ShopPersistenceService;
import bakery.util.exception.DatabaseException;
import bakery.util.exception.NoObjectException;
import bakery.util.exception.TechnicalException;

@Stateless
public class SupplierHasStockCheckPTBean implements OrderSupplierCheckPT
{
    
    private static Logger logger = LoggerFactory.getLogger(SupplierHasStockCheckPTBean.class);

    @EJB(lookup = ShopPersistenceService.PERSISTENCE_SHOPPERSISTENCEBEAN)
    private ShopPersistenceService shopPersistenceService;

    @EJB(lookup = Shop2SupplierPersistenceService.PERSISTENCE_SHOP2SUPPLIERPERSISTENCEBEAN)
    private Shop2SupplierPersistenceService shop2SupplierPersistenceService;

    @EJB(lookup = AtpPersistenceService.PERSISTENCE_ATPPERSISTENCEBEAN)
    private AtpPersistenceService atpPersistenceService;

    @Override
    public boolean isCheckRequired(OrderObject orderObject)
    {
        // always required
        return true;
    }

    @Override
    public ProcessContainer doCheck(ProcessContainer container, boolean isErrorForcesAutomaticCancelation)
    {
        logger.debug("SupplierHasStockCheckPTBean - started for order: {}", container.getObjectId());

        OrderObject orderObject = container.getOrderObject();
        ShopDO shopDO;
       
        try
        {
            shopDO = this.shopPersistenceService.getShopDO(orderObject.getShopRef());
        }
        catch(NoObjectException | DatabaseException e)
        {
            throw new TechnicalException(e);
        }
        
        routePositions(orderObject.getPositionsForDOSE(), shopDO.getId(), container.getUser(), container.getInitiator(), isErrorForcesAutomaticCancelation);

        logger.debug("SupplierHasStockCheckPTBean - finished for order: {}", container.getObjectId());

        return container;
    }
    
    /**
     * Routes positions to a supplier that passed previous evaluations and has stock to deliver.
     * 
     * @param orderPositionList
     * @param shopId
     * @param user
     * @param initiator
     * @param isErrorForcesAutomaticCancelation
     */
    private void routePositions(List<OrderPosition> orderPositionList, Long shopId, UserDO user, InitiatorDefDO initiator, boolean isErrorForcesAutomaticCancelation)
    {
        for (OrderPosition pos : orderPositionList)
        {           
            for (OrderSupplierEvaluationDO eval : pos.getOrderSupplierEvaluationList())
            {
                if(eval.getOrderEvaluationDefDO().equals(OrderEvaluationDefDO.SUCCESS)  // passed previous rules
                   &&
                   supplierCanDeliver(shopId, pos, eval.getSupplierDO()))               // has stock
                {
                    // supplier can deliver -> still OrderEvaluationDefDO.SUCCESS
                }
                else
                {
                    // supplier has NO stock
                    // order should be canceled 
                    if(isErrorForcesAutomaticCancelation)
                    {
                        eval.setOrderEvaluationDefDO(OrderEvaluationDefDO.CANCEL);    
                    }
                    // order should NOT be canceled
                    else
                    {
                        eval.setOrderEvaluationDefDO(OrderEvaluationDefDO.ERROR);    
                    }                    
                }
            }
        }  
    }
            
    /**
     * Whether the given supplier can deliver by quantity the given position or not.
     * 
     * @param shopID
     * @param pos
     * @param supplier
     * @return
     */
    private boolean supplierCanDeliver(Long shopId, OrderPosition pos, SupplierDO supplier)
    {
        try
        {
            List<Atp> atpList = atpPersistenceService.getAtp(shopId, pos.getShopArticleNo(), null, null);

            Atp atp = atpList.stream().filter(current -> current.getLocation().equals(supplier.getName())).findAny().orElse(null);
            if (atp != null && atp.getAtp() >= pos.getQuantityOrdered())
            {
                return true;
            }
        }
        catch(DatabaseException | RequestedNoObjectException e)
        {
            logger.error("Couldn't get atp for product {} for shop {}.", pos.getShopArticleNo(), shopId);
        }

        return false;
    }
    
}
