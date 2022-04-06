package com.intershop.oms.ps;

import static org.junit.jupiter.api.Assertions.assertTrue;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.List;

import javax.ejb.EJB;
import javax.ejb.Singleton;
import javax.ejb.Stateful;
import javax.ejb.Stateless;
import javax.persistence.PersistenceContext;

import org.junit.jupiter.api.Test;
import org.reflections.Reflections;
import org.reflections.scanners.Scanners;

// this test class can be used to perform some static "code analysis" to check
// for missing annotations
public class BeanAnnotationTest
{
    @SuppressWarnings("static-method")
    @Test
    public void test() throws Exception
    {
        Reflections reflectionsFramework = new Reflections("com.intershop.oms.ps",  Scanners.SubTypes.filterResultsBy(s -> true));
        // you can add custom java packages like this:
        Reflections reflectionsProject = new Reflections("com.intershop.oms.example", Scanners.SubTypes.filterResultsBy(s -> true));

        List<Class<? extends Object>> classes = new ArrayList<>();
        classes.addAll(reflectionsProject.getSubTypesOf(Object.class));
        classes.addAll(reflectionsFramework.getSubTypesOf(Object.class));

        for (Class<? extends Object> clazz : classes)
        {
            // abstract classes and JAX-RS provider classes do not require
            // annotations like Stateless or Singleton
            if (Modifier.isAbstract(clazz.getModifiers()) || isJaxRsProvider(clazz))
            {
                continue;
            }
            for (Field field : clazz.getDeclaredFields())
            {
                if (field.isAnnotationPresent(EJB.class) || field.isAnnotationPresent(PersistenceContext.class))
                {
                    assertTrue(clazz.isAnnotationPresent(Stateless.class) || clazz.isAnnotationPresent(Stateful.class)
                                    || clazz.isAnnotationPresent(Singleton.class), clazz.getName());
                    break;
                }
            }
        }
    }

    private static boolean isJaxRsProvider(Class<? extends Object> clazz)
    {
        // adjust this if necessary
        return clazz.getPackageName().startsWith("com.intershop.oms.ps.rest.filter");
    }
}
