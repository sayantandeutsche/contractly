package com.crm.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class CreateOpportunityRequest {

    // Step 1 — Opportunity Information
    @NotBlank(message = "Opportunity name is required")
    @Size(max = 120)
    private String name;
    private String type;
    private String stageName;
    private String forecastCategory;
    private BigDecimal probability;
    private String leadSource;
    private String primaryProduct;
    private String productOfInterest;
    private String platform;
    private String profitCenter;
    private String clearingHouse;
    private String businessLanguage;
    private String dealType;
    private UUID accountId;
    private String nextStep;
    private String description;

    // Step 2 — Financials
    private BigDecimal amount;
    private BigDecimal annualRecurringRevenue;
    private BigDecimal monthlyRecurringRevenue;
    private BigDecimal expectedRevenue;
    private String currencyIsoCode;
    private String billingFrequency;
    private String paymentTerms;
    private String agreementForm;
    private String poNumber;
    private BigDecimal termInMonths;
    private BigDecimal noticePeriodInDays;
    private String autoRenewal;
    private String billingEmail;

    // Step 3 — Dates
    @NotNull(message = "Close date is required")
    private LocalDate closeDate;
    private LocalDate startDate;
    private LocalDate endDate;
    private LocalDate forecastDate;
    private LocalDate quoteValidityDate;
}
