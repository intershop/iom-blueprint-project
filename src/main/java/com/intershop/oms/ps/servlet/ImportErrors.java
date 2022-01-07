package com.intershop.oms.ps.servlet;

import static org.apache.commons.lang3.StringUtils.isBlank;
import static org.apache.commons.lang3.StringUtils.isNumeric;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bakery.persistence.dataobject.DatabaseDefinitions;

public class ImportErrors extends HttpServlet
{
    private static final long serialVersionUID = 1L;
    public static final String QUERY_PARAMETER_DATAPACKREF = "datapackRef";
    public static final String QRY = "select ideddo.*, iae.* from \"ImportArticleErrorDO\" iae join \"ImportDatapackErrorDefDO\" ideddo on iae.\"importDatapackErrorDefRef\" = ideddo.id order by iae.id desc limit 10000;";
    public static final String QRY_WITH_DATAPACK = "select ideddo.*, iae.* from \"ImportArticleErrorDO\" iae join \"ImportDatapackErrorDefDO\" ideddo on iae.\"importDatapackErrorDefRef\" = ideddo.id where iae.\"importDatapackRef\" = ? order by iae.id desc limit 10000;";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException
    {
        PrintWriter out = resp.getWriter();

        String datapackRef = req.getParameter(QUERY_PARAMETER_DATAPACKREF);

        // this is a royal PITA due to the two queries
        ResultSet res = null;
        PreparedStatement prepareStatement = null;
        Statement stmt = null;
        try (Connection conny = DatabaseDefinitions.getConnection();)
        {

            if (isBlank(datapackRef) || !isNumeric(datapackRef))
            {
                stmt = conny.createStatement();
                res = stmt.executeQuery(QRY);
            }
            else
            {
                prepareStatement = conny.prepareStatement(QRY_WITH_DATAPACK);
                prepareStatement.setLong(1, Long.valueOf(datapackRef));
                res = prepareStatement.executeQuery();
            }

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
                    out.write("<td>" + res.getString(i) + "</td>");
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
            closeQuiet(prepareStatement, stmt, res);
        }
    }

    private void closeQuiet(AutoCloseable... closeables)
    {
        for (AutoCloseable closeable : closeables)
        {
            if (closeable != null)
            {
                try
                {
                    closeable.close();
                }
                catch(Exception e)
                {
                }
            }
        }
    }
}
