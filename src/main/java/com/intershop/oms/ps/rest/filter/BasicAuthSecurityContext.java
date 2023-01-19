package com.intershop.oms.ps.rest.filter;

import static org.apache.commons.lang3.StringUtils.isNotBlank;

import java.security.Principal;

import jakarta.ws.rs.core.SecurityContext;

public class BasicAuthSecurityContext implements SecurityContext
{
    public BasicAuthSecurityContext(String userName)
    {
        if (isNotBlank(userName))
        {
            this.principal = new Principal()
            {
                @Override
                public String getName()
                {
                    return userName;
                }
            };
        }
    }

    private Principal principal = null;

    @Override
    public Principal getUserPrincipal()
    {
        return principal;
    }

    @Override
    public boolean isUserInRole(String role)
    {
        return false;
    }

    @Override
    public boolean isSecure()
    {
        return true;
    }

    @Override
    public String getAuthenticationScheme()
    {
        return getUserPrincipal() != null ? SecurityContext.BASIC_AUTH : null;
    }

}
