package com.intershop.oms.ps.rest.logging;

import static org.apache.commons.lang3.StringUtils.isBlank;

import java.util.List;

import jakarta.ws.rs.core.MultivaluedHashMap;
import jakarta.ws.rs.core.MultivaluedMap;

import org.apache.commons.lang3.StringUtils;

public class MaskedHeaders<K, V> extends MultivaluedHashMap<K, V>
{
    private static final long serialVersionUID = 1L;

    private MaskedHeaders(MultivaluedMap<K, V> map)
    {
        super(map);
    }

    private MaskedHeaders()
    {
        super();
    }

    @Override
    public String toString()
    {
        StringBuilder sb = new StringBuilder("[");
        for (Entry<K, List<V>> entry : entrySet())
        {
            sb.append("[");
            sb.append(entry.getKey().toString());
            sb.append("=");
            if (isSensitiveInformation(entry.getKey().toString()))
            {
                sb.append("******");
            }
            else
            {
                sb.append(StringUtils.join(entry.getValue(), ','));
            }
            sb.append("]");
        }
        sb.append("]");
        return sb.toString();
    }

    private static boolean isSensitiveInformation(String string)
    {
        return "authorization".equals(string.toLowerCase()) || string.toLowerCase().contains("token");

    }

    public static <K, V> MaskedHeaders<K, V> of(MultivaluedMap<K, V> map)
    {
        return new MaskedHeaders<K, V>(map);
    }

    public static MaskedHeaders<String, String> of(Iterable<String> headers)
    {
        MaskedHeaders<String, String> mv = new MaskedHeaders<>();
        for (String header : headers)
        {
            String[] keyValue = header.split(":", 2);
            if (keyValue.length != 2 || isBlank(keyValue[0]) || isBlank(keyValue[1]))
            {
                // ignore empty headers
                continue;
            }

            mv.add(keyValue[0], keyValue[1]);
        }

        return mv;
    }

}
