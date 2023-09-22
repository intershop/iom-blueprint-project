package com.intershop.oms.blueprint.opentrans;

import bakery.logic.communication.mapper.MapperUtil;
import bakery.logic.service.configuration.ShopLogicService;
import bakery.logic.service.exception.IncorrectValueException;
import bakery.logic.service.exception.InvalidReferenceException;
import bakery.logic.service.exception.MissingFieldException;
import bakery.logic.service.order.DispatchLogicService;
import bakery.persistence.dataobject.common.InitiatorDefDO;
import bakery.persistence.dataobject.configuration.shop.CarrierDO;
import bakery.persistence.dataobject.configuration.shop.ShopDO;
import bakery.persistence.dataobject.configuration.supplier.Supplier2CarrierDO;
import bakery.persistence.dataobject.configuration.supplier.SupplierDO;
import bakery.persistence.dataobject.configuration.user.UserDO;
import bakery.persistence.dataobject.order.DispatchDO;
import bakery.persistence.dataobject.order.DispatchPosDO;
import bakery.persistence.dataobject.order.OrderDO;
import bakery.persistence.dataobject.order.OrderPosDO;
import bakery.persistence.service.order.OrderPersistenceService;
import bakery.persistence.states.controller.InvalidStateTransitionException;
import bakery.util.exception.BakeryValidationException;
import bakery.util.exception.DatabaseException;
import bakery.util.exception.DuplicateObjectException;
import bakery.util.exception.NoObjectException;
import bakery.util.exception.ValidationException;
import com.intershop.oms.rolemgmt.capi.OMSRuntimeException;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import org.opentrans.xmlschema._2.DISPATCHNOTIFICATION;
import org.opentrans.xmlschema._2.DISPATCHNOTIFICATIONITEM;
import org.opentrans.xmlschema._2.PACKAGE;
import org.opentrans.xmlschema._2.PACKAGEID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static org.apache.commons.lang3.StringUtils.isBlank;

@Stateless
@TransactionAttribute(TransactionAttributeType.REQUIRED)
public class OpenTransDeliveryMessageBean
{

    private static final String TRACKING_LINE = "TrackingLine";
    protected static final String CARRIER_SPECIFIC_PACKAGE_ID = "deliverer_specific";
    private static final String SDF_STR_OPENTRANS_ISO8601 = "yyyy-MM-dd";

    @EJB(lookup = DispatchLogicService.LOGIC_DISPATCHLOGICBEAN)
    private DispatchLogicService dispatchLogicService;

    @EJB(lookup = ShopLogicService.LOGIC_SHOPLOGICBEAN)
    private ShopLogicService shopLogicService;

    @EJB(lookup = OrderPersistenceService.PERSISTENCE_ORDERPERSISTENCEBEAN)
    private OrderPersistenceService orderPersistenceService;

    private Logger log = LoggerFactory.getLogger(OpenTransDeliveryMessageBean.class);

    private static final SimpleDateFormat SDF_ERPAL = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX");

    public void handleDispatch(DISPATCHNOTIFICATION deliveryMessage) throws ValidationException
    {
        if (deliveryMessage == null)
        {
            throw new IllegalArgumentException("deliveryMessage must not be null");
        }

        handleOPENTRANS(deliveryMessage);

    }

    private DISPATCHNOTIFICATION handleOPENTRANS(DISPATCHNOTIFICATION deliveryMessage) throws ValidationException
    {
        // map
        List<DispatchDO> dispatchList = mapOPENTRANSDelivery(deliveryMessage);

        createDispatches(dispatchList);

        return deliveryMessage;
    }

