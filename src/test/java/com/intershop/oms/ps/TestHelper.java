package com.intershop.oms.ps;

import java.lang.reflect.Field;

public class TestHelper
{
    public static void setField(Object object, String fieldName, Object value)
    {
        Field field;
        try
        {
            field = object.getClass().getDeclaredField(fieldName);
            field.setAccessible(true);
            field.set(object, value);
        }
        catch(Exception e)
        {
            throw new RuntimeException(e);
        }

    }

}
