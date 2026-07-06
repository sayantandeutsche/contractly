package com.crm.entity;

import com.crm.converter.PostgresEnumType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Type;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "contact", schema = "crm")
@Getter @Setter @NoArgsConstructor
public class Contact extends BaseEntity {

    // ── Identity ─────────────────────────────────────────────
    @Column(name = "salutation") @Type(PostgresEnumType.class)
    private String salutation;
    @Column(name = "first_name")            private String firstName;
    @Column(name = "last_name")             private String lastName;
    @Column(name = "name", insertable = false, updatable = false)
    private String name;
    private String title;
    @Column(name = "title_type")     @Type(PostgresEnumType.class) private String titleType;
    @Column(name = "academic_title") @Type(PostgresEnumType.class) private String academicTitle;
    @Column(name = "academic_status")@Type(PostgresEnumType.class) private String academicStatus;
    @Column(name = "pronouns")       @Type(PostgresEnumType.class) private String pronouns;
    @Column(name = "gender_identity")@Type(PostgresEnumType.class) private String genderIdentity;

    // ── Department / role ─────────────────────────────────────
    private String department;
    @Column(name = "department_picklist")@Type(PostgresEnumType.class) private String departmentPicklist;
    @Column(name = "department_group")   @Type(PostgresEnumType.class) private String departmentGroup;
    private String role;
    @Column(name = "role_level")         @Type(PostgresEnumType.class) private String roleLevel;

    // ── Contact info ─────────────────────────────────────────
    private String email;
    @Column(name = "email_2")               private String email2;
    @Column(name = "email_bounced_date")    private OffsetDateTime emailBouncedDate;
    @Column(name = "email_bounced_reason")  private String emailBouncedReason;
    @Column(name = "has_opted_out_of_email")private Boolean hasOptedOutOfEmail = false;
    @Column(name = "unsubscribed")          private Boolean unsubscribed = false;
    private String phone;
    @Column(name = "mobile_phone")          private String mobilePhone;
    @Column(name = "home_phone")            private String homePhone;
    @Column(name = "do_not_call")           private Boolean doNotCall = false;
    @Column(name = "do_not_contact")        private Boolean doNotContact = false;
    private String linkedin;

    // ── Mailing address ───────────────────────────────────────
    @Column(name = "mailing_street")        private String mailingStreet;
    @Column(name = "mailing_city")          private String mailingCity;
    @Column(name = "mailing_state")         private String mailingState;
    @Column(name = "mailing_postal_code")   private String mailingPostalCode;
    @Column(name = "mailing_country")       private String mailingCountry;
    @Column(name = "mailing_country_code")  private String mailingCountryCode;

    // ── Classification (Postgres enum columns) ────────────────
    @Column(name = "lead_source")         @Type(PostgresEnumType.class) private String leadSource;
    @Column(name = "contact_source")      @Type(PostgresEnumType.class) private String contactSource;
    @Column(name = "account_type")        @Type(PostgresEnumType.class) private String accountType;
    @Column(name = "platform")            @Type(PostgresEnumType.class) private String platform;
    @Column(name = "product_of_interest") @Type(PostgresEnumType.class) private String productOfInterest;
    @Column(name = "subscription_status") @Type(PostgresEnumType.class) private String subscriptionStatus;
    @Column(name = "currency_iso_code")   @Type(PostgresEnumType.class) private String currencyIsoCode;
    @Column(name = "user_status")         @Type(PostgresEnumType.class) private String userStatus;
    @Column(name = "user_integration_status")@Type(PostgresEnumType.class) private String userIntegrationStatus;

    // ── License / access ─────────────────────────────────────
    @Column(name = "license_is_active")     private Boolean licenseIsActive = false;
    @Column(name = "license_type")          private String licenseType;
    @Column(name = "backend_user_id")       private String backendUserId;

    // ── Engagement metrics ───────────────────────────────────
    @Column(name = "active_days_last_90")   private Integer activeDaysLast90;
    @Column(name = "content_views_last_90") private Integer contentViewsLast90;
    @Column(name = "was_active_last_90")    private Boolean wasActiveLast90 = false;
    @Column(name = "last_active_date")      private LocalDate lastActiveDate;

    // ── Relationships ─────────────────────────────────────────
    @Column(name = "account_id")            private UUID accountId;
    @Column(name = "owner_id")              private UUID ownerId;
    @Column(name = "reports_to_id")         private UUID reportsToId;
    @Column(name = "license_id")            private UUID licenseId;

    // ── Misc ─────────────────────────────────────────────────
    private String description;
    @Column(name = "converted_from_lead")   private Boolean convertedFromLead = false;
}