    private List<DispatchDO> mapOPENTRANSDelivery(DISPATCHNOTIFICATION deliveryMessage) throws ValidationException
    {
        final DateFormat SDF_OPENTRANS_ISO8601 = new SimpleDateFormat(SDF_STR_OPENTRANS_ISO8601);
        SDF_OPENTRANS_ISO8601.setLenient(false);
        String PATH_DELIVERYNOTENO = "DISPATCHNOTIFICATIONHEADER/DISPATCHNOTIFICATIONINFO/DISPATCHNOTIFICATIONID";
        String PATH_DELIVERYDATE = "DISPATCHNOTIFICATIONHEADER/DISPATCHNOTIFICATIONINFO/DELIVERYDATE/DELIVERYSTARTDATE";

        List<String> distinctOrders = deliveryMessage.getDISPATCHNOTIFICATIONITEMLIST().getDISPATCHNOTIFICATIONITEM()
                        .stream().map(dn -> dn.getORDERREFERENCE().getORDERID()).distinct().toList();

        String deliveryNoteNo = MapperUtil.resolvePath(deliveryMessage, PATH_DELIVERYNOTENO);
        if (isBlank(deliveryNoteNo))
        {
            throw singleValidationException(deliveryMessage, new MissingFieldException(PATH_DELIVERYNOTENO));
        }

        Timestamp deliveryDate;

        String deliveryStartDate = MapperUtil.resolvePath(deliveryMessage, PATH_DELIVERYDATE);
        if (!isBlank(deliveryStartDate))
        {
            try
            {
                deliveryDate = new Timestamp(SDF_OPENTRANS_ISO8601.parse(deliveryStartDate).getTime());
            }
            catch(ParseException e)
            {
                throw singleValidationException(deliveryMessage,
                                new IncorrectValueException(PATH_DELIVERYDATE, deliveryStartDate));
            }
        }
        else
        {
            deliveryDate = new Timestamp(System.currentTimeMillis());
        }

        List<DispatchDO> dispatchesToCreate = new ArrayList<>();

        for (String shopPurchaseOrderNumber : distinctOrders)
        {
            OrderDO orderDO = null;
            try
            {
                // FIXME hardcoded shop id, just an example
                orderDO = orderPersistenceService.getOrderDO(10000L, shopPurchaseOrderNumber);
            }
            catch(NoObjectException e)
            {
                throw singleValidationException(deliveryMessage,
                                new IncorrectValueException("shopPurchaseOrderNumber", shopPurchaseOrderNumber));
            }
            DispatchDO dispatchDO = new DispatchDO();

            ShopDO shopDO;
            try
            {
                shopDO = shopLogicService.getShopDO(orderDO.getShopRef());
            }
            catch(DatabaseException | NoObjectException e)
            {
                throw new OMSRuntimeException("internal db error", e);
            }

            SupplierDO supplierDO;
            try
            {
                // FIXME harcoded example, should be determined dynamically
                supplierDO = orderDO.getOrderPosDOList().get(0).getSupplierDO();
            }
            catch(IllegalArgumentException e)
            {
                throw singleValidationException(deliveryMessage,
                                new InvalidReferenceException("shopPurchaseOrderNumber", shopPurchaseOrderNumber));
            }
            // TODO
            Supplier2CarrierDO supp2carr = supplierDO.getCarrierList().get(0);
            CarrierDO carrierDO = supp2carr.getCarrierDO();

            List<DispatchPosDO> dispatchPosList = new ArrayList<>();
            Set<String> uniqueTrackingNumbers = new HashSet<>();

            for (DISPATCHNOTIFICATIONITEM notificationItem : deliveryMessage.getDISPATCHNOTIFICATIONITEMLIST()
                            .getDISPATCHNOTIFICATIONITEM().stream()
                            .filter(pos -> pos.getORDERREFERENCE().getORDERID().equals(shopPurchaseOrderNumber))
                            .toList())
            {
                int orderPosNo;
                try
                {
                    orderPosNo = Integer.parseInt(notificationItem.getORDERREFERENCE().getLINEITEMID());
                }
                catch(NumberFormatException | NullPointerException e)
                {
                    throw singleValidationException(notificationItem, new IncorrectValueException("OrderPosNo"));
                }
                int qty = notificationItem.getQUANTITY().intValue();

                DispatchPosDO dispatchPosDO = mapPosition(orderPosNo, qty, orderDO);
                dispatchPosDO.setDispatchDO(dispatchDO);
                dispatchPosList.add(dispatchPosDO);

                // prevent NPE...
                if (notificationItem.getLOGISTICDETAILS() == null
                                || notificationItem.getLOGISTICDETAILS().getPACKAGEINFO() == null)
                {
                    continue;
                }

                // iterate over packages for that product
                for (PACKAGE pack : notificationItem.getLOGISTICDETAILS().getPACKAGEINFO().getPACKAGE())
                {
                    // there may be multiple IDs for a package
                    for (PACKAGEID id : pack.getPACKAGEID())
                    {
                        // carrier specific id = tracking number
                        if (id.getType().equals(CARRIER_SPECIFIC_PACKAGE_ID))
                        {
                            uniqueTrackingNumbers.add(id.getValue());
                        }
                    }
                }
            }

            if (dispatchPosList.size() < 1)
            {
                // well..
                log.error("empty dispatch position list? purchase order number: " + shopPurchaseOrderNumber);
                continue;
            }
            dispatchDO.setDeliveryNoteNo(deliveryNoteNo);
            dispatchDO.setTrackingNo(String.join(";", uniqueTrackingNumbers));
            dispatchDO.setDispatchDate(deliveryDate);
            dispatchDO.setEntryDate(deliveryDate);
            dispatchDO.getDispatchPosDOList().addAll(dispatchPosList);
            dispatchDO.setSupplierCarrierName(supp2carr.getSupplierCarrierName());
            dispatchDO.setCarrierDO(carrierDO);
            dispatchDO.setPackages(1);
            dispatchDO.setOrderDO(orderDO);
            dispatchDO.setShopDO(shopDO);
            dispatchDO.setShopOrderNo(orderDO.getShopOrderNo());
            dispatchDO.setSupplierDO(supplierDO);
            // find purchase order number
            dispatchDO.setSupplierOrderNo(
                            deliveryMessage.getDISPATCHNOTIFICATIONITEMLIST().getDISPATCHNOTIFICATIONITEM().stream()
                                            .filter(pos -> pos.getORDERREFERENCE().getORDERID()
                                                            .equals(shopPurchaseOrderNumber)
                                                            && pos.getSUPPLIERORDERREFERENCE() != null && !isBlank(
                                                            pos.getSUPPLIERORDERREFERENCE().getSUPPLIERORDERID()))
                                            .map(pos -> pos.getSUPPLIERORDERREFERENCE().getSUPPLIERORDERID())
                                            .findFirst().orElse(shopPurchaseOrderNumber));
            dispatchesToCreate.add(dispatchDO);
        }

        return dispatchesToCreate;
    }

