package com.intershop.oms.ps.servlet;

import static org.apache.commons.lang3.StringUtils.isNotBlank;

import java.io.IOException;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class Heartbeat extends HttpServlet
{
    private static final long serialVersionUID = 1L;

    public static final String RESPONSE_CODE_PARAM = "responseCode";
    public static final String RESPONSE_TEXT_PARAM = "responseText";

    public static final String RMA_DUMMY = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                    + "<p:ReturnAnnouncementResponse xmlns:p=\"http://oms.intershop.com/elefant/rma/model\" xmlns:p1=\"http://types.theberlinbakery.com/v1_0\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://oms.intershop.com/elefant/rma/model ReturnAnnouncementResponse-v1.0.xsd \">"
                    + "  <p:RMANumber>%s</p:RMANumber>" + "  <p:Property key=\"some_property\" value=\"some_value\"/>"
                    + "  <p:Property key=\"another_property\" value=\"another value xyz\"/>"
                    + "</p:ReturnAnnouncementResponse>";

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
        if (req.getRequestURI().contains("rma-dummy"))
        {
            if (req.getRequestURI().contains("unauthenticated"))
            {
                resp.setContentType("application/json");
                responseBody = String.format(RMA_LOGIN_DUMMY, UUID.randomUUID().toString());
            }
            else
            {
                resp.setContentType("application/xml");
                responseBody = String.format(RMA_DUMMY, UUID.randomUUID().toString());
            }
        }
        else if (req.getRequestURI().contains("dpd-dummy"))
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
