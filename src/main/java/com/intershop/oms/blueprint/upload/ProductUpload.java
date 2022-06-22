package com.intershop.oms.blueprint.upload;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
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
// import com.intershop.oms.utils.configuration.IOMSharedFileSystem;

@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
                maxFileSize = 1024 * 1024 * 10, // 10 MB
                maxRequestSize = 1024 * 1024 * 100 // 100 MB
)
public class ProductUpload extends HttpServlet
{
    // private final Path TARGET_UPLOAD_DIRECTORY = IOMSharedFileSystem.OMS_SHARE.resolve("tmp");
    // private final Path TARGET_IMPORT_IN = IOMSharedFileSystem.IMPORTARTICLE_IN.toPath();
    private final String FORM_ID_SEPARATOR = "_";
    private final String FORM_PREFIX_SSR = "ssr" + FORM_ID_SEPARATOR;

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
                dom.append(createCheckbox(
                                "ssr" + FORM_ID_SEPARATOR + shopDO.getId() + FORM_ID_SEPARATOR + supplierDO.getId(),
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
        return "<input type=\"checkbox\" name=\"" + id + "\" value=\"" + id + "\" " + checked + "><label for=\"" + id
                        + "\">" + displayname + "</label><br>";
    }

    /**
     * Accepts a html-form containing a product file and several options to import.
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        Part uploadedFile = request.getPart("file");

        /**
         * Transform
         */
        BlueprintProductTransformer transformer = new BlueprintProductTransformer();
        
        for (Long shopId : getShopAndSuppliers(request).keySet()) 
        {
            transformer.transform(shopId,  getShopAndSuppliers(request).get(shopId), getStock(request), uploadedFile.getInputStream());
        }
      
        /**
         * Servlet response
         */
        request.getPart("file");
        response.getWriter().print("<html><head></head><body>");
        response.getWriter().print("File '" + uploadedFile.getSubmittedFileName() + "' uploaded sucessfully ...");
        response.getWriter().print("Desired stock '" + getStock(request) + ".");
        response.getWriter().print("Desired suppliers '" + getShopAndSuppliers(request) + ".");
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

    /**
     * Determines the desired suppliers (and their leading shop) from the html-form parameters.
     * 
     * @param request
     * @return
     */
    private Map<Long, List<Long>> getShopAndSuppliers(HttpServletRequest request)
    {
        Map<Long, List<Long>> shopSuppliersMap = new HashMap<>();
        Map params = request.getParameterMap();
        Iterator i = params.keySet().iterator();

        while(i.hasNext())
        {
            String key = (String)i.next();

            // it's a checkbox with a supplier (and a shop) -> prefix_shopId_supplierId
            if (key.startsWith(FORM_PREFIX_SSR))
            {
                String[] ids = key.split(FORM_ID_SEPARATOR); // -> prefix_shopId_supplierId
                Long shopId = Long.valueOf(ids[1]);
                Long supplierId = Long.valueOf(ids[2]);

                if (shopSuppliersMap.containsKey(shopId))
                {
                    // put additional supplier
                    List<Long> supplierIds = shopSuppliersMap.get(shopId);
                    if (!supplierIds.contains(supplierId))
                    {
                        supplierIds.add(supplierId);
                        shopSuppliersMap.put(shopId, supplierIds);
                    }

                }
                else
                {
                    // put (first) shop and first supplier
                    List<Long> supplierIds = new ArrayList<Long>();
                    supplierIds.add(supplierId);
                    shopSuppliersMap.put(shopId, supplierIds);
                }
            }
        }

        return shopSuppliersMap;
    }

}
