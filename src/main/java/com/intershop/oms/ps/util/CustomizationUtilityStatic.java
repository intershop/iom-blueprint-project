package com.intershop.oms.ps.util;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Base64;
import java.util.StringTokenizer;

import jakarta.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.theberlinbakery.types.v1_0.Property;
import com.theberlinbakery.types.v1_0.PropertyGroup;
import com.theberlinbakery.types.v2_0.ReturnAnnouncement;

import bakery.persistence.dataobject.documents.DocumentDO;
import bakery.persistence.dataobject.documents.DocumentPropertyDO;
import bakery.persistence.dataobject.order.OrderDO;
import bakery.persistence.dataobject.order.OrderPosDO;
import bakery.persistence.dataobject.order.OrderPosPropertyDO;
import bakery.persistence.dataobject.order.OrderPropertyDO;
import bakery.persistence.dataobject.payment.PaymentNotificationDO;
import bakery.persistence.dataobject.payment.PaymentNotificationPropertyDO;
import bakery.security.exception.AuthorizeException;
import bakery.util.exception.TechnicalException;

public final class CustomizationUtilityStatic
{

    public static final String AUTHORIZATION_PROPERTY = "Authorization";
    public static final String AUTHENTICATION_SCHEME = "Basic";
    public static final String AUTHENTICATION_SEPARATOR = ":";

    public static final Logger log = LoggerFactory.getLogger(CustomizationUtilityStatic.class);

    // static class haxx
    private CustomizationUtilityStatic()
    {
    };

    public static String[] getCredentialsFromHttpServletRequest(HttpServletRequest request) throws AuthorizeException
    {

        /*
         * Authorization-Header holen
         */
        String authorization = request.getHeader(AUTHORIZATION_PROPERTY);
        if (authorization == null)
        {
            throw new AuthorizeException("Missing Authorization!");
        }

        /*
         * Kodierten Usernamen und Passwort aus dem Header holen
         */
        final String encodedUserPassword = authorization.replaceFirst(AUTHENTICATION_SCHEME + " ", "");

        /*
         * Username und Passwort dekodieren
         */
        String usernameAndPassword = new String(Base64.getDecoder().decode(encodedUserPassword));

        if (!usernameAndPassword.contains(AUTHENTICATION_SEPARATOR))
        {
            throw new AuthorizeException(
                            String.format("Kein Separator ('%s') in decodiertem Authorization-Header gefunden.",
                                            AUTHENTICATION_SEPARATOR));
        }

        /*
         * Usernamen und Passwort auseinandernehmen
         */
        StringTokenizer tokenizer = new StringTokenizer(usernameAndPassword, AUTHENTICATION_SEPARATOR);

        String userName = tokenizer.nextToken();
        String password = tokenizer.nextToken();

        return new String[] { userName, password };
    }

    public static void moveProcessedFile(Path file, Path targetDir)
    {
        try
        {
            Files.move(file, targetDir.resolve(file.getFileName()), StandardCopyOption.REPLACE_EXISTING);
        }
        catch(IOException e)
        {
            throw new TechnicalException("Can't move import file to done/error dir: ", e);
        }
    }

    public static void setOrUpdateProperty(OrderPosDO orderPosDO, String groupId, String key, String value)
    {
        for (OrderPosPropertyDO prop : orderPosDO.getPropertyList())
        {
            if (groupId.equals(prop.getGroup()) && key.equals(prop.getKey()))
            {
                prop.setValue(value);
                return;
            }
        }

        orderPosDO.setProperty(groupId, key, value);

    }

    public static void setOrUpdateProperty(OrderDO orderDO, String groupId, String key, String value)
    {
        for (OrderPropertyDO prop : orderDO.getPropertyList())
        {
            if (groupId.equals(prop.getGroup()) && key.equals(prop.getKey()))
            {
                prop.setValue(value);
                return;
            }
        }

        orderDO.setProperty(groupId, key, value);

    }

    public static void setOrUpdateProperty(PaymentNotificationDO paymentNotificationDO, String groupId, String key,
                    String value)
    {
        for (PaymentNotificationPropertyDO prop : paymentNotificationDO.getPaymentNotificationPropertyList())
        {
            if (groupId.equals(prop.getGroup()) && key.equals(prop.getKey()))
            {
                prop.setValue(value);
                return;
            }
        }

        paymentNotificationDO.setProperty(groupId, key, value);

    }

    public static void setOrUpdateProperty(DocumentDO documentDO, String key, String value)
    {
        for (DocumentPropertyDO prop : documentDO.getPropertyList())
        {
            if (key.equals(prop.getKey()))
            {
                prop.setValue(value);
                return;
            }

        }

        DocumentPropertyDO newProp = new DocumentPropertyDO();
        newProp.setKey(key);
        newProp.setValue(value);
        newProp.setDocumentDO(documentDO);
        documentDO.getPropertyList().add(newProp);
    }

    public static void setOrUpdateProperty(ReturnAnnouncement returnAnnouncementXML, String group, String key, String value)
    {
        PropertyGroup grp = null;
        for(PropertyGroup pg : returnAnnouncementXML.getProperties())
        {
            if(!group.equals(pg.getId()))
            {
                continue;
            }

            grp = pg;
            for(Property prop: pg.getProperty())
            {
                if(key.equals(prop.getKey()))
                {
                    prop.setValue(value);
                    return;
                }
            }
        }

        if(grp == null)
        {
            grp = new PropertyGroup();
            grp.setId(group);
            returnAnnouncementXML.getProperties().add(grp);
        }

        Property prop = new Property();
        prop.setKey(key);
        prop.setValue(value);
        grp.getProperty().add(prop);
    }

}
