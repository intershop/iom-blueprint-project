package com.intershop.oms.blueprint.upload;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

public class ProductUpload extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Auto-generated constructor stub
    public ProductUpload() {
        super();
    }

    // HttpServlet doPost(HttpServletRequest request, HttpServletResponse response)
    // method
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /* Receive file uploaded to the Servlet from the HTML5 form */
        Part filePart = request.getPart("file");
        String fileName = filePart.getSubmittedFileName();
        for (Part part : request.getParts()) {
            // part.write("C:\\upload\\" + fileName);
        }
        response.getWriter().print("The file uploaded sucessfully.");

    }

}
