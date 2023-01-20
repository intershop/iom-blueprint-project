package com.intershop.oms.ps.servlet;

import static org.apache.commons.lang3.StringUtils.isNotBlank;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import bakery.persistence.dataobject.DatabaseDefinitions;

public class ImportStatus extends HttpServlet
{
    private static final long serialVersionUID = 1L;
    public static final String QRY = "select * from \"ImportDatapackDO\" order by id desc limit 20;";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException
    {
        PrintWriter out = resp.getWriter();

        try (Connection conny = DatabaseDefinitions.getConnection(); Statement stmt = conny.createStatement();
                        ResultSet res = stmt.executeQuery(QRY);)
        {
            ResultSetMetaData meta = res.getMetaData();
            final int columnCount = meta.getColumnCount();
            out.write("<table width=\"100%\" border=\"1\"><tr>");
            for (int i = 1; i <= columnCount; i++)
            {
                out.write("<td>" + meta.getColumnName(i) + "</td>");
            }
            out.write("</tr>");
            while(res.next())
            {
                out.write("<tr>");
                for (int i = 1; i <= columnCount; i++)
                {
                    if ("articleErrorCount".equals(meta.getColumnName(i)) && isNotBlank(res.getString(i))
                                    && !"0".equals(res.getString(i)))
                    {
                        out.write("<td><a href=\"ImportErrors?" + ImportErrors.QUERY_PARAMETER_DATAPACKREF + "="
                                        + res.getString(1) + "\">" + res.getString(i) + "</a></td>");
                    }
                    else
                    {
                        out.write("<td>" + res.getString(i) + "</td>");
                    }
                }
                out.write("</tr>");
            }
            out.write("</table>");
        }
        catch(Exception e)
        {
            out.println("ERROR: ");
            e.printStackTrace(out);
        }
        finally
        {
            out.flush();
            out.close();
        }
    }

}
