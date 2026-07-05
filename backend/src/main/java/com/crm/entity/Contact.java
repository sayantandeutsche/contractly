package com.crm.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * Maps to crm.contact (04d_contact_table_updated.sql)
 * 'name' is a GENERATED ALWAYS column — insertable=false, updatable=false.
 */
@Entity
@Table(name = "contact", schema = "crm")
@Getter @Setter @NoArgsConstructor
public class Contact extends BaseEntity {

    // ── Identity ─────────────────────────────────────────────
    private String salutation;                                     // crm.contact_salutation
    @Column(name = "first_name")           private String firstName;
    @Column(name = "last_name")            private String lastName;

    /** Generated column — read-only. Never set this directly. */
    @Column(name = "name", insertable = false, updatable = false)
    private String name;

    private String title;
    @Column(name = "title_type")           private String titleType;
    @Column(name = "academic_title")       private String academicTitle;
    @Column(name = "academic_status")      private String academicStatus;
    private String pronouns;
    @Column(name = "gender_identity")      private String genderIdentity;

    // ── Department / role ────────────────────────────────────
    private String department;
    @Column(name = "department_picklist")  private String departmentPicklist;
    @Column(name = "department_group")     private String departmentGroup;
    private String role;                                           // multipicklist → delimited
    @Column(name = "role_level")           private String roleLevel;

    // ── Contact info ─────────────────────────────────────────
    private String email;
    @Column(name = "email_2")              private String email2;
    @Column(name = "email_bounced_date")   private OffsetDateTime emailBouncedDate;
    @Column(name = "email_bounced_reason") private String emailBouncedReason;
    @Column(name = "has_opted_out_of_email")private Boolean hasOptedOutOfEmail = false;
    @Column(name = "unsubscribed")         private Boolean unsubscribed = false;
    private String phone;
    @Column(name = "mobile_phone")         private String mobilePhone;
    @Column(name = "home_phone")           private String homePhone;
    @Column(name = "do_not_call")          private Boolean doNotCall = false;
    @Column(name = "do_not_contact")       private Boolean doNotContact = false;
    private String linkedin;

    // ── Mailing address ───────────────────────────────────────
    @Column(name = "mailing_street")       private String mailingStreet;
    @Column(name = "mailing_city")         private String mailingCity;
    @Column(name = "mailing_state")        private String mailingState;
    @Column(name = "mailing_postal_code")  private String mailingPostalCode;
    @Column(name = "mailing_country")      private String mailingCountry;
    @Column(name = "mailing_country_code") private String mailingCountryCode;

    // ── Classification ────────────────────────────────────────
    @Column(name = "lead_source")          private String leadSource;
    @Column(name = "contact_source")       private String contactSource;
    @Column(name = "account_type")         private String accountType;
    private String platform;
    @Column(name = "product_of_interest")  private String productOfInterest;
    @Column(name = "subscription_status")  private String subscriptionStatus;
    @Column(name = "currency_iso_code")    private String currencyIsoCode;
    @Column(name = "user_status")          private String userStatus;
    @Column(name = "user_integration_status")private String userIntegrationStatus;

    // ── License / access ─────────────────────────────────────
    @Column(name = "license_is_active")    private Boolean licenseIsActive = false;
    @Column(name = "license_type")         private String licenseType;
    @Column(name = "backend_user_id")      private String backendUserId;

    // ── Engagement metrics ───────────────────────────────────
    @Column(name = "active_days_last_90")           private Integer activeDaysLast90;
    @Column(name = "content_views_last_90")         private Integer contentViewsLast90;
    @Column(name = "was_active_last_90")            private Boolean wasActiveLast90 = false;
    @Column(name = "last_active_date")              private java.time.LocalDate lastActiveDate;

    // ── Relationships ─────────────────────────────────────────
    @Column(name = "account_id")           private UUID accountId;
    @Column(name = "owner_id")             private UUID ownerId;
    @Column(name = "reports_to_id")        private UUID reportsToId;
    @Column(name = "license_id")           private UUID licenseId;

    // ── Misc ─────────────────────────────────────────────────
    private String description;
    @Column(name = "converted_from_lead")  private Boolean convertedFromLead = false;
    @Column(name = "email_opted_out",
            insertable = false, updatable = false)   // alias — use has_opted_out_of_email
    private Boolean emailOptedOut;
}
