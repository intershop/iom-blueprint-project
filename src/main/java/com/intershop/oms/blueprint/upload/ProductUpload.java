package com.intershop.oms.blueprint.upload;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.ejb.EJB;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import bakery.logic.service.configuration.Shop2SupplierLogicService;
import bakery.logic.service.configuration.ShopLogicService;
import bakery.persistence.dataobject.configuration.shop.ShopDO;
import bakery.persistence.dataobject.configuration.supplier.Shop2SupplierDO;
import bakery.persistence.dataobject.configuration.supplier.SupplierDO;

import com.intershop.oms.blueprint.upload.transform.BlueprintProductTransformer;
import com.intershop.oms.utils.configuration.IOMSharedFileSystem;

@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
                maxFileSize = 1024 * 1024 * 10, // 10 MB
                maxRequestSize = 1024 * 1024 * 100 // 100 MB
)
public class ProductUpload extends HttpServlet
{
    private final Path TARGET_UPLOAD_DIRECTORY = IOMSharedFileSystem.OMS_SHARE.resolve("tmp");
    // private final Path TARGET_IMPORT_IN = IOMSharedFileSystem.IMPORTARTICLE_IN.toPath();
    private final String FORM_PREFIX_SSR = "ssr_";

    @EJB(lookup = ShopLogicService.LOGIC_SHOPLOGICBEAN)
    private ShopLogicService shopLogicService;

    @EJB(lookup = Shop2SupplierLogicService.LOGIC_SHOP2SUPPLIERLOGICBEAN)
    private Shop2SupplierLogicService shop2SupplierLogicService;

    // Auto-generated constructor stub
    public ProductUpload()
    {
        super();
    }

    /**
     * Returns a html-form to enter product upload configurations.
     */
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException
    {
        // ServletResponse response;
        PrintWriter out = resp.getWriter();
        out.append("<html><head>");
        out.append("<title>Product Upload (non-standard)</title><link rel=\"shortcut icon\" type=\"image/png\" href=\"/omt/static/oms/img/favicon.ico\"></head>");
        out.append("<body><div><h1>Upload your product files</h1><span style=\"color:red\">Note, that this code is not part of the IOM Blueprint Project.</span>");
        out.append("<form action = \"ProductUpload\" method = \"post\" enctype = \"multipart/form-data\">");

        // get shops and related suppliers
        List<ShopDO> shops = shopLogicService.getShopDOList();
        for (ShopDO shopDO : shops)
        {
            if (shopDO.getId().intValue() > 1) // only real shops
            {
                out.append(createFieldset(shopDO));
            }
        }

        out.append("<fieldset><legend>Select the file to upload products.</legend>");
        out.append("<br>");
        out.append("<input type = \"file\" name = \"file\" style:\"width:120px;\" />");
        out.append("<br><br>");
        out.append("<input type = \"text\" name = \"stock\" value=\"250\" style:\"width:120px;\" /><label for=\"stock\"> stock level</label>");
        out.append("<br><br>");
        out.append("<input type = \"submit\" value = \"Import Products\" style:\"width:120px;background-color:light-blue;\" />");
        out.append("<br>");
        out.append("</fieldset></form></div></body></html>");

        out.flush();
        out.close();
    }

    /**
     * Creates a html-fieldset containing all suppliers of a shop to be selectable.
     * 
     * @param shopDO
     * @return
     */
    private StringBuilder createFieldset(ShopDO shopDO)
    {
        // if B2B set all boxes checked initially
        String checked = shopDO.isB2B() ? "checked" : "";

        StringBuilder dom = new StringBuilder();

        // the shop
        dom.append("<div><h2>" + shopDO.getName()
                        + "</h2><fieldset><legend>Select the suppliers to upload products for this shop</legend><br>");

        // assigned suppliers
        for (Shop2SupplierDO shop2SupplierDO : shop2SupplierLogicService.getShop2SupplierDOListByShopId(shopDO.getId()))
        {
            SupplierDO supplierDO = shop2SupplierDO.getSupplierDO();
            if (supplierDO.getId().intValue() > 1) // only real suppliers
            {
                dom.append(createCheckbox("ssr_" + shopDO.getId().toString() + "_" + supplierDO.getId().toString(),
                                supplierDO.getName(), checked));
            }
        }

        return dom.append("<br></fieldset></div>");
    }

    /**
     * Returns an html-checkbox with if and displayname to select.
     * 
     * @param id
     * @param displayname
     * @return
     */
    private String createCheckbox(String id, String displayname, String checked)
    {
        return "<input type=\"checkbox\" id=\"" + id + "\" name=\"" + id + "\" value=\"" + id + "\" " + checked
                        + "><label for=\"" + id + "\">" + displayname + "</label><br>";
    }

    /**
     * Accepts a html-form containing a product file and several options to import.
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        // get form input

        // get stock
        int stock = getStock(request);

        // call transformer and put files to configured standard import API
        // have 3 files per shop-supplier-relation to store with the following names
        // to product import directory

        // given file
        Part filePart = request.getPart("file");
        String fileName = filePart.getSubmittedFileName();

        // if not existing yet, create target directory
        if (!Files.isDirectory(TARGET_UPLOAD_DIRECTORY))
        {
            Files.createDirectory(TARGET_UPLOAD_DIRECTORY);
        }

        Map params = request.getParameterMap();
        Iterator i = params.keySet().iterator();

        while(i.hasNext())
        {
            String key = (String)i.next();
            String value = ((String[])params.get(key))[0];

            // it's a checkbox with a supplier
            if (key.contains(FORM_PREFIX_SSR))
            {
                response.getWriter().print("<p>found checked shop-supplier-checkbox</p>");

                // write to share
                for (Part part : request.getParts())
                {
                    part.write(TARGET_UPLOAD_DIRECTORY.resolve(key + fileName).toString());
                }

            }

            response.getWriter().print("<p>" + key + " | " + value + "</p>");
        }

        /**
         * 
         * ICM2IOMTransformer
         * 
         */

        BlueprintProductTransformer transformer = new BlueprintProductTransformer();
        // transformer.transform(parameters, dirStructure, state, index);

        // import file
        // Part filePart = request.getPart("file");
        // String fileName = filePart.getSubmittedFileName();

        // run transformer and put files to configured standard import API

        // write to share
        // for (Part part : request.getParts())
        // {
        // part.write(TARGET_UPLOAD_DIRECTORY.resolve(fileName).toString());
        // }
        response.getWriter().print("<html><head></head><body>");
        response.getWriter().print("File '" + fileName + "' uploaded sucessfully ...");
        response.getWriter().print(
                        "<br><br> ... want to do one more import? -> <a href=\"ProductUpload\">one more upload</a>");
        response.getWriter().print("</body></html");
    }

    /**
     * Determines the desired stock from the html-form parameters. If empty or failed, return 250.
     * 
     * @param request
     * @return
     */
    private int getStock(HttpServletRequest request)
    {
        String stock = request.getParameter("stock");
        try
        {
            return Integer.parseInt(stock);
        }
        catch(NumberFormatException e)
        {
            return 250;
        }
    }

}
