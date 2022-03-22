package com.intershop.oms.blueprint.orderrouting;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.ejb.EJB;
import javax.ejb.Stateless;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import bakery.atp.v2.Atp;
import bakery.logic.service.order.task.OrderSupplierCheckPT;
import bakery.logic.valueobject.ProcessContainer;
import bakery.persistence.dataobject.common.InitiatorDefDO;
import bakery.persistence.dataobject.common.OrderObject;
import bakery.persistence.dataobject.common.OrderPosition;
import bakery.persistence.dataobject.common.PaymentDefDO;
import bakery.persistence.dataobject.configuration.common.OrderEvaluationDefDO;
import bakery.persistence.dataobject.configuration.shop.ShopDO;
import bakery.persistence.dataobject.configuration.states.OrderSupplierEvaluationStatesDefDO;
import bakery.persistence.dataobject.configuration.supplier.PreferredSupplierDO;
import bakery.persistence.dataobject.configuration.supplier.SupplierDO;
import bakery.persistence.dataobject.configuration.user.UserDO;
import bakery.persistence.dataobject.order.OrderSupplierEvaluationDO;
import bakery.persistence.exception.RequestedNoObjectException;
import bakery.persistence.service.article.atp.AtpPersistenceService;
import bakery.persistence.service.configuration.Shop2SupplierPersistenceService;
import bakery.persistence.service.configuration.ShopPersistenceService;
import bakery.persistence.states.controller.InvalidStateTransitionException;
import bakery.util.exception.DatabaseException;
import bakery.util.exception.NoObjectException;
import bakery.util.exception.TechnicalException;

@Stateless
public class OneSupplierOnlyRoutingRulePTBean implements OrderSupplierCheckPT
{
    
    private static Logger logger = LoggerFactory.getLogger(OneSupplierOnlyRoutingRulePTBean.class);

    @EJB(lookup = ShopPersistenceService.PERSISTENCE_SHOPPERSISTENCEBEAN)
    private ShopPersistenceService shopPersistenceService;

    @EJB(lookup = Shop2SupplierPersistenceService.PERSISTENCE_SHOP2SUPPLIERPERSISTENCEBEAN)
    private Shop2SupplierPersistenceService shop2SupplierPersistenceService;

    @EJB(lookup = AtpPersistenceService.PERSISTENCE_ATPPERSISTENCEBEAN)
    private AtpPersistenceService atpPersistenceService;

    @Override
    public boolean isCheckRequired(OrderObject orderObject)
    {
        ShopDO shopDO;
        try
        {
            shopDO = this.shopPersistenceService.getShopDO(orderObject.getShopRef());
        }
        catch(NoObjectException | DatabaseException e)
        {
            throw new TechnicalException(e);
        }
        
        // This also can be configured by assigning rules to selected shops only
        if (shopDO.isB2B())
        {
            logger.debug("OneSupplierOnlyRoutingRulePTBean - check is not required for B2B.");
            return false;
        }
        else
        {
            logger.debug("OneSupplierOnlyRoutingRulePTBean - check is required for B2C.");
            return true;   
        }
    }

    /**
     * Only one supplier should deliver all positions of the order.
     */
    @Override
    public ProcessContainer doCheck(ProcessContainer container, boolean isErrorForcesAutomaticCancelation)
    {
        logger.debug("OneSupplierOnlyRoutingRulePTBean - started for order: {}", container.getObjectId());

        OrderObject orderObject = container.getOrderObject();
        ShopDO shopDO;
        // must consider COD, as the core rule will be checked later and can't overwrite selected suppliers of this rule
        boolean requiresCOD = orderObject.getPaymentDefDO().equals(PaymentDefDO.CASH_ON_DELIVERY) ? true : false;
        try
        {
            shopDO = this.shopPersistenceService.getShopDO(orderObject.getShopRef());
        }
        catch(NoObjectException | DatabaseException e)
        {
            throw new TechnicalException(e);
        }

        List<OrderPosition> orderPositionList = orderObject.getPositionsForDOSE();
        List<Long> rankedSuppliers = getSupplierRankingForShop(shopDO);
        Long selectedSupplierID = selectSupplier(shopDO.getId(), orderPositionList, rankedSuppliers, requiresCOD);
        updateEvalDOsWithSelectedSupplier(orderPositionList, selectedSupplierID, container.getUser(), container.getInitiator());

        logger.debug("OneSupplierOnlyRoutingRulePTBean - finished for order: {}", container.getObjectId());

        return container;
    }

