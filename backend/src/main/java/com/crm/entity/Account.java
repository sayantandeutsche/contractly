package com.crm.entity;

import com.crm.converter.PostgresEnumType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Type;
import java.math.BigDecimal;
import java.util.UUID;

/**
 * Maps to crm.account (04c_account_table_updated.sql)
 *
 * Postgres named enum columns use @Type(PostgresEnumType.class) which
 * passes values as Types.OTHER — Postgres then casts them to the
 * correct enum type implicitly without needing an explicit CAST().
 */
@Entity
@Table(name = "account", schema = "crm")
@Getter @Setter @NoArgsConstructor
public class Account extends BaseEntity {

    // ── Identity ─────────────────────────────────────────────
    private String name;
    @Column(name = "account_number")        private String accountNumber;
    @Column(name = "site")                  private String site;
    @Column(name = "ticker_symbol")         private String tickerSymbol;

    // ── Postgres enum columns — require @Type(PostgresEnumType.class) ──
    @Column(name = "type")
    @Type(PostgresEnumType.class)
    private String type;

    @Column(name = "account_type_custom")
    @Type(PostgresEnumType.class)
    private String accountTypeCustom;

    @Column(name = "industry")
    @Type(PostgresEnumType.class)
    private String industry;

    @Column(name = "sub_industry")
    @Type(PostgresEnumType.class)
    private String subIndustry;

    @Column(name = "ownership")
    @Type(PostgresEnumType.class)
    private String ownership;

    @Column(name = "rating")
    @Type(PostgresEnumType.class)
    private String rating;

    @Column(name = "account_source")
    @Type(PostgresEnumType.class)
    private String accountSource;

    @Column(name = "account_category")
    @Type(PostgresEnumType.class)
    private String accountCategory;

    @Column(name = "segment")
    @Type(PostgresEnumType.class)
    private String segment;

    @Column(name = "calculated_segment")
    @Type(PostgresEnumType.class)
    private String calculatedSegment;

    @Column(name = "customer_status")
    @Type(PostgresEnumType.class)
    private String customerStatus;

    @Column(name = "customer_category")
    @Type(PostgresEnumType.class)
    private String customerCategory;

    @Column(name = "subscription_status")
    @Type(PostgresEnumType.class)
    private String subscriptionStatus;

    @Column(name = "profit_center")
    @Type(PostgresEnumType.class)
    private String profitCenter;

    @Column(name = "platform")
    @Type(PostgresEnumType.class)
    private String platform;

    @Column(name = "license_type")
    @Type(PostgresEnumType.class)
    private String licenseType;

    @Column(name = "healthscore")
    @Type(PostgresEnumType.class)
    private String healthscore;

    @Column(name = "strategic_potential")
    @Type(PostgresEnumType.class)
    private String strategicPotential;

    @Column(name = "paid_accounts_in_company")
    @Type(PostgresEnumType.class)
    private String paidAccountsInCompany;

    @Column(name = "merge_flag")
    @Type(PostgresEnumType.class)
    private String mergeFlag;

    @Column(name = "number_of_employees_range")
    @Type(PostgresEnumType.class)
    private String numberOfEmployeesRange;

    @Column(name = "fte_size")
    @Type(PostgresEnumType.class)
    private String fteSize;

    @Column(name = "currency_iso_code")
    @Type(PostgresEnumType.class)
    private String currencyIsoCode;

    @Column(name = "billing_geocode_accuracy")
    @Type(PostgresEnumType.class)
    private String billingGeocodeAccuracy;

    @Column(name = "shipping_geocode_accuracy")
    @Type(PostgresEnumType.class)
    private String shippingGeocodeAccuracy;

    // ── Plain VARCHAR / non-enum columns ──────────────────────
    private String phone;
    private String fax;
    private String website;
    @Column(name = "account_email")         private String accountEmail;
    @Column(name = "linkedin_company_id")   private String linkedinCompanyId;

    // ── Billing address ───────────────────────────────────────
    @Column(name = "billing_street")        private String billingStreet;
    @Column(name = "billing_city")          private String billingCity;
    @Column(name = "billing_state")         private String billingState;
    @Column(name = "billing_state_code")    private String billingStateCode;
    @Column(name = "billing_postal_code")   private String billingPostalCode;
    @Column(name = "billing_country")       private String billingCountry;
    @Column(name = "billing_country_code")  private String billingCountryCode;

    // ── Shipping address ──────────────────────────────────────
    @Column(name = "shipping_street")       private String shippingStreet;
    @Column(name = "shipping_city")         private String shippingCity;
    @Column(name = "shipping_state")        private String shippingState;
    @Column(name = "shipping_postal_code")  private String shippingPostalCode;
    @Column(name = "shipping_country")      private String shippingCountry;
    @Column(name = "shipping_country_code") private String shippingCountryCode;

    // ── Financial ─────────────────────────────────────────────
    @Column(name = "annual_revenue")        private BigDecimal annualRevenue;
    @Column(name = "annualized_revenue")    private BigDecimal annualizedRevenue;
    @Column(name = "monthly_revenue")       private BigDecimal monthlyRevenue;

    // ── Employees ─────────────────────────────────────────────
    @Column(name = "number_of_employees")       private Integer numberOfEmployees;

    // ── Contract metrics ──────────────────────────────────────
    @Column(name = "activated_contracts")       private Integer activatedContracts;
    @Column(name = "current_contracts")         private Integer currentContracts;
    @Column(name = "active_opportunities_count")private Integer activeOpportunitiesCount;

    // ── Relationships ─────────────────────────────────────────
    @Column(name = "owner_id")                  private UUID ownerId;
    @Column(name = "parent_id")                 private UUID parentId;
    @Column(name = "client_success_manager_id") private UUID clientSuccessManagerId;
    @Column(name = "sales_representative_id")   private UUID salesRepresentativeId;

    // ── Flags ─────────────────────────────────────────────────
    @Column(name = "is_active_subscription")    private Boolean isActiveSubscription = false;
    @Column(name = "churn_risk")                private Boolean churnRisk = false;
    @Column(name = "enriched")                  private Boolean enriched = false;

    // ── Text ─────────────────────────────────────────────────
    private String description;
    @Column(name = "account_description")       private String accountDescription;

    // ── External IDs ─────────────────────────────────────────
    @Column(name = "customer_id")               private String customerId;
    @Column(name = "backend_user_id")           private String backendUserId;
    @Column(name = "domain")                    private String domain;
}
