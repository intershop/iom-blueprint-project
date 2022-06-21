package com.intershop.oms.blueprint.upload.transform;

import org.apache.commons.lang3.StringUtils;

public enum InventoryDataCSV implements CSVTable
{
    // TODO
    dummy(StringUtils.EMPTY);

    private String defaultValue;

    private InventoryDataCSV(String defaultValue)
    {
        this.defaultValue = defaultValue;
    }

    @Override
    public String getDefaultValue()
    {
        return defaultValue;
    }
}