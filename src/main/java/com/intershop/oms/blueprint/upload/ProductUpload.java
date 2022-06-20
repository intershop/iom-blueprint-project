package com.intershop.oms.blueprint.upload;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import com.intershop.oms.utils.configuration.IOMSharedFileSystem;

@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
                maxFileSize = 1024 * 1024 * 10, // 10 MB
                maxRequestSize = 1024 * 1024 * 100 // 100 MB
)
public class ProductUpload extends HttpServlet
{
    private static final long serialVersionUID = 1L;
    private static final Path TARGET_UPLOAD_DIRECTORY = IOMSharedFileSystem.OMS_SHARE.resolve("productupload");

    // Auto-generated constructor stub
    public ProductUpload()
    {
        super();
    }

    // refer
    // https://www.theserverside.com/blog/Coffee-Talk-Java-News-Stories-and-Opinions/Java-File-Upload-Servlet-Ajax-Example
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {

        // if not existing yet, create target directory
        if (!Files.isDirectory(TARGET_UPLOAD_DIRECTORY))
        {
            Files.createDirectory(TARGET_UPLOAD_DIRECTORY);
        }

        // get file from form
        Part filePart = request.getPart("file");
        String fileName = filePart.getSubmittedFileName();

        // write to share
        for (Part part : request.getParts())
        {
            part.write(TARGET_UPLOAD_DIRECTORY.resolve(fileName).toString());
        }

        response.getWriter().print("File '" + fileName + "' uploaded sucessfully to " + TARGET_UPLOAD_DIRECTORY + ".");
    }

}
