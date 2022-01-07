package com.intershop.oms.ps.ordervalidation;

import static org.apache.commons.lang3.StringUtils.isBlank;

import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import javax.ejb.EJB;
import javax.ejb.Stateless;
import javax.ejb.TransactionAttribute;
import javax.ejb.TransactionAttributeType;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import bakery.logic.service.configuration.PaymentProviderLogicService;
import bakery.logic.service.configuration.ShopLogicService;
import bakery.logic.service.exception.MissingFieldException;
import bakery.logic.service.order.task.ValidateOrderPT;
import bakery.logic.valueobject.ProcessContainer;
import bakery.persistence.dataobject.order.OrderDO;
import bakery.persistence.dataobject.order.OrderPosDO;
import bakery.persistence.util.ErrorTextFormatter;
import bakery.util.exception.DatabaseException;
import bakery.util.exception.ModifiedObjectException;
import bakery.util.exception.NoObjectException;
import bakery.util.exception.TechnicalException;
import bakery.util.exception.ValidationException;

@Stateless
@TransactionAttribute(TransactionAttributeType.REQUIRED)
public class ValidateMandatoryPropertiesPTBean implements ValidateOrderPT
{
    @EJB(lookup = PaymentProviderLogicService.LOGIC_PAYMENTPROVIDERLOGICBEAN)
    private PaymentProviderLogicService paymentProviderLogicService;

    @EJB(lookup = ShopLogicService.LOGIC_SHOPLOGICBEAN)
    private ShopLogicService shopLogicService;

    private Logger log = LoggerFactory.getLogger(ValidateMandatoryPropertiesPTBean.class);

    public static final Map<String, String> MANDATORY_POSITION_PROPERTIES;
    public static final Map<String, String> MANDATORY_ORDER_PROPERTIES;

    static
    {
        MANDATORY_POSITION_PROPERTIES = new HashMap<>();
        MANDATORY_ORDER_PROPERTIES = new HashMap<>();

    }

    @Override
    public ProcessContainer execute(ProcessContainer processContainer)
                    throws ValidationException, NoObjectException, DatabaseException, ModifiedObjectException
    {
        OrderDO orderDO = processContainer.getOrderDO();

        if (null == orderDO)
        {
            log.error("can't find order object in process container");
            throw new TechnicalException(OrderDO.class, "OrderDO in processcontainer is null");
        }

        ValidationException validationException = new ValidationException(orderDO);

        for (Entry<String, String> propertyGroupKey : MANDATORY_ORDER_PROPERTIES.entrySet())
        {
            if (isBlank(orderDO.getPropertyValue(propertyGroupKey.getKey(), propertyGroupKey.getValue())))
            {
                MissingFieldException mfe = new MissingFieldException("GROUP: [" + propertyGroupKey.getKey()
                                + "] KEY: [" + propertyGroupKey.getValue() + "]");
                validationException.getExceptionList().add(mfe);
            }
        }

        for (OrderPosDO orderPos : orderDO.getOrderPosDOList())
        {
            ValidationException positionValidationException = new ValidationException(orderPos);
            for (Entry<String, String> propertyGroupKey : MANDATORY_POSITION_PROPERTIES.entrySet())
            {
                if (isBlank(orderPos.getPropertyValue(propertyGroupKey.getKey(), propertyGroupKey.getValue())))
                {
                    MissingFieldException mfe = new MissingFieldException("GROUP: [" + propertyGroupKey.getKey()
                                    + "] KEY: [" + propertyGroupKey.getValue() + "]");
                    positionValidationException.getExceptionList().add(mfe);
                }
            }

            if (positionValidationException.hasExceptions())
            {
                validationException.getExceptionList().add(positionValidationException);
            }

            // add other properties here

        }

        if (validationException.hasExceptions())
        {
            log.error("Order is missing mandatory properties: " + orderDO.getShopOrderNo());
            orderDO.addErrorText(ErrorTextFormatter.formattingErrorText(validationException));
            throw validationException;
        }

        return processContainer;
    }


}
