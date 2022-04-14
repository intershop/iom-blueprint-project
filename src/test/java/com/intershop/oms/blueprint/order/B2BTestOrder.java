package com.intershop.oms.blueprint.order;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

import com.intershop.oms.test.businessobject.OMSShop;
import com.intershop.oms.test.businessobject.address.OMSAddressInvoice;
import com.intershop.oms.test.businessobject.address.OMSAddressLocation;
import com.intershop.oms.test.businessobject.address.OMSAddressLocationStreet;
import com.intershop.oms.test.businessobject.address.OMSAddressReceiver;
import com.intershop.oms.test.businessobject.address.OMSAddressReceiver.OMSAddressReceiverTypeEnum;
import com.intershop.oms.test.businessobject.address.OMSAddressShipping;
import com.intershop.oms.test.businessobject.address.OMSContact;
import com.intershop.oms.test.businessobject.address.OMSPerson;
import com.intershop.oms.test.businessobject.order.OMSCompanyData;
import com.intershop.oms.test.businessobject.order.OMSCustomerData;
import com.intershop.oms.test.businessobject.order.OMSCustomerData.OMSCustomerDataTypeEnum;
import com.intershop.oms.test.businessobject.order.OMSDeliveryDate;
import com.intershop.oms.test.businessobject.order.OMSDeliveryDate.OMSDeliveryDateTypeEnum;
import com.intershop.oms.test.businessobject.order.OMSOrder;
import com.intershop.oms.test.businessobject.order.OMSOrderPosition;
import com.intershop.oms.test.businessobject.order.OMSPayment;
import com.intershop.oms.test.businessobject.order.OMSProduct;
import com.intershop.oms.test.businessobject.order.OMSShipping;
import com.intershop.oms.test.businessobject.order.OMSShippingBucket;
import com.intershop.oms.test.businessobject.prices.OMSCharge;
import com.intershop.oms.test.businessobject.prices.OMSListPrice;
import com.intershop.oms.test.businessobject.prices.OMSPrice;
import com.intershop.oms.test.businessobject.prices.OMSSales;
import com.intershop.oms.test.businessobject.prices.OMSSumPrice;
import com.intershop.oms.test.businessobject.prices.OMSTax;
import com.intershop.oms.test.businessobject.prices.OMSTotalPrice;
import com.intershop.oms.test.businessobject.prices.OMSUnitPrice;

public class B2BTestOrder
{
    public static OMSOrder createSimpleOrder(String testCaseId)
    {
        OMSOrder order = new OMSOrder();
        order.customerData(createB2BCustomer()).invoiceAddress(createB2BInvoiceAddress())
                        .payment(new OMSPayment().paymentMethod("ISH_INVOICE")).sales(getSales())
                        .addShippingBucketsItem(getShippingBucket());

        order.setTestCaseId(testCaseId);
        order.setShop(new OMSShop(10020));
        return order;
    }

    private static OMSShippingBucket getShippingBucket()
    {
        return new OMSShippingBucket().shippingMethod("DHL").shippingAddress(getShippingAddress())
                        .addChargesItem(getDeliveryCharge()).addPositionsItem(getPosA()).addPositionsItem(getPosB());
    }

    private static OMSOrderPosition getPosB()
    {
        OMSProduct product = new OMSProduct().name("LUXA2 M1-Pro").number("7030019");
        OMSShipping shipping = new OMSShipping().deliveryDate(new OMSDeliveryDate()
                        .deliveryDateType(OMSDeliveryDateTypeEnum.FIXED).desiredDeliveryDate(tomorrow()));
        OMSUnitPrice unitPrice = new OMSUnitPrice().gross(getListPrice("72.00", "72.00"))
                        .net(getListPrice("60.00", "60.00"));
        OMSSumPrice sum = new OMSSumPrice().addTaxesItem(new OMSTax().type("FullTax").amount(new BigDecimal("12.00")))
                        .net(getPrice("60.00", "60.00")).gross(getPrice("72.00", "72.00"));
        return new OMSOrderPosition().product(product).quantity(1).shipping(shipping).unitPrice(unitPrice).sum(sum)
                        .number(2);
    }

