package com.intershop.oms.blueprint.email;

import java.util.ArrayList;
import java.util.List;

import jakarta.ejb.EJB;
import jakarta.ejb.Stateless;
import jakarta.mail.MessagingException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.intershop.oms.enums.expand.ExpandedExecutionBeanKeyDefDO;
import com.intershop.oms.enums.expand.ExpandedTransmissionTypeDefDO;

import bakery.logic.service.exception.MissingFieldException;
import bakery.logic.service.mail.ShopCustomerMailLogicService;
import bakery.logic.service.mail.ShopCustomerMailTransmissionLogicService;
import bakery.logic.service.transmission.MessageTransmitter;
import bakery.logic.usermailobject.UserMailLO;
import bakery.logic.util.TemplateTransformerUtil;
import bakery.logic.valueobject.ProcessContainer;
import bakery.mail.service.ExternalMailService;
import bakery.mail.valueObject.ExternalMail;
import bakery.persistence.dataobject.common.InitiatorDefDO;
import bakery.persistence.dataobject.configuration.common.ProcessDefDO;
import bakery.persistence.dataobject.configuration.user.UserDO;
import bakery.persistence.dataobject.mail.ShopCustomerMailTransmissionDO;
import bakery.persistence.dataobject.order.AbstractTransmission;
import bakery.persistence.dataobject.order.OrderDO;
import bakery.persistence.expand.TransmissionTypeDefDOEnumInterface;
import bakery.persistence.service.configuration.TransformerPersistenceService;
import bakery.util.StringUtils;
import bakery.util.exception.ConfigurationException;
import bakery.util.exception.NoObjectException;
import bakery.util.exception.TechnicalException;
import bakery.util.exception.ValidationException;
 
@Stateless
public class AnotherMailTransmitterBean implements MessageTransmitter 
{
    private static Logger log = LoggerFactory.getLogger(AnotherMailTransmitterBean.class);

    @EJB( mappedName = ShopCustomerMailLogicService.LOGIC_SHOPCUSTOMERMAILLOGICBEAN )
    private ShopCustomerMailLogicService shopCustomerMailLogicService;

    @EJB( mappedName = ShopCustomerMailTransmissionLogicService.LOGIC_SHOPCUSTOMERMAILTRANSMISSIONLOGICBEAN )
    private ShopCustomerMailTransmissionLogicService shopCustomerMailTransmissionLogicService;

    @EJB( mappedName = ExternalMailService.MAIL_EXTERNALMAILBEAN )
    private ExternalMailService externalMailService;
    
    // get persistent mail configurations
    // unused yet, use it if you have configured templates in the database to be used
    @EJB(lookup = TransformerPersistenceService.PERSISTENCE_TRANSFORMERPERSISTENCEBEAN)
    private TransformerPersistenceService transformerPersistenceService;
    
    // util to transform velocity templates i.g. retrieved from persisted mail configurations
    // unused yet, use it if you have configured templates in the database to be used
    @EJB(lookup = TemplateTransformerUtil.JNDI_LOGIC_TEMPLATETRANSFORMERUTIL)
    private TemplateTransformerUtil templateTransformerUtil;
 
    private List<ConfigurationException> configurationExceptionList;

