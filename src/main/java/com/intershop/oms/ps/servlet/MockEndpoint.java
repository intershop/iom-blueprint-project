package com.intershop.oms.ps.servlet;

import static org.apache.commons.lang3.StringUtils.isNotBlank;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Can be used to mock endpoints for development.
 */
public class MockEndpoint extends HttpServlet
{
    private static final long serialVersionUID = 1L;

    public static final String RESPONSE_CODE_PARAM = "responseCode";
    public static final String RESPONSE_TEXT_PARAM = "responseText";

    public static final String RMA_LOGIN_DUMMY = "{\"token\":\"%s\"}";

    private static final String DPD_LOGIN_DUMMY = "{\"error\":null,\"data\":{\"geoSession\":\"testgeosession\",\"flag\":\"7\"}}";
    private static final String DPD_SHIPMENT_DUMMY = "{\"error\":null,\"data\":{\"shipmentId\":1055223,\"consolidated\":false,\"consignmentDetail\":[{\"consignmentNumber\":\"1999236263\",\"parcelNumbers\":[\"15501999236263\"]}]}}";
    private static final String DPD_HTML_DUMMY = "<!DOCTYPE html><html><head><title>Page Title</title></head><body><h1>My First Heading</h1><p>My first paragraph.</p></body></html>";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException
    {
        putOrPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException
    {
        putOrPost(req, resp);
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException
    {
        putOrPost(req, resp);
    }

    private static void putOrPost(HttpServletRequest req, HttpServletResponse resp) throws IOException
    {
        String responseCodeParam = req.getParameter(RESPONSE_CODE_PARAM);
        String responseTextParam = req.getParameter(RESPONSE_TEXT_PARAM);
        String responseBody = null;

        if (isNotBlank(responseTextParam))
        {
            responseBody = responseTextParam;
        }

        int responseCode = 200;
        if (isNotBlank(responseCodeParam))
        {
            try
            {
                responseCode = Integer.valueOf(responseCodeParam);
            }
            catch(NumberFormatException e)
            {
            }
        }
        resp.setStatus(responseCode);
        if (req.getRequestURI().contains("dpd-dummy"))
        {
            if (req.getRequestURI().contains("user"))
            {
                resp.setContentType("application/json");
                responseBody = DPD_LOGIN_DUMMY;
            }
            else if (req.getRequestURI().contains("shipment") && !req.getRequestURI().contains("label"))
            {
                resp.setContentType("application/json");
                responseBody = DPD_SHIPMENT_DUMMY;
            }
            else
            {
                resp.setContentType("text/html");
                responseBody = DPD_HTML_DUMMY;
            }
        }

        if (isNotBlank(responseBody))
        {

            resp.getWriter().print(responseBody);
            resp.getWriter().flush();
            resp.getWriter().close();
        }

    }
}
