package com.intershop.oms.enums.expand;

import bakery.persistence.dataobject.article.configuration.ImportConfigurationBeanDefDO;
import bakery.persistence.dataobject.article.export.ArticleExportConfigBeanDefDO;
import bakery.persistence.dataobject.common.PaymentDefDO;
import bakery.persistence.dataobject.configuration.common.ApprovalTypeDefDO;
import bakery.persistence.dataobject.configuration.common.DocumentMapperDefDO;
import bakery.persistence.dataobject.configuration.common.IdentCodeGenerationBeanDefDO;
import bakery.persistence.dataobject.configuration.common.NumberRangeFormatterDefDO;
import bakery.persistence.dataobject.configuration.common.OrderSupplierEvaluationRuleDefDO;
import bakery.persistence.dataobject.configuration.common.OrderValidationRuleDefDO;
import bakery.persistence.dataobject.configuration.connections.DecisionBeanDefDO;
import bakery.persistence.dataobject.configuration.connections.ExecutionBeanDefDO;
import bakery.persistence.dataobject.configuration.connections.ExecutionBeanKeyDefDO;
import bakery.persistence.dataobject.configuration.connections.MessageTypeDefDO;
import bakery.persistence.dataobject.configuration.connections.TransmissionTypeDefDO;
import bakery.persistence.dataobject.configuration.event.EventDefDO;
import bakery.persistence.dataobject.configuration.order.OrderExportConfigBeanDefDO;
import bakery.persistence.dataobject.configuration.process.ProcessTaskDefDO;
import bakery.persistence.dataobject.configuration.salesprice.SalesPriceCalculatorBeanDefDO;
import bakery.persistence.dataobject.job.JobDefDO;
import bakery.persistence.dataobject.transformer.TransformerBeanDefDO;

public final class ExpandEnumerations
{

    // increase this when adding new DefDOs
    public static final int DEFDO_COUNT = 20;

    private static ExpandedArticleExportConfigBeanDefDO[] enumValuesExpandedArticleExportConfigBeanDefDO = ExpandedArticleExportConfigBeanDefDO
                    .values();
    private static ExpandedDecisionBeanDefDO[] enumValuesExpandedDecisionBeanDefDO = ExpandedDecisionBeanDefDO.values();
    private static ExpandedDocumentMapperDefDO[] enumValuesExpandedDocumentMapperDefDO = ExpandedDocumentMapperDefDO.values();
    private static ExpandedExecutionBeanDefDO[] enumValuesExpandedExecutionBeanDefDO = ExpandedExecutionBeanDefDO
                    .values();
    private static ExpandedIdentCodeGenerationBeanDefDO[] enumValuesExpandedIdentCodeGenerationBeanDefDO = ExpandedIdentCodeGenerationBeanDefDO
                    .values();
    private static ExpandedImportConfigurationBeanDefDO[] enumValuesExpandedImportConfigurationBeanDefDO = ExpandedImportConfigurationBeanDefDO
                    .values();
    private static ExpandedOrderExportConfigBeanDefDO[] enumValuesExpandedOrderExportConfigBeanDefDO = ExpandedOrderExportConfigBeanDefDO
                    .values();
    private static ExpandedSalesPriceCalculatorBeanDefDO[] enumValuesExpandedSalesPriceCalculatorBeanDefDO = ExpandedSalesPriceCalculatorBeanDefDO
                    .values();
    private static ExpandedTransformerBeanDefDO[] enumValuesExpandedTransformerBeanDefDO = ExpandedTransformerBeanDefDO
                    .values();
    private static ExpandedExecutionBeanKeyDefDO[] enumValuesExpandedExecutionBeanKeyDefDO = ExpandedExecutionBeanKeyDefDO
                    .values();
    private static ExpandedApprovalTypeDefDO[] enumValuesExpandedApprovalTypeDefDO = ExpandedApprovalTypeDefDO.values();
    private static ExpandedOrderValidationRuleDefDO[] enumValuesExpandedOrderValidationRuleDefDO = ExpandedOrderValidationRuleDefDO
                    .values();
    private static ExpandedJobDefDO[] enumValuesExpandedJobDefDO = ExpandedJobDefDO.values();
    private static ExpandedOrderSupplierEvaluationRuleDefDO[] enumValuesExpandedOrderSupplierEvaluationRuleDefDO = ExpandedOrderSupplierEvaluationRuleDefDO
                    .values();
    private static ExpandedNumberRangeFormatterDefDO[] enumValuesExpandedNumberRangeFormatterDefDO = ExpandedNumberRangeFormatterDefDO
                    .values();
    private static ExpandedPaymentDefDO[] enumValuesExpandedPaymentDefDO = ExpandedPaymentDefDO.values();
    private static ExpandedMessageTypeDefDO[] enumValuesExpandedMessageTypeDefDO = ExpandedMessageTypeDefDO.values();
    private static ExpandedTransmissionTypeDefDO[] enumValuesExpandedTransmissionTypeDefDO = ExpandedTransmissionTypeDefDO
                    .values();
    private static ExpandedProcessTaskDefDO[] enumValuesExpandedProcessTaskDefDO = ExpandedProcessTaskDefDO.values();
    
