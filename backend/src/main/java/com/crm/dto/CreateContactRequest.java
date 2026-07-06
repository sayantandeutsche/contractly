package com.crm.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class CreateContactRequest {

    // Step 1 — Contact Information
    private String salutation;
    private String firstName;
    @NotBlank(message = "Last name is required")
    @Size(max = 80)
    private String lastName;
    private String title;
    private String titleType;
    private String departmentPicklist;
    private String roleLevel;
    private String leadSource;
    private String platform;
    private String subscriptionStatus;
    private String currencyIsoCode;
    private java.util.UUID accountId;

    // Step 2 — Contact Details
    private String email;
    private String email2;
    private String phone;
    private String mobilePhone;
    private String homePhone;
    private Boolean doNotCall;
    private Boolean hasOptedOutOfEmail;
    private String linkedin;
    private String productOfInterest;

    // Step 3 — Address
    private String mailingStreet;
    private String mailingCity;
    private String mailingState;
    private String mailingPostalCode;
    private String mailingCountry;
    private String mailingCountryCode;
    private String description;
}
