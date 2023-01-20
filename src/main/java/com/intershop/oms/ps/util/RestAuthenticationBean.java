package com.intershop.oms.ps.util;

import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import jakarta.servlet.http.HttpServletRequest;

import bakery.common.v1.EnumInitiator;
import bakery.persistence.dataobject.configuration.user.UserNotFoundException;
import bakery.persistence.expand.RightDefDOEnumInterface;
import bakery.security.exception.AuthorizeException;
import bakery.security.service.CheckpointSecurityService;
import bakery.security.service.UserSecurityService;
import bakery.user.v1.User;
import bakery.util.NamedId;

@Stateless
@TransactionAttribute(TransactionAttributeType.NEVER)
public class RestAuthenticationBean
{
    @EJB(lookup = UserSecurityService.SECURITY_USERSECURITYBEAN)
    private UserSecurityService userSecurityService;

    @EJB(lookup = CheckpointSecurityService.SECURITY_CHECKPOINT_SECURITY_BEAN)
    private CheckpointSecurityService checkpointSecurityService;

    public void authorizeOperation(HttpServletRequest request, RightDefDOEnumInterface rightDefDO)
                    throws AuthorizeException, UserNotFoundException
    {
        User usr;
        try
        {
            String[] credentials = CustomizationUtilityStatic.getCredentialsFromHttpServletRequest(request);
            String userName = credentials[0];
            String password = credentials[1];

            usr = this.userSecurityService.createUserSession(userName, password, EnumInitiator.WEBSERVICE);
        }
        catch(AuthorizeException e)
        {
            throw new UserNotFoundException(new NamedId("userDO", "userName"));
        }

        checkpointSecurityService.check(usr.getSessionKey(), rightDefDO);
    }
}
