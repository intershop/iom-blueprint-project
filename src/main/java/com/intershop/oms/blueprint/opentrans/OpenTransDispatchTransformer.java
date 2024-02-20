package com.intershop.oms.blueprint.opentrans;

import bakery.logic.job.file.FileTransferTransformationDirectories;
import bakery.logic.job.transformation.Transformer;
import bakery.persistence.dataobject.exit.ExitCodeDefDO;
import bakery.persistence.dataobject.job.JobRunState;
import bakery.persistence.dataobject.job.JobStateDefDO;
import bakery.persistence.dataobject.transformer.TransformerProcessParameterKeyDefDO;
import bakery.persistence.dataobject.transformer.TransformerProcessesParameterDO;
import bakery.persistence.job.file.Retry;
import bakery.util.exception.DatabaseException;
import bakery.util.exception.MissingConfigurationException;
import bakery.util.exception.TechnicalException;
import bakery.util.exception.ValidationException;
import com.intershop.oms.ps.util.CustomizationUtilityStatic;
import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.JAXBElement;
import jakarta.xml.bind.JAXBException;
import jakarta.xml.bind.UnmarshalException;
import jakarta.xml.bind.Unmarshaller;
import org.opentrans.xmlschema._2.DISPATCHNOTIFICATION;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;

import javax.xml.XMLConstants;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URL;
import java.nio.file.Path;
import java.util.List;
import java.util.regex.Pattern;

@Stateless
public class OpenTransDispatchTransformer implements Transformer
{

    private static final Logger log = LoggerFactory.getLogger(OpenTransDispatchTransformer.class);

    @EJB
    private OpenTransDeliveryMessageBean deliveryMessageBean;

    @Override
    public void transform(List<TransformerProcessesParameterDO> parameters,
                    FileTransferTransformationDirectories dirStructure, JobRunState state, int index)
                    throws Retry, MissingConfigurationException
    {
        boolean hasErrors = false;
        boolean hasSuccess = false;
        String errorText = "";
        File[] importFiles = dirStructure.getTransformDir().listFiles();
        Path doneDir = dirStructure.getDoneDir().toPath();
        Path errorDir = dirStructure.getErrorDir().toPath();
        Path currentImportFilePath;
        String regex = getRegex(parameters);

        URL xsd = Thread.currentThread().getContextClassLoader()
                        .getResource("xsd/opentrans/opentrans_2_1.xsd");

        for (File currentImportFile : importFiles)
        {

            if (!currentImportFile.canRead())
            {
                hasErrors = true;
                errorText = errorText.concat(
                                "Encountered file without \"read\" permissions: " + currentImportFile.getName() + "\n");
                continue;
            }

            currentImportFilePath = currentImportFile.toPath();

            if (!Pattern.matches(regex, currentImportFile.getName()))
            {
                continue;
            }

            try
            {
                DISPATCHNOTIFICATION desadv = unmarshallAndValidateFile(currentImportFile, xsd,
                                DISPATCHNOTIFICATION.class);
                deliveryMessageBean.handleDispatch(desadv);
                CustomizationUtilityStatic.moveProcessedFile(currentImportFilePath, doneDir);
                hasSuccess = true;
            }

            catch(ValidationException | SAXException | UnmarshalException e)
            {
                // ValidationException for logical / contextual problems during
                // mapping, UnmarshalException for syntactical issues (import
                // file is invalid according to the schema)
                hasErrors = true;
                errorText = errorText.concat("Error (syntactical or logical) during mapping while processing file: "
                                + currentImportFile.getName() + " --> " + e.getMessage() + "\n");
                log.error("Error: ", e);
                CustomizationUtilityStatic.moveProcessedFile(currentImportFilePath, errorDir);
            }
            catch(JAXBException | IOException | DatabaseException e)
            {
                // when this happens, something is wrong with the code or
                // database - not the xml
                hasErrors = true;
                errorText = errorText.concat(
                                "Exception caused by Transformer/Unmarshaller/PersistenceService Implementation --> "
                                                + e.getMessage() + "\n");
                log.error("Error: ", e);
                CustomizationUtilityStatic.moveProcessedFile(currentImportFilePath, errorDir);
            }
            catch(Exception e)
            {
                hasErrors = true;
                errorText = errorText.concat(
                                "Error (technical) while processing file: " + currentImportFile.getName() + " --> "
                                                + e.getMessage() + "\n");
                log.error("Error: ", e);
                CustomizationUtilityStatic.moveProcessedFile(currentImportFilePath, errorDir);
            }

        }

        if (hasErrors)
        {
            if (hasSuccess)
            {
                state.setError(ExitCodeDefDO.WARN, JobStateDefDO.PROCESSED, errorText);
            }
            else
            {
                state.setError(ExitCodeDefDO.ERROR, JobStateDefDO.PROCESS_ERROR, errorText);
            }
        }
        else
        {
            state.setExitCodeDefDO(ExitCodeDefDO.OK);
            state.setJobStateDefDO(JobStateDefDO.PROCESSED);
        }

    }

    private static String getRegex(List<TransformerProcessesParameterDO> parameters)
    {

        for (TransformerProcessesParameterDO transformerProcessesParameterDO : parameters)
        {

            if (transformerProcessesParameterDO.getTransformerProcessesParameterKeyDefDO()
                            .equals(TransformerProcessParameterKeyDefDO.SOURCE_FILENAME))
            {

                if (null != transformerProcessesParameterDO.getParameterValue())
                {
                    return transformerProcessesParameterDO.getParameterValue();
                }

            }
        }
        throw new TechnicalException(
                        new MissingConfigurationException("The (mandatory) filename regex is not configured"));
    }

    private <T> T unmarshallAndValidateFile(File xmlFile, URL xsdFile, Class<T> returnType)
                    throws JAXBException, SAXException, IOException
    {
        SchemaFactory sf = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
        sf.setFeature("http://apache.org/xml/features/honour-all-schemaLocations", true);
        Schema schema = sf.newSchema(xsdFile);
        JAXBContext jaxbContext = JAXBContext.newInstance(returnType);
        Unmarshaller unmarshaller = jaxbContext.createUnmarshaller();
        unmarshaller.setSchema(schema);

        T javaObject = null;
        JAXBElement<T> jaxbElement;

        try (FileInputStream input = new FileInputStream(xmlFile);)
        {
            jaxbElement = unmarshaller.unmarshal(new StreamSource(input), returnType);
        }

        javaObject = jaxbElement.getValue();

        return javaObject;
    }
}
