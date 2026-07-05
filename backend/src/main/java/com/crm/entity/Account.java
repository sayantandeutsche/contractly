package com.crm.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.UUID;

/**
 * Maps to crm.account (04c_account_table_updated.sql)
 * Enum columns stored as VARCHAR — Postgres enums are read as strings by Hibernate.
 */
@Entity
@Table(name = "account", schema = "crm")
@Getter @Setter @NoArgsConstructor
public class Account extends BaseEntity {

    // ── Identity ─────────────────────────────────────────────
    private String name;
    @Column(name = "account_number")       private String accountNumber;
    @Column(name = "site")                 private String site;
    @Column(name = "ticker_symbol")        private String tickerSymbol;

    // ── Classification (enum columns → String) ───────────────
    @Column(name = "type")                 private String type;           // crm.account_type
    @Column(name = "account_type_custom")  private String accountTypeCustom;
    @Column(name = "industry")             private String industry;       // crm.account_industry
    @Column(name = "sub_industry")         private String subIndustry;
    @Column(name = "ownership")            private String ownership;
    @Column(name = "rating")               private String rating;
    @Column(name = "account_source")       private String accountSource;
    @Column(name = "account_category")     private String accountCategory;
    @Column(name = "segment")              private String segment;
    @Column(name = "calculated_segment")   private String calculatedSegment;
    @Column(name = "customer_status")      private String customerStatus;
    @Column(name = "customer_category")    private String customerCategory;
    @Column(name = "subscription_status")  private String subscriptionStatus;
    @Column(name = "profit_center")        private String profitCenter;
    @Column(name = "platform")             private String platform;
    @Column(name = "primary_product")      private String primaryProduct;  // license_type equivalent
    @Column(name = "healthscore")          private String healthscore;
    @Column(name = "strategic_potential")  private String strategicPotential;

    // ── Contact / communication ───────────────────────────────
    private String phone;
    private String fax;
    private String website;
    @Column(name = "account_email")        private String accountEmail;
    @Column(name = "linkedin_company_id")  private String linkedinCompanyId;

    // ── Billing address ───────────────────────────────────────
    @Column(name = "billing_street")       private String billingStreet;
    @Column(name = "billing_city")         private String billingCity;
    @Column(name = "billing_state")        private String billingState;
    @Column(name = "billing_state_code")   private String billingStateCode;
    @Column(name = "billing_postal_code")  private String billingPostalCode;
    @Column(name = "billing_country")      private String billingCountry;
    @Column(name = "billing_country_code") private String billingCountryCode;

    // ── Shipping address ──────────────────────────────────────
    @Column(name = "shipping_street")      private String shippingStreet;
    @Column(name = "shipping_city")        private String shippingCity;
    @Column(name = "shipping_state")       private String shippingState;
    @Column(name = "shipping_postal_code") private String shippingPostalCode;
    @Column(name = "shipping_country")     private String shippingCountry;
    @Column(name = "shipping_country_code")private String shippingCountryCode;

    // ── Financial ─────────────────────────────────────────────
    @Column(name = "annual_revenue")           private BigDecimal annualRevenue;
    @Column(name = "annualized_revenue")       private BigDecimal annualizedRevenue;  // ARR
    @Column(name = "monthly_revenue")          private BigDecimal monthlyRevenue;     // MRR
    @Column(name = "currency_iso_code")        private String currencyIsoCode;

    // ── Employees ─────────────────────────────────────────────
    @Column(name = "number_of_employees")      private Integer numberOfEmployees;
    @Column(name = "number_of_employees_range")private String numberOfEmployeesRange;
    @Column(name = "fte_size")                 private String fteSize;

    // ── Contract metrics ──────────────────────────────────────
    @Column(name = "activated_contracts")      private Integer activatedContracts;
    @Column(name = "current_contracts")        private Integer currentContracts;
    @Column(name = "active_opportunities_count")private Integer activeOpportunitiesCount;

    // ── Relationships ─────────────────────────────────────────
    @Column(name = "owner_id")                 private UUID ownerId;
    @Column(name = "parent_id")                private UUID parentId;
    @Column(name = "client_success_manager_id")private UUID clientSuccessManagerId;
    @Column(name = "sales_representative_id")  private UUID salesRepresentativeId;

    // ── Flags ─────────────────────────────────────────────────
    @Column(name = "is_active_subscription")   private Boolean isActiveSubscription = false;
    @Column(name = "churn_risk")               private Boolean churnRisk = false;
    @Column(name = "enriched")                 private Boolean enriched = false;

    // ── Text ──────────────────────────────────────────────────
    private String description;
    @Column(name = "account_description")      private String accountDescription;

    // ── External IDs ─────────────────────────────────────────
    @Column(name = "customer_id")              private String customerId;
    @Column(name = "backend_user_id")          private String backendUserId;
    @Column(name = "domain")                   private String domain;
}
