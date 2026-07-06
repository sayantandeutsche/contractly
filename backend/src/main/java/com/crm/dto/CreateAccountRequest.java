package com.crm.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;
import java.math.BigDecimal;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class CreateAccountRequest {

    // Step 1 — Account Details
    @NotBlank(message = "Account name is required")
    @Size(max = 255)
    private String name;
    private String type;
    private String industry;
    private String customerStatus;
    private String segment;
    private String profitCenter;
    private String phone;
    private String accountEmail;
    private String website;
    private String accountNumber;
    private String currencyIsoCode;

    // Step 2 — Billing Info
    private String billingStreet;
    private String billingCity;
    private String billingState;
    private String billingPostalCode;
    private String billingCountry;
    private String billingCountryCode;

    // Step 3 — Additional Info
    private Integer numberOfEmployees;
    private String numberOfEmployeesRange;
    private BigDecimal annualRevenue;
    private String ownership;
    private String rating;
    private String subscriptionStatus;
    private String description;
}
