package com.intershop.oms.blueprint.ordervalidation;

import jakarta.ejb.Stateless;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import bakery.logic.service.exception.IncorrectValueException;
import bakery.logic.service.order.task.ValidateOrderPT;
import bakery.logic.valueobject.ProcessContainer;
import bakery.persistence.dataobject.order.OrderDO;
import bakery.persistence.util.ErrorTextFormatter;
import bakery.util.exception.BakeryValidationException;
import bakery.util.exception.DatabaseException;
import bakery.util.exception.ModifiedObjectException;
import bakery.util.exception.NoObjectException;
import bakery.util.exception.TechnicalException;
import bakery.util.exception.ValidationException;

/**
 * Validation fails if custom order level property is given as group|key|value = order|validation|fail
 */
@Stateless
public class ValidateCustomOrderPropertiesPTBean implements ValidateOrderPT
{
    private Logger log = LoggerFactory.getLogger(ValidateCustomOrderPropertiesPTBean.class);

    private static final String GROUP   = "order";
    private static final String KEY     = "validation";
    private static final String VALUE   = "fail";

    @Override
    public ProcessContainer execute(ProcessContainer container) throws ValidationException, NoObjectException, DatabaseException, ModifiedObjectException
    {
        OrderDO orderDO = container.getOrderDO();

        if (null == orderDO)
        {
            log.error("Can't find order object in process container");
            throw new TechnicalException(OrderDO.class, "OrderDO in process container is null");
        }

        String value = orderDO.getPropertyValue(GROUP, KEY);
        if ((value != null) && value.equals(VALUE))
        {
            ValidationException validationException = new ValidationException(orderDO,
                            new BakeryValidationException[] { new IncorrectValueException(
                                            "Custom order property group|key|value", String.format("%s|%s|%s", GROUP, KEY, VALUE) )});

            orderDO.addErrorText(ErrorTextFormatter.formattingErrorText(validationException));
            throw validationException;
        }

        return container;
    }

}