    private static OMSOrderPosition getPosA()
    {
        OMSProduct product = new OMSProduct().name("Logitech ClearChat Comfort").number("896737");
        OMSShipping shipping = new OMSShipping().deliveryDate(new OMSDeliveryDate()
                        .deliveryDateType(OMSDeliveryDateTypeEnum.FIXED).desiredDeliveryDate(tomorrow()));
        OMSUnitPrice unitPrice = new OMSUnitPrice().gross(getListPrice("24.20", "24.20"))
                        .net(getListPrice("20.00", "20.00"));
        OMSSumPrice sum = new OMSSumPrice().addTaxesItem(new OMSTax().type("FullTax").amount(new BigDecimal("8.40")))
                        .net(getPrice("40.00", "40.00")).gross(getPrice("48.40", "48.40"));
        return new OMSOrderPosition().product(product).quantity(2).shipping(shipping).unitPrice(unitPrice).sum(sum)
                        .number(1);
    }

    private static OMSListPrice getListPrice(String amount, String amountDiscounted)
    {
        return new OMSListPrice().amount(new BigDecimal(amount)).amountDiscounted(new BigDecimal(amountDiscounted));
    }

    private static OffsetDateTime tomorrow()
    {
        return OffsetDateTime.now().plusDays(1l);
    }

    private static OMSCharge getDeliveryCharge()
    {
        return new OMSCharge().type("DELIVERYCHARGE").net(getPrice("5.00", "5.00")).gross(getPrice("6.05", "6.05"))
                        .addTaxesItem(new OMSTax().amount(new BigDecimal("1.05")).type("FullTax"));
    }

    private static OMSAddressShipping getShippingAddress()
    {
        return new OMSAddressShipping().contact(new OMSContact().email("user@example.com"))
                        .receiver(new OMSAddressReceiver().addressReceiverType(OMSAddressReceiverTypeEnum.COMPANY)
                                        .companyName("Intershop Communications AG")
                                        .person(new OMSPerson().firstName("Tester").lastName("McTesterson")))
                        .location(getAddressLocation());
    }

    private static OMSSales getSales()
    {
        return new OMSSales().currencyCode("EUR").subTotal(getSubTotal()).total(getTotal());
    }

    private static OMSTotalPrice getTotal()
    {
        return new OMSTotalPrice().addTaxesItem(new OMSTax().amount(new BigDecimal("21.45")).type("FullTax"))
                        .gross(getPrice("126.45", "126.45")).net(getPrice("105.00", "105.00"));
    }

    private static OMSPrice getPrice(String amount, String amountDiscounted)
    {
        return new OMSPrice().amount(new BigDecimal(amount)).amountDiscounted(new BigDecimal(amountDiscounted));
    }

    private static OMSSumPrice getSubTotal()
    {
        return new OMSSumPrice().addTaxesItem(new OMSTax().amount(new BigDecimal("20.40")).type("FullTax"))
                        .net(getPrice("100.00", "100.00")).gross(getPrice("120.40", "120.40"));
    }

    private static OMSAddressInvoice createB2BInvoiceAddress()
    {
        return new OMSAddressInvoice().contact(new OMSContact().email("user@example.com"))
                        .receiver(new OMSAddressReceiver().addressReceiverType(OMSAddressReceiverTypeEnum.COMPANY)
                                        .companyName("Intershop Communications AG")
                                        .person(new OMSPerson().firstName("Tester").lastName("McTesterson")))
                        .location(getAddressLocation());
    }

    private static OMSAddressLocation getAddressLocation()
    {
        return new OMSAddressLocationStreet().street("Steinweg").streetNumber("10").city("Jena").postCode("07743")
                        .countryCode("DEU");
    }

    private static OMSCustomerData createB2BCustomer()
    {
        return new OMSCustomerData().customerDataType(OMSCustomerDataTypeEnum.COMPANY).companyData(createCompanyData());
    }

    private static OMSCompanyData createCompanyData()
    {
        return new OMSCompanyData().commercialRegisterLocation("Jena").commercialRegisterNumber("HRB 209419")
                        .vatNumber("DE 812464534").companyName("Intershop Communications AG");
    }

}
