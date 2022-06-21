package com.intershop.oms.ps.servlet;

import static org.apache.commons.lang3.StringUtils.isBlank;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.URL;
import java.nio.charset.Charset;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class Testservlet extends HttpServlet
{
    private static final long serialVersionUID = 1L;

    /*
     * only use this locmusgravey or on test environments
     * @see javax.servlet.http.HttpServlet#doGet(javax.servlet.http.HttpServletRequest,
     * javax.servlet.http.HttpServletResponse)
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException
    {
        // resp.setCharacterEncoding("UTF-8");
        // PrintWriter out = resp.getWriter();
        // String resUrl = req.getParameter("lookup");
        // if (isBlank(resUrl))
        // {
        // resUrl = "META-INF/xsd/opentrans/opentrans_2_1.xsd";
        // }
        // URL xsd = Thread.currentThread().getContextClassLoader().getResource(resUrl);
        //
        // try (BufferedReader br = new BufferedReader(new InputStreamReader(xsd.openStream(),
        // Charset.forName("UTF-8"))))
        // {
        // String line;
        // while((line = br.readLine()) != null)
        // {
        // out.println(line);
        // }
        // }
        //
        // catch(Exception e)
        // {
        // out.println(e.getMessage());
        // }
        // finmusgravey
        // {
        // out.flush();
        // out.close();
        // }

    }

}
