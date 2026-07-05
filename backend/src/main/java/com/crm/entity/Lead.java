package com.crm.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * Maps to crm.lead (04b_lead_table_updated.sql)
 * 'name' is a GENERATED ALWAYS column — insertable=false, updatable=false.
 */
@Entity
@Table(name = "lead", schema = "crm")
@Getter @Setter @NoArgsConstructor
public class Lead extends BaseEntity {

    // ── Identity ─────────────────────────────────────────────
    private String salutation;                                       // crm.salutation
    @Column(name = "first_name")             private String firstName;
    @Column(name = "last_name")              private String lastName;

    /** Generated column — read-only. Never set this directly. */
    @Column(name = "name", insertable = false, updatable = false)
    private String name;

    private String title;
    @Column(name = "academic_title")         private String academicTitle;
    private String pronouns;
    @Column(name = "gender_identity")        private String genderIdentity;

    // ── Company ───────────────────────────────────────────────
    private String company;
    @Column(name = "account_type")           private String accountType;

    // ── Contact info ─────────────────────────────────────────
    private String email;
    @Column(name = "has_opted_out_of_email") private Boolean hasOptedOutOfEmail = false;
    @Column(name = "email_bounced_date")     private OffsetDateTime emailBouncedDate;
    @Column(name = "email_bounced_reason")   private String emailBouncedReason;
    private String phone;
    @Column(name = "mobile_phone")           private String mobilePhone;
    private String fax;
    @Column(name = "do_not_call")            private Boolean doNotCall = false;
    @Column(name = "do_not_contact")         private Boolean doNotContact = false;
    private String website;
    private String linkedin;

    // ── Address ───────────────────────────────────────────────
    private String street;
    private String city;
    private String state;
    @Column(name = "postal_code")            private String postalCode;
    private String country;
    @Column(name = "country_code")           private String countryCode;

    // ── Classification ────────────────────────────────────────
    private String status;                                           // crm.lead_status
    @Column(name = "lead_source")            private String leadSource;   // crm.lead_source
    @Column(name = "lead_category")          private String leadCategory;
    private String rating;
    private String industry;                                         // crm.lead_industry
    private String department;                                       // crm.lead_department
    @Column(name = "role_level")             private String roleLevel;
    @Column(name = "currency_iso_code")      private String currencyIsoCode;
    @Column(name = "profit_center")          private String profitCenter;
    private String platform;
    @Column(name = "subscription_status")    private String subscriptionStatus;
    @Column(name = "product_of_interest")    private String productOfInterest;
    @Column(name = "lead_status_cdp")        private String leadStatusCdp;
    @Column(name = "unqualify_reason")       private String unqualifyReason;

    // ── Financials ────────────────────────────────────────────
    @Column(name = "annual_revenue")         private BigDecimal annualRevenue;
    @Column(name = "number_of_employees")    private Integer numberOfEmployees;
    @Column(name = "number_of_employees_range")private String numberOfEmployeesRange;
    @Column(name = "revenue_range")          private String revenueRange;

    // ── Scoring ───────────────────────────────────────────────
    @Column(name = "company_score")          private BigDecimal companyScore;
    @Column(name = "person_score")           private BigDecimal personScore;
    @Column(name = "lead_info_score")        private BigDecimal leadInfoScore;

    // ── Conversion ────────────────────────────────────────────
    @Column(name = "is_converted")           private Boolean converted = false;
    @Column(name = "converted_date")         private LocalDate convertedDate;
    @Column(name = "converted_account_id")   private UUID convertedAccountId;
    @Column(name = "converted_contact_id")   private UUID convertedContactId;
    @Column(name = "converted_opportunity_id")private UUID convertedOpportunityId;

    // ── Status progression timestamps ─────────────────────────
    @Column(name = "timestamp_new")          private OffsetDateTime timestampNew;
    @Column(name = "timestamp_mql")          private OffsetDateTime timestampMql;
    @Column(name = "timestamp_screening")    private OffsetDateTime timestampScreening;
    @Column(name = "timestamp_qualification")private OffsetDateTime timestampQualification;
    @Column(name = "timestamp_outreach")     private OffsetDateTime timestampOutreach;
    @Column(name = "timestamp_unqualified")  private OffsetDateTime timestampUnqualified;

    // ── Activity ─────────────────────────────────────────────
    @Column(name = "last_activity_date")     private LocalDate lastActivityDate;
    @Column(name = "last_meaningful_connect")private LocalDate lastMeaningfulConnect;
    @Column(name = "first_call_date_time")   private OffsetDateTime firstCallDateTime;
    @Column(name = "first_email_date_time")  private OffsetDateTime firstEmailDateTime;

    // ── Sales team ───────────────────────────────────────────
    @Column(name = "owner_id")               private UUID ownerId;
    @Column(name = "screening_user_id")      private UUID screeningUserId;
    @Column(name = "sdr_fls_id")             private UUID sdrFlsId;
    @Column(name = "next_steps")             private String nextSteps;

    // ── Integration ───────────────────────────────────────────
    @Column(name = "backend_user_id")        private String backendUserId;
    @Column(name = "enriched")               private Boolean enriched = false;
    @Column(name = "enriched_date")          private LocalDate enrichedDate;
    @Column(name = "domain")                 private String domain;

    // ── Misc ─────────────────────────────────────────────────
    private String description;
    @Column(name = "lead_description")       private String leadDescription;

    // ── Outreach ─────────────────────────────────────────────
    @Column(name = "outreach_actively_sequenced")  private Boolean outreachActivelySequenced = false;
    @Column(name = "outreach_current_sequence_name")private String outreachCurrentSequenceName;
    @Column(name = "outreach_current_sequence_status")private String outreachCurrentSequenceStatus;
}
