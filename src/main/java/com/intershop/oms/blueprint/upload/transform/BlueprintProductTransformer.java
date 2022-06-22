package com.intershop.oms.blueprint.upload.transform;

import static org.apache.commons.lang3.StringUtils.isNotBlank;

import java.io.IOException;
import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.ejb.EJB;
import javax.ejb.Stateless;
import javax.servlet.http.Part;
import javax.xml.bind.JAXBElement;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.utils.configuration.IOMSharedFileSystem;
// import com.intershop.oms.blueprint.atp.model.ProductCustomAttributes;
import com.intershop.xml.ns.enfinity._7_1.xcs.impex.ComplexTypeCustomAttribute;
import com.intershop.xml.ns.enfinity._7_1.xcs.impex.ComplexTypeCustomAttributes;
import com.intershop.xml.ns.enfinity._7_1.xcs.impex.ComplexTypeGenericAttributeString;
import com.intershop.xml.ns.enfinity._7_1.xcs.impex.ComplexTypeMultipleCustomAttributeValue;
import com.intershop.xml.ns.enfinity._7_1.xcs.impex.ComplexTypeProduct;
import com.intershop.xml.ns.enfinity._7_1.xcs.impex.ComplexTypeProductManufacturer;
import com.intershop.xml.ns.enfinity._7_1.xcs.impex.ComplexTypeProductProductLink;
import com.intershop.xml.ns.enfinity._7_1.xcs.impex.ComplexTypeProductProductLinks;

import bakery.logic.job.file.FileTransferTransformationDirectories;
import bakery.persistence.dataobject.configuration.shop.ShopDO;
import bakery.persistence.dataobject.transformer.TransformerProcessParameterKeyDefDO;
import bakery.persistence.dataobject.transformer.TransformerProcessesParameterDO;
import bakery.persistence.service.configuration.ShopPersistenceService;
import bakery.util.exception.DatabaseException;
import bakery.util.exception.MissingConfigurationException;
import bakery.util.exception.NoObjectException;
import bakery.util.exception.TechnicalException;

@Stateless
public class BlueprintProductTransformer extends EnfinityProductTransformer
{
    // private static final String CUSTOM_ATTRIBUTE_DEPOT_STOCKED = "depot-stocked";
    private static final Logger log = LoggerFactory.getLogger(BlueprintProductTransformer.class);
    private static final char ESCAPE_CHAR = '\u0015';
    // private static final String PRODUCT_LINK_TYPE_CASE = "MSG_Case";
    // private static final String CUSTOM_ATTRIBUTE_EACH_PER_CASE = "number-of-pack-units";

    @EJB(lookup = ShopPersistenceService.PERSISTENCE_SHOPPERSISTENCEBEAN)
    private ShopPersistenceService shopPersistenceService;

    private String currentFilePrefix = "";
    private Map<Long, CSVPrinter> basicDataPrinters = null;
    private Map<String, Long> supplierMapping = null;
    private Path transformDir = null;
    private Long shopId;

    @Override
    protected void initialize(List<TransformerProcessesParameterDO> parameters,
                    FileTransferTransformationDirectories dirStructure)
    {
        // initialize supplier mapping for this shop based on
        // s2s.shopSupplierName
        supplierMapping = new HashMap<>();
        Long shopId = parameters.stream()
                        .filter(par -> par.getTransformerProcessesParameterKeyDefDO()
                                        .equals(TransformerProcessParameterKeyDefDO.SHOP_ID))
                        .map(TransformerProcessesParameterDO::getParameterValue).map(Long::parseLong).findAny()
                        .orElseThrow(() -> new MissingConfigurationException("ShopId is mandatory"));
        this.shopId = shopId;
        ShopDO shopDO;
        try
        {
            shopDO = shopPersistenceService.getShopDO(shopId);
        }
        catch(DatabaseException | NoObjectException e)
        {
            throw new TechnicalException("error while getting shop", e);
        }

        shopDO.getSupplierList()
                        .forEach(s2s -> supplierMapping.put(s2s.getShopSupplierName(), s2s.getSupplierDO().getId()));

        transformDir = dirStructure.getTransformDir().toPath();
    }

    protected void initialize(Long shopId, List<Long> supplierIds, int stock, Part stream)
    {
        // initialize supplier mapping for this shop based on given html-form
        supplierMapping = new HashMap<>();

        this.shopId = shopId;
        ShopDO shopDO;
        try
        {
            shopDO = shopPersistenceService.getShopDO(shopId);
        }
        catch(DatabaseException | NoObjectException e)
        {
            throw new TechnicalException("error while getting shop", e);
        }

        shopDO.getSupplierList().stream().filter(s2s -> supplierIds.contains(s2s.getSupplierDO().getId())) // was
                                                                                                           // selected
                                                                                                           // in the
                                                                                                           // form
                        .forEach(s2s -> supplierMapping.put(s2s.getShopSupplierName(), s2s.getSupplierDO().getId()));

        // Import In
        // transformDir = dirStructure.getTransformDir().toPath();
        transformDir = IOMSharedFileSystem.IMPORTARTICLE_IN.toPath();
    }

    @Override
    protected void preFileHook(String datePrefix)
    {
        basicDataPrinters = new HashMap<>();
        currentFilePrefix = datePrefix;
    }