    /**
     * Returns a 'ranked' list of suppliers of the shop. Preferred first if configured.
     * @param shopDO
     * @param requiresCOD
     * @return
     */
    private List<Long> getSupplierRankingForShop(ShopDO shopDO)
    {
        try
        {
            List<Long> rankedSuppliers = new ArrayList<>();
            List<PreferredSupplierDO> preferredSupplierList = this.shop2SupplierPersistenceService.getPreferredSupplierIds(shopDO.getId(), null, null);
            if (preferredSupplierList == null || preferredSupplierList.isEmpty())
            {
                throw new TechnicalException("No preferred suppliers defined for shop " + shopDO.getName());
            }

            for (PreferredSupplierDO preferred : preferredSupplierList)
            {
                Long supplierID = preferred.getShop2SupplierSupplierRef();
                rankedSuppliers.add(supplierID);
            }

            return rankedSuppliers;
        }
        catch(DatabaseException ex)
        {
            throw new TechnicalException(ex);
        }
    }

    /**
     * Returns the id of the selected supplier. Fallback is the highest ranked.
     * @param shopID
     * @param orderPositionList
     * @param rankedSuppliers
     * @return
     */
    private Long selectSupplier(Long shopID, List<OrderPosition> orderPositionList, List<Long> rankedSuppliers, boolean requiresCOD)
    {
        for (Long supplierID : rankedSuppliers)
        {
            Map<OrderPosition, Boolean> posCanBeFulfilledBySupplier = new HashMap<>();
            for (OrderPosition pos : orderPositionList)
            {
                List<OrderSupplierEvaluationDO> evalList = pos.getOrderSupplierEvaluationList();

                boolean supplierCanFulfill = evalList.stream()
                                .anyMatch(eval -> (eval.getSupplierDO().getId().compareTo(supplierID) == 0)
                                                && supplierCanDeliver(shopID, pos, eval.getSupplierDO()));
                posCanBeFulfilledBySupplier.put(pos, supplierCanFulfill);
            }

            if (posCanBeFulfilledBySupplier.values().stream().noneMatch(value -> value.equals(Boolean.FALSE)))
            {
                return supplierID;
            }
        }

        // return the highest ranked supplier as fallback
        return rankedSuppliers.get(0);
    }

    /**
     * Whether the given supplier can deliver (quantity) the given position or not.
     * @param shopID
     * @param pos
     * @param supplier
     * @return
     */
    private boolean supplierCanDeliver(Long shopID, OrderPosition pos, SupplierDO supplier)
    {
        try
        {
            List<Atp> atpList = atpPersistenceService.getAtp(shopID, pos.getShopArticleNo(), null, null);

            Atp atp = atpList.stream().filter(current -> current.getLocation().equals(supplier.getName())).findAny().orElse(null);
            if (atp != null && atp.getAtp() >= pos.getQuantityOrdered())
            {
                return true;
            }
        }
        catch(DatabaseException | RequestedNoObjectException e)
        {
            logger.error("Couldn't get atp for product {} for shop {}.", pos.getShopArticleNo(), shopID);
        }

        return false;
    }

    /**
     * Updates the selected suppliers.
     * @param orderPositionList
     * @param selectedSupplierID
     * @param user
     * @param initiator
     */
    private void updateEvalDOsWithSelectedSupplier(List<OrderPosition> orderPositionList, Long selectedSupplierID, UserDO user, InitiatorDefDO initiator)
    {
        for (OrderPosition pos : orderPositionList)
        {
            List<OrderSupplierEvaluationDO> evalList = pos.getOrderSupplierEvaluationList();

            for (OrderSupplierEvaluationDO eval : evalList)
            {
                if (eval.getSupplierDO().getId().compareTo(selectedSupplierID) != 0)
                {
                    try
                    {
                        eval.setOrderEvaluationDefDO(OrderEvaluationDefDO.UNSUCCESS);
                        eval.setState(OrderSupplierEvaluationStatesDefDO.STATE_FINISHED, user, initiator);
                    }
                    catch(InvalidStateTransitionException e)
                    {
                        throw new TechnicalException(e);
                    }
                }
                else
                {
                    eval.setOrderEvaluationDefDO(OrderEvaluationDefDO.SUCCESS);
                }
            }
        }
    }
    
}