    @Override
    public AbstractTransmission transmit(AbstractTransmission transmission)
    {
        if (transmission == null || !(transmission instanceof ShopCustomerMailTransmissionDO))
        {
            throw new TechnicalException("illegal transmissiont type");
        }
        ShopCustomerMailTransmissionDO shopCustomerMailTransmissionDO = (ShopCustomerMailTransmissionDO)transmission;
        UserMailLO userMailLO = null;
        OrderDO orderDO = null;
        try
        {
            TransmissionTypeDefDOEnumInterface transmissionTypeDefDO = shopCustomerMailTransmissionDO
                            .getTransmissionTypeDefDO();

            if (transmissionTypeDefDO == ExpandedTransmissionTypeDefDO.APPROVAL_NOTIFICATION)
            {
                orderDO = shopCustomerMailTransmissionDO.getOrderDO();
                userMailLO = this.shopCustomerMailLogicService.createShopUserMailOrderLO(orderDO.getId());
            }
            else
            {
                String message = "No handling found for transmission type in CustomMailTransmitterBean: " + transmissionTypeDefDO.getFieldName() ;
                throw new TechnicalException(message);
            }

        }
        catch(NoObjectException  e)
        {
            throw new TechnicalException("Error while creating UserMailLO", e);
        }
        configurationExceptionList = new ArrayList<>();

        // get transmission parameters
        String senderMailAddress = MessageTransmitter.getCheckedConfigurationValue(shopCustomerMailTransmissionDO,
                        ExpandedExecutionBeanKeyDefDO.SHOPCUSTOMERMAILSENDERBEAN_SHOP_EMAIL_ADDRESS, configurationExceptionList);
        String senderName = MessageTransmitter.getCheckedConfigurationValue(shopCustomerMailTransmissionDO,
                        ExpandedExecutionBeanKeyDefDO.SHOPCUSTOMERMAILSENDERBEAN_SHOP_EMAIL_SENDERNAME, configurationExceptionList);
        String mimeType = MessageTransmitter.getCheckedConfigurationValue(shopCustomerMailTransmissionDO,
                        ExpandedExecutionBeanKeyDefDO.MIME_TYPE, configurationExceptionList);

        // check required parameters
        checkConfiguration();
        if (senderName==null)
        {
            senderName = "your better shop";
        }

        // get receiver address
        String receiverMailAddress = userMailLO.getReceiverMailAddress();
        
        String subject = "Order " + orderDO.getId();
        String message =  "Order " + orderDO.getId() + " is in approval";
        // optional - prevent exception if not configured
        String plainTextMessage = "Order " + orderDO.getId() + " is in approval";;

        // Store address and content at ShopCustomerMailTransmissionDO.
        // Replace existing address if was set before.
        String shopCustomerMailAddress = shopCustomerMailTransmissionDO.getReceiverMailAddress();

        if (StringUtils.isEmpty(shopCustomerMailAddress))
        {
            shopCustomerMailTransmissionDO.setReceiverMailAddress(receiverMailAddress);
        }
        else
        {
            receiverMailAddress = shopCustomerMailAddress;
        }

        shopCustomerMailTransmissionDO.setSubject(subject);
        shopCustomerMailTransmissionDO.setMessage(message);
        shopCustomerMailTransmissionDO.setPlainTextMessage(plainTextMessage);

        // update ShopCustomerMailTransmissionDO
        ShopCustomerMailTransmissionDO updatedShopCustomerMailTransmissionDO = this.shopCustomerMailTransmissionLogicService
                        .updateShopCustomerMailTransmissionDO(shopCustomerMailTransmissionDO);

        // send mail only if receiver address is not empty
        if (!StringUtils.isEmpty(receiverMailAddress))
        {
            // create mail
            ExternalMail userMail = createExternalMail(senderMailAddress, senderName, receiverMailAddress,
                            null, subject, message, plainTextMessage, mimeType);

            // send mail
            try
            {
                externalMailService.mail(userMail);
            }
            catch(MessagingException e)
            {
                throw new TechnicalException("Error while sending email.", e);
            }
        }
        else
        {
           // Throw exception 
            MissingFieldException missingFieldException = new MissingFieldException("receiverMailAddress");
            ValidationException validationException = new ValidationException(updatedShopCustomerMailTransmissionDO);
            validationException.getExceptionList().add(missingFieldException);
            throw new TechnicalException(validationException);
        }

        // create process container
        ProcessContainer processContainer = new ProcessContainer(null, false, true, UserDO.BATCH_USER_ID,
                        InitiatorDefDO.BATCH);
        processContainer.addMessageIdMap(ProcessDefDO.SHOPCUSTOMERMAILTRANSMISSIONEDQUEUE, updatedShopCustomerMailTransmissionDO.getId());

        return transmission;
    }

    /**
     * @see bakery.logic.communication.out.MessageSender#getTransmissionMedium()
     */
    @Override
    public String getTransmissionMedium()
    {
        return TransmissionMedium.Email.name();
    }

    /**
     * Creates a {@see ExternalMail} using the given.
     * 
     * @param senderMailAddress
     * @param senderName
     * @param receiverMailAddress
     * @param bccMailAddress
     * @param subject
     * @param message
     * @param plainTextMessage
     * @param mimeType
     */
    private ExternalMail createExternalMail(String senderMailAddress, String senderName,
                    String receiverMailAddress, String bccMailAddress, String subject, String message,
                    String plainTextMessage, String mimeType)
    {
        ExternalMail externalMail = new ExternalMail();
        
        if (log.isDebugEnabled())
        {
            log.debug("SendUserMailPTBean - create ExternalMail:");
            log.debug("Sender: " + senderMailAddress);
            log.debug("Sender name: " + senderName);
            log.debug("Receiver: " + receiverMailAddress);
            log.debug("BCC: " + bccMailAddress);
            log.debug("Subject: " + subject);
            log.debug("Message: " + message);
            log.debug("PlainTextMessage: " + plainTextMessage);
            log.debug("MIME type: " + mimeType);
        }

        externalMail.setFromAddress(senderMailAddress);
        externalMail.setFromPersonalName(senderName);
        externalMail.addToAddress(receiverMailAddress);

        if (bccMailAddress != null)
        {
            externalMail.addBCCAddress(bccMailAddress);
        }

        // set subject and contents
        externalMail.setSubject(subject);
        externalMail.setText(message);
        externalMail.setPlainText(plainTextMessage);
        
        externalMail.setMimeType(mimeType);

        return externalMail;
    }


    protected void checkConfiguration() throws ConfigurationException
    {
        if ((configurationExceptionList != null) && (configurationExceptionList.size() > 0))
        {
            /*
             * Exceptions ausgeben
             */
            for (ConfigurationException configurationException : configurationExceptionList)
            {
                log.error(configurationException.getMessage());
            }

            ConfigurationException configurationException = new ConfigurationException();
            configurationException.getExceptionList().addAll(configurationExceptionList);

            throw configurationException;
        }
    }

}