    private static ExpandedEventDefDO[] enumValuesExpandedEventDefDO = ExpandedEventDefDO.values();

    private ExpandEnumerations()
    {
    }

    public static void expand()
    {

        for (ExpandedArticleExportConfigBeanDefDO value : enumValuesExpandedArticleExportConfigBeanDefDO)
        {
            ArticleExportConfigBeanDefDO.addArticleExportConfig(value);
        }
        for (ExpandedDecisionBeanDefDO value : enumValuesExpandedDecisionBeanDefDO)
        {
            DecisionBeanDefDO.addDecisionBean(value);
        }
        for (ExpandedDocumentMapperDefDO value : enumValuesExpandedDocumentMapperDefDO)
        {
            DocumentMapperDefDO.addDocumentMapperDefDO(value);
        }
        for (ExpandedIdentCodeGenerationBeanDefDO value : enumValuesExpandedIdentCodeGenerationBeanDefDO)
        {
            IdentCodeGenerationBeanDefDO.addIdentCodeGenerationBean(value);
        }
        for (ExpandedImportConfigurationBeanDefDO value : enumValuesExpandedImportConfigurationBeanDefDO)
        {
            ImportConfigurationBeanDefDO.addImportConfiguration(value);
        }
        for (ExpandedOrderExportConfigBeanDefDO value : enumValuesExpandedOrderExportConfigBeanDefDO)
        {
            OrderExportConfigBeanDefDO.addOrderExportConfigBean(value);
        }
        for (ExpandedSalesPriceCalculatorBeanDefDO value : enumValuesExpandedSalesPriceCalculatorBeanDefDO)
        {
            SalesPriceCalculatorBeanDefDO.addSalesPriceCalculator(value);
        }
        for (ExpandedExecutionBeanDefDO value : enumValuesExpandedExecutionBeanDefDO)
        {
            ExecutionBeanDefDO.addExecutionBean(value);
        }
        for (ExpandedTransformerBeanDefDO value : enumValuesExpandedTransformerBeanDefDO)
        {
            TransformerBeanDefDO.addTransformer(value);
        }
        for (ExpandedExecutionBeanKeyDefDO value : enumValuesExpandedExecutionBeanKeyDefDO)
        {
            ExecutionBeanKeyDefDO.addExecutionBeanKey(value);
        }
        for (ExpandedApprovalTypeDefDO value : enumValuesExpandedApprovalTypeDefDO)
        {
            ApprovalTypeDefDO.addApprovalType(value);
        }
        for (ExpandedOrderValidationRuleDefDO value : enumValuesExpandedOrderValidationRuleDefDO)
        {
            OrderValidationRuleDefDO.addOrderValidationRule(value);
        }
        for (ExpandedJobDefDO value : enumValuesExpandedJobDefDO)
        {
            JobDefDO.addJobDefDO(value);
        }
        for (ExpandedOrderSupplierEvaluationRuleDefDO value : enumValuesExpandedOrderSupplierEvaluationRuleDefDO)
        {
            OrderSupplierEvaluationRuleDefDO.addOrderSupplierEvaluationRule(value);
        }
        for (ExpandedNumberRangeFormatterDefDO value : enumValuesExpandedNumberRangeFormatterDefDO)
        {
            NumberRangeFormatterDefDO.addNumberRangeFormatter(value);
        }
        for (ExpandedPaymentDefDO value : enumValuesExpandedPaymentDefDO)
        {
            PaymentDefDO.addPaymentDefDO(value);
        }
        for (ExpandedMessageTypeDefDO value : enumValuesExpandedMessageTypeDefDO)
        {
            MessageTypeDefDO.addMessageTypeDefDO(value);
        }
        for (ExpandedTransmissionTypeDefDO value : enumValuesExpandedTransmissionTypeDefDO)
        {
            TransmissionTypeDefDO.addTransmissionTypeDefDO(value);
        }
        for (ExpandedProcessTaskDefDO value : enumValuesExpandedProcessTaskDefDO)
        {
            ProcessTaskDefDO.addProcessTask(value);
        }
        for (ExpandedEventDefDO value : enumValuesExpandedEventDefDO)
        {
            EventDefDO.addEventDefDO(value);
        }

    }
}
