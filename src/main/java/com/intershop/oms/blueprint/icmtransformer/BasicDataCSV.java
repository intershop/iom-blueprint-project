package com.intershop.oms.blueprint.icmtransformer;

import com.intershop.oms.blueprint.upload.transform.CSVTable;
import org.apache.commons.lang3.StringUtils;

public enum BasicDataCSV implements CSVTable
{
    supplierArticleNo(StringUtils.EMPTY),
    manufacturer("MyTrustedManufacturer"),
    manufacturerArticleNo(StringUtils.EMPTY),
    ISBN(StringUtils.EMPTY),
    EAN(StringUtils.EMPTY),
    articleName(StringUtils.EMPTY),
    length(StringUtils.EMPTY),
    height(StringUtils.EMPTY),
    width(StringUtils.EMPTY),
    weight(StringUtils.EMPTY),
    assortmentName("Dummy"),
    assortmentIdentifier("Dummy"),
    deliveryForm(StringUtils.EMPTY),
    customsTariffNo(StringUtils.EMPTY),
    parentSupplierArticleNo(StringUtils.EMPTY),
    articleForm(StringUtils.EMPTY),
    immaterialUid(StringUtils.EMPTY),
    articleLanguage(StringUtils.EMPTY),
    supplierSalesCode(StringUtils.EMPTY),
    supplierArticleIdentifier(StringUtils.EMPTY),
    articleType("1"),
    edition(StringUtils.EMPTY),
    packagingUnit(StringUtils.EMPTY),
    packagingUnitValue(StringUtils.EMPTY);

    private String defaultValue;

    private BasicDataCSV(String defaultValue)
    {
        this.defaultValue = defaultValue;
    }

    @Override
    public String getDefaultValue()
    {
        return defaultValue;
    }
}