    @Override
    protected boolean processProduct(ComplexTypeProduct product)
    {
        Set<String> supplierNames = new HashSet<>();
        CSVRecord<BasicDataCSV> rec = new CSVRecord<>(BasicDataCSV.class);
        // ProductCustomAttributes ca = new ProductCustomAttributes();

        for (JAXBElement<?> elem : product.getAvailableOrNameOrShortDescription())
        {
            // note: due to the weird data structures in ICM and weird code
            // generation we have to look at the localName attribute of the XML
            // tags and cast it to the correct class
            switch(elem.getName().getLocalPart())
            {
                case "sku":
                    rec.setNotBlank(BasicDataCSV.supplierArticleNo, (String)elem.getValue());
                    rec.setNotBlank(BasicDataCSV.manufacturerArticleNo, (String)elem.getValue());
                    break;
                case "name":
                    rec.setNotBlank(BasicDataCSV.articleName,
                                    ((ComplexTypeGenericAttributeString)elem.getValue()).getValue());
                    break;
                // case "custom-attributes":
                // handleCustomAttributes((ComplexTypeCustomAttributes)elem.getValue(), rec, supplierNames, ca);
                // break;
                case "manufacturer":
                    rec.setNotBlank(BasicDataCSV.manufacturer,
                                    ((ComplexTypeProductManufacturer)elem.getValue()).getManufacturerName());
                    break;
                // case "product-links":
                // handleProductLinks((ComplexTypeProductProductLinks)elem.getValue(), ca);

                default:
                    break;
            }
        }

        // rec.setNotBlank(BasicDataCSV.supplierArticleIdentifier, ca.toString());
        rec.setNotBlank(BasicDataCSV.supplierArticleIdentifier, "TODO");

        for (String supplierName : supplierNames)
        {
            Long supplierId = supplierMapping.get(supplierName);
            if (supplierId == null)
            {
                log.trace("found unknown supplierName {}", supplierName);
                continue;
            }

            // closed in postFileHook
            @SuppressWarnings("resource")
            CSVPrinter printer = basicDataPrinters.computeIfAbsent(supplierId, this::createPrinter);

            try
            {
                printer.printRecord(rec.toIterator());
            }
            catch(IOException e)
            {
                log.error("unknown issue while printing the product", e);
            }

        }

        return true;
    }

    // private void handleProductLinks(ComplexTypeProductProductLinks links, ProductCustomAttributes ca)
    // {
    // for (ComplexTypeProductProductLink productLink : links.getProductLink())
    // {
    // if (productLink.getProductLinkType() != null
    // && PRODUCT_LINK_TYPE_CASE.equals(productLink.getProductLinkType().getName()))
    // {
    // ca.setCrateArticleLink(productLink.getSku());
    // return;
    // }
    // }
    // }

    private static String buildFilename(String shopId, String supplierId, String creationDate)
    {
        StringBuilder sb = new StringBuilder(shopId);
        sb.append("_");
        sb.append(supplierId);
        sb.append("_");
        sb.append(creationDate);
        sb.append("_ABC.csv");
        return sb.toString();
    }

    private CSVPrinter createPrinter(Long supplierId)
    {

        String fileName = buildFilename(shopId.toString(), supplierId.toString(), currentFilePrefix);

        try
        {
            // escape/quote/delimiter char = IOM default, only use unix line
            // ending
            return CSVFormat.DEFAULT.withHeader(BasicDataCSV.class).withDelimiter('|').withEscape(ESCAPE_CHAR)
                            .withQuote(ESCAPE_CHAR).withRecordSeparator('\n')
                            .print(transformDir.resolve(fileName), StandardCharsets.UTF_8);
        }
        catch(IOException e)
        {
            throw new TechnicalException(e);
        }
    }

    // private void handleCustomAttributes(ComplexTypeCustomAttributes value, CSVRecord<BasicDataCSV> rec,
    // Set<String> supplierNames, ProductCustomAttributes mappedAttributes)
    // {
    // for (ComplexTypeCustomAttribute ca : value.getCustomAttribute())
    // {
    // switch(ca.getName())
    // {
    // case CUSTOM_ATTRIBUTE_DEPOT_STOCKED:
    // for (Serializable ser : ca.getContent())
    // {
    // String supplierName = mapSerializableCA(ser);
    // if (isNotBlank(supplierName))
    // {
    // supplierNames.add(supplierName.toUpperCase());
    // }
    // }
    // break;
    // case CUSTOM_ATTRIBUTE_EACH_PER_CASE:
    // if (ca.getContent() != null && ca.getContent().size() > 0)
    // {
    // try
    // {
    // String eaPerCaseStr = mapSerializableCA(ca.getContent().get(0));
    // if (isNotBlank(eaPerCaseStr))
    // {
    // mappedAttributes.setCrateQuantity(Integer.valueOf(eaPerCaseStr));
    // }
    // }
    // catch(NumberFormatException nfe)
    // {
    // log.warn("invalid number format for EACH_PER_CASE attribute", nfe);
    // }
    // }
    // break;
    // }
    // }

    // }

    @SuppressWarnings("unchecked")
    private String mapSerializableCA(Serializable ser)
    {
        if (ser instanceof String)
        {
            return (String)ser;
        }
        else if (ser instanceof JAXBElement<?>)
        {
            return ((JAXBElement<ComplexTypeMultipleCustomAttributeValue>)ser).getValue().getValue();
        }
        return null;
    }

    @Override
    protected void postFileHook()
    {
        for (CSVPrinter printer : basicDataPrinters.values())
        {
            try
            {
                printer.close(true);
            }
            catch(IOException e)
            {
                log.error("error closing printer", e);
            }
        }
    }

    @Override
    protected void destroy()
    {
        // noop
    }

}
