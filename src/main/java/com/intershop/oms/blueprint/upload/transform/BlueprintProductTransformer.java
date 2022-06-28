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
import bakery.persistence.dataobject.job.JobRunState;
import bakery.persistence.dataobject.transformer.TransformerProcessParameterKeyDefDO;
import bakery.persistence.dataobject.transformer.TransformerProcessesParameterDO;
import bakery.persistence.job.file.Retry;
import bakery.persistence.service.configuration.ShopPersistenceService;
import bakery.util.exception.DatabaseException;
import bakery.util.exception.MissingConfigurationException;
import bakery.util.exception.NoObjectException;
import bakery.util.exception.TechnicalException;

@Stateless
public class BlueprintProductTransformer extends EnfinityProductTransformer
{
    private static final Logger log = LoggerFactory.getLogger(BlueprintProductTransformer.class);
    private static final char ESCAPE_CHAR = '\u0015';

    private String currentFilePrefix = "";
    private Map<Long, CSVPrinter> basicDataPrinters = null;
    private Map<String, Long> supplierMapping = null;
    private Path transformDir = null;
    private Long shopId;

    @Override
    protected void initialize(Long shopId, List<Long> supplierIds, Path targetDirectory)
    {
        // initialize supplier mapping for this shop based on s2s.shopSupplierName
        supplierMapping = new HashMap<>();

        this.shopId = shopId;

        supplierIds.forEach(s -> supplierMapping.put(s.toString(), s));

        transformDir = targetDirectory;
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
        CSVRecord<BasicDataCSV> rec = new CSVRecord<>(BasicDataCSV.class);
        String sku = "skuToFind";
        // ProductCustomAttributes ca = new ProductCustomAttributes();

        for (JAXBElement<?> elem : product.getAvailableOrNameOrShortDescription())
        {
            // note: due to the weird data structures in ICM and weird code
            // generation we have to look at the localName attribute of the XML
            // tags and cast it to the correct class
            switch(elem.getName().getLocalPart())
            {
                case "sku":
                    sku = (String)elem.getValue();
                    rec.setNotBlank(BasicDataCSV.supplierArticleNo, sku);
                    rec.setNotBlank(BasicDataCSV.manufacturerArticleNo, sku);
                    sku = (String)elem.getValue();
                    break;
                case "name":
                    rec.setNotBlank(BasicDataCSV.articleName,
                                    ((ComplexTypeGenericAttributeString)elem.getValue()).getValue());
                    break;
                case "manufacturer":
                    rec.setNotBlank(BasicDataCSV.manufacturer,
                                    ((ComplexTypeProductManufacturer)elem.getValue()).getManufacturerName());
                    break;
                default:
                    break;
            }
        }

        rec.setNotBlank(BasicDataCSV.supplierArticleIdentifier, sku); // use same sku as found before

        for (String supplierName : supplierMapping.keySet())
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
