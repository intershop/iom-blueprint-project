package com.intershop.oms.blueprint.info;

import com.intershop.oms.info.InfoPropertyImpl;
import com.intershop.oms.logic.service.InfoPropertyService;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;

/**
 * Adds custom properties to the informational properties map.
 * Two should be displayed in the back office.
 * One should NOT be displayed in the back office.
 */
@Singleton
@Startup
public class AddInfoProperties
{
    
    @EJB(lookup = InfoPropertyService.JNDI)
    private InfoPropertyService infoPropertyService;
    
    private final String KEY_DEVELOPMENT_INFO = "DevelopmentInfo";
    private final String KEY_WISHES_INFO = "WishesInfo";
    private final boolean SHOW_IN_BACKOFFICE = true;
    
    private final String KEY_A_JOKE = "JokeThatShouldNotBeShownInTheBackoffice";

    @PostConstruct
    public void init()
    {
        infoPropertyService.putInfoProperty(new InfoPropertyImpl(KEY_DEVELOPMENT_INFO, "The deployed project is a demo project for demonstration purposes and for learning project development of the Intershop Order Management.", SHOW_IN_BACKOFFICE));
        infoPropertyService.putInfoProperty(new InfoPropertyImpl(KEY_WISHES_INFO, "Intershop works continuously to meet the needs of its customers in the best possible way.", SHOW_IN_BACKOFFICE));
        
        // don't show this in the back office
        infoPropertyService.putInfoProperty(new InfoPropertyImpl(KEY_A_JOKE, "Here comes a joke ...", false));
    }
    
}