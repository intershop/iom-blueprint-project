package com.intershop.oms.blueprint.upload.transform;

import static org.apache.commons.lang3.StringUtils.isNotBlank;
import static org.apache.commons.lang3.StringUtils.normalizeSpace;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.LinkedHashMap;
import java.util.stream.Stream;

public class CSVRecord<T extends Enum<T> & CSVTable>
{
    private LinkedHashMap<T, String> values = new LinkedHashMap<>();
    private Class<T> cls;

    /**
     * This constructor will create an instance of this class with initialized column names and default values for the
     * selected CSVTable enumeration.
     *
     * @param clazz
     */
    @SuppressWarnings("unchecked")
    public CSVRecord(Class<T> clazz)
    {
        this.cls = clazz;
        Method method;
        try
        {
            // we have to use reflections here, anyway this is pretty much idiot
            // proof due to the fact that the generic type is bound to Enum,
            // which guarantees availability of the values() method.
            method = clazz.getDeclaredMethod("values");
            Object[] obj = (Object[])method.invoke(null);
            Stream.of(obj).forEach(en -> this.values.put(((T)en), ((CSVTable)en).getDefaultValue()));
        }
        catch(NoSuchMethodException | SecurityException | IllegalAccessException | IllegalArgumentException
                        | InvocationTargetException e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * Sets the value of the specified column unless the provided value is null or empty.
     *
     * @param header
     *            the enum constant for the CSV column
     * @param value
     */
    public void setNotBlank(T header, String value)
    {
        String sanitized = normalizeSpace(value);
        if (isNotBlank(sanitized))
        {
            values.put(header, sanitized);
        }
    }

    public Iterable<String> toIterator()
    {
        return values.values();
    }

    @Override
    @SuppressWarnings("unchecked")
    public CSVRecord<T> clone()
    {
        CSVRecord<T> cl = new CSVRecord<>(cls);
        // it's a shallow copy, however keys and values are immutable so this is
        // a safe operation
        cl.values = (LinkedHashMap<T, String>)values.clone();
        return cl;
    }

}
