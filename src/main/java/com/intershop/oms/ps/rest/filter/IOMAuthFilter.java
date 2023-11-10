package com.intershop.oms.ps.rest.filter;

import static org.apache.commons.lang3.StringUtils.isBlank;
import static org.apache.commons.lang3.StringUtils.startsWithIgnoreCase;

import java.io.IOException;
import java.util.Base64;
import java.util.StringTokenizer;

import jakarta.annotation.Priority;
import jakarta.ejb.EJB;
import jakarta.ws.rs.Priorities;
import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.container.ContainerRequestFilter;
import jakarta.ws.rs.core.HttpHeaders;
import jakarta.ws.rs.ext.Provider;

import bakery.logic.service.user.UserLoginLogicService;
import bakery.persistence.dataobject.configuration.user.UserDO;
import bakery.util.exception.DatabaseException;
import bakery.util.exception.NoObjectException;
import bakery.util.exception.ValidationException;

@Provider
@Priority(Priorities.AUTHENTICATION)
public class IOMAuthFilter implements ContainerRequestFilter
{
    @EJB(lookup = UserLoginLogicService.LOGIC_USERLOGINLOGICBEAN)
    private UserLoginLogicService userLoginLogicService;

    private static final String AUTHENTICATION_SCHEME = "Basic";
    private static final String AUTHENTICATION_SEPARATOR = ":";

    @Override
    public void filter(ContainerRequestContext requestContext) throws IOException
    {
        String userName = null;
        try
        {
            userName = getAuthenticatedUser(requestContext);
        }
        catch(DatabaseException | NoObjectException | ValidationException e)
        {
            // ignore, continue without auth
        }

        requestContext.setSecurityContext(new BasicAuthSecurityContext(userName));

    }   

    private String getAuthenticatedUser(ContainerRequestContext requestContext)
                    throws DatabaseException, NoObjectException, ValidationException
    {
        String authHeader = requestContext.getHeaderString(HttpHeaders.AUTHORIZATION);
        if (isBlank(authHeader) || !startsWithIgnoreCase(authHeader, AUTHENTICATION_SCHEME))
        {
            return null;
        }

        final String encodedUserPassword = authHeader.replaceFirst(AUTHENTICATION_SCHEME + " ", "");

        /*
         * Username und Passwort dekodieren
         */
        String usernameAndPassword = new String(Base64.getDecoder().decode(encodedUserPassword));

        if (!usernameAndPassword.contains(AUTHENTICATION_SEPARATOR))
        {
            return null;
        }

        /*
         * Usernamen und Passwort auseinandernehmen
         */
        StringTokenizer tokenizer = new StringTokenizer(usernameAndPassword, AUTHENTICATION_SEPARATOR);

        String userName = tokenizer.nextToken();
        String password = tokenizer.nextToken();

        UserDO authenticatedUser = userLoginLogicService.authorizeUserCrypted(userName, password);
        return authenticatedUser.getAccountName();

    }
}