    private void createDispatches(List<DispatchDO> dispatchList) throws ValidationException
    {
        // process
        for (DispatchDO dispatch : dispatchList)
        {
            try
            {
                dispatchLogicService.createDispatchDO(dispatch, UserDO.BATCH_USER_ID, InitiatorDefDO.WEBSERVICE);
            }
            catch(DatabaseException | NoObjectException | DuplicateObjectException | InvalidStateTransitionException e)
            {
                log.error("unrecoverable error while calling DispatchService.createDispatchDO", e);
                throw new OMSRuntimeException("error while creating dispatch ", e);
            }

        }
    }

    private static DispatchPosDO mapPosition(int lineNumber, int quantity, OrderDO orderDO) throws ValidationException
    {
        // Integer orderPosNo = getOrderPosNoForDeliveryItem(deliveryItem);
        DispatchPosDO dispatchPosDO = new DispatchPosDO();

        OrderPosDO orderPosDO;

        orderPosDO = orderDO.getOrderPosDOList().stream().filter(pos -> pos.getOrderPosNo() == lineNumber).findAny()
                        .orElseThrow(() -> new ValidationException(orderDO,
                                        new InvalidReferenceException("LineItemNumber", String.valueOf(lineNumber))));

        dispatchPosDO.setOrderPosDO(orderPosDO);
        dispatchPosDO.setOrderPosNo(orderPosDO.getOrderPosNo());
        dispatchPosDO.setArticleRef(orderPosDO.getArticleRef());
        dispatchPosDO.setEan(orderPosDO.getEan());
        dispatchPosDO.setIsbn(orderPosDO.getIsbn());
        if (quantity > orderPosDO.getMaxQuantityToBeDispatched())
        {
            throw singleValidationException(orderDO, new IncorrectValueException("Quantity", String.valueOf(quantity),
                            "Confirmed / MaxDispatchable: " + orderPosDO.getQuantityConfirmed() + " / "
                                            + orderPosDO.getMaxQuantityToBeDispatched()));
        }
        dispatchPosDO.setQuantityDispatched(quantity);
        dispatchPosDO.setShopArticleName(orderPosDO.getShopArticleName());
        dispatchPosDO.setShopArticleNo(orderPosDO.getShopArticleNo());
        dispatchPosDO.setShopOrderPosNo(orderPosDO.getShopOrderPosNo());
        dispatchPosDO.setSupplierArticleNo(orderPosDO.getSupplierArticleNo());

        return dispatchPosDO;
    }

    private static ValidationException singleValidationException(Object validationObject,
                    BakeryValidationException bakeryValidationException)
    {
        ValidationException val = new ValidationException(validationObject);
        val.getExceptionList().add(bakeryValidationException);
        return val;
    }

}
