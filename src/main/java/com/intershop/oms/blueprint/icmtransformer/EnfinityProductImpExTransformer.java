package com.intershop.oms.blueprint.icmtransformer;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Path;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.regex.Pattern;

import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.JAXBElement;
import jakarta.xml.bind.JAXBException;
import jakarta.xml.bind.Unmarshaller;

import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.ps.util.CustomizationUtilityStatic;
import com.intershop.xml.ns.enfinity._7_1.xcs.impex.ComplexTypeProduct;
import com.intershop.xml.ns.enfinity._7_1.xcs.impex.Enfinity;

import bakery.logic.job.file.FileTransferTransformationDirectories;
import bakery.logic.job.transformation.Transformer;
import bakery.persistence.dataobject.exit.ExitCodeDefDO;
import bakery.persistence.dataobject.job.JobRunState;
import bakery.persistence.dataobject.job.JobStateDefDO;
import bakery.persistence.dataobject.transformer.TransformerProcessParameterKeyDefDO;
import bakery.persistence.dataobject.transformer.TransformerProcessesParameterDO;
import bakery.persistence.job.file.Retry;
import bakery.util.exception.MissingConfigurationException;
import bakery.util.exception.TechnicalException;

/**
 * Transformer to be used for files previously uploaded via direct FTP.
 */
public abstract class EnfinityProductImpExTransformer implements Transformer
{
    private static final Logger log = LoggerFactory.getLogger(EnfinityProductImpExTransformer.class);

    @Override
    public void transform(List<TransformerProcessesParameterDO> parameters,
                    FileTransferTransformationDirectories dirStructure, JobRunState state, int index)
                    throws Retry, MissingConfigurationException
    {
        state.setExitCodeDefDO(ExitCodeDefDO.OK);
        state.setJobStateDefDO(JobStateDefDO.SUCCEEDED);

        SimpleDateFormat sdfFilename = new SimpleDateFormat("yyyyMMddHHmmss");
        Long importStartDate = state.getStartDate() != null ? state.getStartDate().getTime()
                        : System.currentTimeMillis();
        initialize(parameters, dirStructure);
        log.debug("Start of transfomation");

        boolean hasErrors = false;
        StringBuilder errorText = new StringBuilder();
        Path doneDir = dirStructure.getDoneDir().toPath();
        Path errorDir = dirStructure.getErrorDir().toPath();

        /*
         * check for parameter list
         */
        if (parameters == null || parameters.isEmpty())
        {
            throw new MissingConfigurationException("Transformer is not configured");
        }

        String xmlFileRegex = this.getFileNameFromParameters(parameters,
                        TransformerProcessParameterKeyDefDO.SOURCE_FILENAME);

        if (xmlFileRegex == null)
        {
            throw new MissingConfigurationException("xml export file type is mandatory!");
        }

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

        List<File> importFiles = this.getImportFiles(Arrays.asList(dirStructure.getTransformDir().listFiles()),
                        xmlFileRegex, errorText);
        int fileCount = 0;
        for (File importFile : importFiles)
        {
            String datePrefix = sdfFilename.format(new Date(importStartDate + TimeUnit.SECONDS.toMillis(fileCount++)));
            log.info("date prefix: {}", datePrefix);
            preFileHook(datePrefix);

            Path importFilePath = importFile.toPath();

            try (FileReader fr = new FileReader(importFile))
            {
                XMLStreamReader reader = xmlFactory.createXMLStreamReader(fr);
                while(reader.hasNext())
                {
                    reader.next();
                    if (reader.isStartElement() && (reader.getLocalName().equals("product")
                                    || reader.getLocalName().equals("offer")))
                    {
                        JAXBElement<ComplexTypeProduct> prodElem = um.unmarshal(reader, ComplexTypeProduct.class);
                        ComplexTypeProduct prod = prodElem.getValue();
                        hasErrors = !processProduct(prod);

                    }
                }

                reader.close();
            }
            catch(XMLStreamException | JAXBException | IOException e)
            {
                hasErrors = true;
                log.error("unexpected error", e);
            }

            postFileHook();

            if (hasErrors)
            {
                state.setError(ExitCodeDefDO.ERROR, JobStateDefDO.PROCESS_ERROR, errorText.toString());
                state.setJobStateDefDO(JobStateDefDO.PROCESS_ERROR);
                CustomizationUtilityStatic.moveProcessedFile(importFilePath, errorDir);
            }
            else
            {
                CustomizationUtilityStatic.moveProcessedFile(importFilePath, doneDir);
            }

        }

        destroy();

        log.debug("End of transformations");

    }

    private String getFileNameFromParameters(List<TransformerProcessesParameterDO> parameters,
                    TransformerProcessParameterKeyDefDO transformerProcessParameterKeyDefDO)
    {
        for (TransformerProcessesParameterDO transformerProcessesParameterDO : parameters)
        {
            if (transformerProcessesParameterDO.getTransformerProcessesParameterKeyDefDO()
                            .equals(transformerProcessParameterKeyDefDO)
                            && (null != transformerProcessesParameterDO.getParameterValue()))
            {
                return transformerProcessesParameterDO.getParameterValue();
            }
        }
        return null;
    }

    private List<File> getImportFiles(List<File> importFiles, String regex, StringBuilder errorText)
    {
        List<File> matchingFiles = new ArrayList<>();
        Pattern pattern = Pattern.compile(regex);
        for (File currentImportFile : importFiles)
        {
            if (pattern.matcher(currentImportFile.getName()).matches())
            {
                if (!currentImportFile.exists())
                {
                    errorText.append("Encountered file doesn't exist: " + currentImportFile.getName() + "\n");
                    continue;
                }

                if (!currentImportFile.canRead())
                {
                    errorText.append("Encountered file without \"read\" permissions: " + currentImportFile.getName()
                                    + "\n");
                    continue;
                }

                matchingFiles.add(currentImportFile);
            }
        }
        return matchingFiles;
    }

    /**
     * pre execution hook to initialize product data transformers with necessary
     * parameters
     *
     * @param parameters
     * @param dirStructure
     */
    protected abstract void initialize(List<TransformerProcessesParameterDO> parameters,
                    FileTransferTransformationDirectories dirStructure);

    /**
     * hook executed before every input file
     *
     * @param datePrefix
     *            date string that can be used to create the filename for
     *            output. it's changed for every new input file.
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
