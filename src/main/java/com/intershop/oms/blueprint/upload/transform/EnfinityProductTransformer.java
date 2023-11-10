package com.intershop.oms.blueprint.upload.transform;

import java.io.InputStream;
import java.nio.file.Path;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;

import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.JAXBElement;
import jakarta.xml.bind.JAXBException;
import jakarta.xml.bind.Unmarshaller;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.utils.configuration.IOMSharedFileSystem;
import com.intershop.xml.ns.enfinity._7_1.xcs.impex.ComplexTypeProduct;
import com.intershop.xml.ns.enfinity._7_1.xcs.impex.Enfinity;

import bakery.util.exception.TechnicalException;

/**
 * Transformer to be used for files previously uploaded by ProductUpload-servlet.
 */
public abstract class EnfinityProductTransformer
{
    private static final Logger log = LoggerFactory.getLogger(EnfinityProductTransformer.class);

    private final Path TARGET_IMPORT_IN = IOMSharedFileSystem.IMPORTARTICLE_IN.toPath();

    public void transform(Long shopId, List<Long> supplierIds, InputStream inputStream)
    {
        SimpleDateFormat sdfFilename = new SimpleDateFormat("yyyyMMddHHmmss");
        Long importStartDate = System.currentTimeMillis();

        initialize(shopId, supplierIds, TARGET_IMPORT_IN);

        log.debug("Starting transformation");

        boolean hasErrors = false;
        StringBuilder errorText = new StringBuilder();

        JAXBContext jaxbContext;
        Unmarshaller um;
        try
        {
            jaxbContext = JAXBContext.newInstance(Enfinity.class);
            um = jaxbContext.createUnmarshaller();

        }
        catch(JAXBException e)
        {
            throw new TechnicalException(e);
        }

        XMLInputFactory xmlFactory = XMLInputFactory.newInstance();

        String datePrefix = sdfFilename.format(new Date(importStartDate + TimeUnit.SECONDS.toMillis(0)));
        log.info("date prefix: {}", datePrefix);
        preFileHook(datePrefix);

        // read the input
        try
        {
            XMLStreamReader reader = xmlFactory.createXMLStreamReader(inputStream);
            while(reader.hasNext())
            {
                reader.next();
                if (reader.isStartElement()
                                && (reader.getLocalName().equals("product") || reader.getLocalName().equals("offer")))
                {
                    JAXBElement<ComplexTypeProduct> prodElem = um.unmarshal(reader, ComplexTypeProduct.class);
                    ComplexTypeProduct prod = prodElem.getValue();
                    hasErrors = !processProduct(prod);
                }
            }

            reader.close();
        }
        catch(XMLStreamException | JAXBException e)
        {
            hasErrors = true;
            log.error("unexpected error", e);
        }

        postFileHook();

        if (hasErrors)
        {
            log.error("Error while importing product file", errorText.toString());
        }
        else
        {
            log.info("Successfully imported product file");
        }

        destroy();

        log.debug("End of transformations");
    }

    /**
     * pre execution hook to initialize product data transformers with necessary parameters
     * 
     * @param shopId
     * @param supplierIds
     * @param toParse
     */
    protected abstract void initialize(Long shopId, List<Long> supplierIds, Path toParse);

    /**
     * hook executed before every input file
     *
     * @param datePrefix
     *            date string that can be used to create the filename for output. it's changed for every new input file.
     */
    protected abstract void preFileHook(String datePrefix);

    /**
     * ICM products should be mapped and written to the output in this step
     *
     * @param product
     * @return
     */
    protected abstract boolean processProduct(ComplexTypeProduct product);

    /**
     * hook executed after the current input file
     */
    protected abstract void postFileHook();

    /**
     * hook executed right at the end of the transformer process
     */
    protected abstract void destroy();
}
