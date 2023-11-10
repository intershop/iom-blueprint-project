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
        order.setCustomerData(createB2BCustomer())
            .setInvoiceAddress(createB2BInvoiceAddress())
            .setPayment(new OMSPayment().setPaymentMethod("ISH_INVOICE"))
            .setSales(getSales())
            .addShippingBucketsItem(getShippingBucket());

        order.setTestCaseId(testCaseId);
        order.setShop(new OMSShop(10020));
        return order;
    }

    private static OMSShippingBucket getShippingBucket()
    {
        return new OMSShippingBucket()
                        .setShippingMethod("DHL")
                        .setShippingAddress(getShippingAddress())
                        .addChargesItem(getDeliveryCharge())
                        .addPositionsItem(getPosA()).addPositionsItem(getPosB());
    }

    private static OMSOrderPosition getPosB()
    {
        OMSProduct product = new OMSProduct().setName("LUXA2 M1-Pro").setNumber("7030019");
        OMSShipping shipping = new OMSShipping()
                        .setDeliveryDate(new OMSDeliveryDate()
                        .setDeliveryDateType(OMSDeliveryDateTypeEnum.FIXED)
                        .setDesiredDeliveryDate(tomorrow()));
        OMSUnitPrice unitPrice = new OMSUnitPrice()
                        .setGross(getListPrice("72.00", "72.00"))
                        .setNet(getListPrice("60.00", "60.00"));
        OMSSumPrice sum = new OMSSumPrice()
                        .addTaxesItem(new OMSTax().setType("FullTax").setAmount(new BigDecimal("12.00")))
                        .setNet(getPrice("60.00", "60.00"))
                        .setGross(getPrice("72.00", "72.00"));
        return new OMSOrderPosition()
                        .setProduct(product)
                        .setQuantity(1)
                        .setShipping(shipping)
                        .setUnitPrice(unitPrice)
                        .setSum(sum)
                        .setNumber(2);
    }

    private static OMSOrderPosition getPosA()
    {
        OMSProduct product = new OMSProduct()
                        .setName("Logitech ClearChat Comfort")
                        .setNumber("896737");
        OMSShipping shipping = new OMSShipping()
                        .setDeliveryDate(new OMSDeliveryDate()
                        .setDeliveryDateType(OMSDeliveryDateTypeEnum.FIXED)
                        .setDesiredDeliveryDate(tomorrow()));
        OMSUnitPrice unitPrice = new OMSUnitPrice()
                        .setGross(getListPrice("24.20", "24.20"))
                        .setNet(getListPrice("20.00", "20.00"));
        OMSSumPrice sum = new OMSSumPrice()
                        .addTaxesItem(new OMSTax().setType("FullTax").setAmount(new BigDecimal("8.40")))
                        .setNet(getPrice("40.00", "40.00"))
                        .setGross(getPrice("48.40", "48.40"));
        return new OMSOrderPosition()
                        .setProduct(product)
                        .setQuantity(2)
                        .setShipping(shipping)
                        .setUnitPrice(unitPrice)
                        .setSum(sum)
                        .setNumber(1);
    }

    private static OMSListPrice getListPrice(String amount, String amountDiscounted)
    {
        return new OMSListPrice()
                        .setAmount(new BigDecimal(amount))
                        .setAmountDiscounted(new BigDecimal(amountDiscounted));
    }

    private static OffsetDateTime tomorrow()
    {
        return OffsetDateTime.now().plusDays(1l);
    }

    private static OMSCharge getDeliveryCharge()
    {
        return new OMSCharge()
                        .setType("DELIVERYCHARGE")
                        .setNet(getPrice("5.00", "5.00"))
                        .setGross(getPrice("6.05", "6.05"))
                        .addTaxesItem(new OMSTax().setAmount(new BigDecimal("1.05")).setType("FullTax"));
    }

    private static OMSAddressShipping getShippingAddress()
    {
        return new OMSAddressShipping()
                        .setContact(new OMSContact().setEmail("user@example.com"))
                        .setReceiver(new OMSAddressReceiver()
                                        .setAddressReceiverType(OMSAddressReceiverTypeEnum.COMPANY)
                                        .setCompanyName("Intershop Communications AG")
                                        .setPerson(new OMSPerson().setFirstName("Tester").setLastName("McTesterson")))
                        .setLocation(getAddressLocation());
    }

    private static OMSSales getSales()
    {
        return new OMSSales().setCurrencyCode("EUR").setSubTotal(getSubTotal()).setTotal(getTotal());
    }

    private static OMSTotalPrice getTotal()
    {
        return new OMSTotalPrice()
                        .addTaxesItem(new OMSTax().setAmount(new BigDecimal("21.45")).setType("FullTax"))
                        .setGross(getPrice("126.45", "126.45"))
                        .setNet(getPrice("105.00", "105.00"));
    }

    private static OMSPrice getPrice(String amount, String amountDiscounted)
    {
        return new OMSPrice().setAmount(new BigDecimal(amount)).setAmountDiscounted(new BigDecimal(amountDiscounted));
    }

    private static OMSSumPrice getSubTotal()
    {
        return new OMSSumPrice()
                        .addTaxesItem(new OMSTax().setAmount(new BigDecimal("20.40")).setType("FullTax"))
                        .setNet(getPrice("100.00", "100.00"))
                        .setGross(getPrice("120.40", "120.40"));
    }

    private static OMSAddressInvoice createB2BInvoiceAddress()
    {
        return new OMSAddressInvoice()
                        .setContact(new OMSContact().setEmail("user@example.com"))
                        .setReceiver(new OMSAddressReceiver()
                                        .setAddressReceiverType(OMSAddressReceiverTypeEnum.COMPANY)
                                        .setCompanyName("Intershop Communications AG")
                                        .setPerson(new OMSPerson().setFirstName("Tester").setLastName("McTesterson")))
                        .setLocation(getAddressLocation());
    }

    private static OMSAddressLocation getAddressLocation()
    {
        return new OMSAddressLocationStreet()
                        .setStreet("Steinweg")
                        .setStreetNumber("10")
                        .setCity("Jena")
                        .setPostCode("07743")
                        .setCountryCode("DEU");
    }

    private static OMSCustomerData createB2BCustomer()
    {
        return new OMSCustomerData()
                        .setCustomerDataType(OMSCustomerDataTypeEnum.COMPANY)
                        .setCompanyData(createCompanyData());
    }

    private static OMSCompanyData createCompanyData()
    {
        return new OMSCompanyData()
                        .setCommercialRegisterLocation("Jena")
                        .setCommercialRegisterNumber("HRB 209419")
                        .setVatNumber("DE 812464534")
                        .setCompanyName("Intershop Communications AG");
    }
}