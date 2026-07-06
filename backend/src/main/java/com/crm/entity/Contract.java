package com.crm.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * Maps to crm.contract (05c_contract_table_updated.sql)
 * Only columns that actually exist in the table are mapped here.
 */
@Entity
@Table(name = "contract", schema = "crm")
@Getter @Setter @NoArgsConstructor
public class Contract extends BaseEntity {

    // ── Identity ─────────────────────────────────────────────
    private String name;
    @Column(name = "contract_number")          private String contractNumber;
    @Column(name = "offer_number")             private String offerNumber;
    @Column(name = "legacy_id")                private String legacyId;
    @Column(name = "kl_contract_number")       private String klContractNumber;
    @Column(name = "backend_user_id")          private String backendUserId;
    private String description;
    @Column(name = "special_terms")            private String specialTerms;
    @Column(name = "special_conditions")       private String specialConditions;

    // ── Status ────────────────────────────────────────────────
    private String status;
    @Column(name = "status_code")              private String statusCode;
    @Column(name = "contract_active")          private Boolean contractActive = false;
    @Column(name = "cancellation_status")      private String cancellationStatus;
    @Column(name = "termination_status")       private String terminationStatus;

    // ── Dates ─────────────────────────────────────────────────
    @Column(name = "start_date")               private LocalDate startDate;
    @Column(name = "end_date")                 private LocalDate endDate;
    @Column(name = "contract_term")            private Integer contractTerm;
    @Column(name = "activated_date")           private OffsetDateTime activatedDate;
    @Column(name = "last_approved_date")       private OffsetDateTime lastApprovedDate;
    @Column(name = "company_signed_date")      private LocalDate companySignedDate;
    @Column(name = "customer_signed_date")     private LocalDate customerSignedDate;
    @Column(name = "customer_signed_title")    private String customerSignedTitle;
    @Column(name = "cancellation_date")        private LocalDate cancellationDate;
    @Column(name = "termination_date")         private LocalDate terminationDate;
    @Column(name = "notice_period_start")      private LocalDate noticePeriodStart;
    @Column(name = "notice_period_in_days")    private BigDecimal noticePeriodInDays;
    @Column(name = "date_of_acceptance")       private LocalDate dateOfAcceptance;
    @Column(name = "date_of_first_contract")   private LocalDate dateOfFirstContract;
    @Column(name = "last_activity_date")       private LocalDate lastActivityDate;
    @Column(name = "user_synchronization_date")private OffsetDateTime userSynchronizationDate;

    // ── Classification ────────────────────────────────────────
    @Column(name = "account_booking_status")   private String accountBookingStatus;
    @Column(name = "deal_type")                private String dealType;
    @Column(name = "industry_type")            private String industryType;
    @Column(name = "primary_product")          private String primaryProduct;
    @Column(name = "service_level")            private String serviceLevel;
    @Column(name = "original_service_level")   private String originalServiceLevel;
    @Column(name = "profit_center")            private String profitCenter;
    @Column(name = "clearing_house")           private String clearingHouse;
    @Column(name = "business_language")        private String businessLanguage;
    @Column(name = "access_type")              private String accessType;     // multipicklist
    @Column(name = "connect_tool")             private String connectTool;    // multipicklist
    @Column(name = "sales_channel")            private String salesChannel;   // multipicklist
    @Column(name = "sales_team_text")          private String salesTeamText;
    @Column(name = "sales_team_deprecated")    private String salesTeamDeprecated;

    // ── Financial ─────────────────────────────────────────────
    @Column(name = "annualized_revenue")           private BigDecimal annualizedRevenue;
    @Column(name = "annual_revenue")               private BigDecimal annualRevenue;
    @Column(name = "monthly_revenue")              private BigDecimal monthlyRevenue;
    @Column(name = "monthly_revenue_list_price")   private BigDecimal monthlyRevenueListPrice;
    @Column(name = "new_business_revenue")         private BigDecimal newBusinessRevenue;
    @Column(name = "existing_business_revenue")    private BigDecimal existingBusinessRevenue;
    @Column(name = "total_amount")                 private BigDecimal totalAmount;
    @Column(name = "remaining_balance")            private BigDecimal remainingBalance;
    @Column(name = "renewal_price_increase_pct")   private BigDecimal renewalPriceIncreasePct;
    @Column(name = "currency_iso_code")            private String currencyIsoCode;

    // ── Billing / payment ─────────────────────────────────────
    @Column(name = "billing_frequency")        private String billingFrequency;
    @Column(name = "billing_cycle")            private String billingCycle;
    @Column(name = "billing_email")            private String billingEmail;
    @Column(name = "payment_terms")            private String paymentTerms;
    @Column(name = "payment_status")           private String paymentStatus;
    @Column(name = "payment_status_comments")  private String paymentStatusComments;
    @Column(name = "po_number")                private String poNumber;
    @Column(name = "po_needed")                private String poNeeded;
    @Column(name = "agreement_form")           private String agreementForm;
    @Column(name = "invoice_post_date_support")private String invoicePostDateSupport;

    // ── Billing address ───────────────────────────────────────
    @Column(name = "billing_street")           private String billingStreet;
    @Column(name = "billing_city")             private String billingCity;
    @Column(name = "billing_state")            private String billingState;
    @Column(name = "billing_state_code")       private String billingStateCode;
    @Column(name = "billing_postal_code")      private String billingPostalCode;
    @Column(name = "billing_country")          private String billingCountry;
    @Column(name = "billing_country_code")     private String billingCountryCode;

    // ── Shipping address ──────────────────────────────────────
    @Column(name = "shipping_street")          private String shippingStreet;
    @Column(name = "shipping_city")            private String shippingCity;
    @Column(name = "shipping_state")           private String shippingState;
    @Column(name = "shipping_postal_code")     private String shippingPostalCode;
    @Column(name = "shipping_country")         private String shippingCountry;
    @Column(name = "shipping_country_code")    private String shippingCountryCode;

    // ── Seats / hours / credits ───────────────────────────────
    private BigDecimal seats;
    @Column(name = "number_of_user")           private BigDecimal numberOfUser;
    @Column(name = "total_purchased_hours")    private BigDecimal totalPurchasedHours;
    @Column(name = "total_remaining_hours")    private BigDecimal totalRemainingHours;
    @Column(name = "total_purchased_credit")   private BigDecimal totalPurchasedCredit;
    @Column(name = "total_remaining_credit")   private BigDecimal totalRemainingCredit;

    // ── Usage metrics ─────────────────────────────────────────
    @Column(name = "content_views_last_60")    private BigDecimal contentViewsLast60;
    @Column(name = "content_views_last_90")    private BigDecimal contentViewsLast90;
    @Column(name = "downloads_last_90")        private BigDecimal downloadsLast90;
    @Column(name = "active_users_last_90")     private BigDecimal activeUsersLast90;

    // ── Health / sentiment ────────────────────────────────────
    private String healthscore;
    @Column(name = "cancellation_reason")      private String cancellationReason;
    @Column(name = "termination_reason")       private String terminationReason;
    @Column(name = "termination_comments")     private String terminationComments;
    @Column(name = "liable_office")            private String liableOffice;
    @Column(name = "user_integration_status")  private String userIntegrationStatus;
    @Column(name = "owner_expiration_notice")  private String ownerExpirationNotice;

    // ── Boolean flags ─────────────────────────────────────────
    @Column(name = "is_auto_renewal")          private Boolean isAutoRenewal = false;
    @Column(name = "is_global")                private Boolean isGlobal = false;
    @Column(name = "is_trial")                 private Boolean isTrial = false;
    @Column(name = "is_win_back")              private Boolean isWinBack = false;
    @Column(name = "has_connect")              private Boolean hasConnect = false;
    @Column(name = "service_level_overridden") private Boolean serviceLevelOverridden = false;
    @Column(name = "notified")                 private Boolean notified = false;
    @Column(name = "exclude_from_user_sync")   private Boolean excludeFromUserSync = false;
    @Column(name = "inbound_flag")             private Boolean inboundFlag = false;
    @Column(name = "ended_yesterday")          private Boolean endedYesterday = false;
    @Column(name = "is_kl_outbound")           private Boolean isKlOutbound = false;
    @Column(name = "is_created_automatically") private Boolean isCreatedAutomatically = false;

    // ── Relationships ─────────────────────────────────────────
    @Column(name = "account_id")               private UUID accountId;
    @Column(name = "owner_id")                 private UUID ownerId;
    @Column(name = "opportunity_id")           private UUID opportunityId;
    @Column(name = "primary_contact_id")       private UUID primaryContactId;
    @Column(name = "primary_cs_manager_id")    private UUID primaryCsManagerId;
    @Column(name = "activated_by_id")          private UUID activatedById;
    @Column(name = "company_signed_id")        private UUID companySignedId;
    @Column(name = "customer_signed_id")       private UUID customerSignedId;
    @Column(name = "source_contract_id")       private UUID sourceContractId;
    @Column(name = "follow_up_contract_id")    private UUID followUpContractId;
    @Column(name = "follow_up_opportunity_id") private UUID followUpOpportunityId;
    @Column(name = "pricebook2_id")            private UUID pricebook2Id;
    @Column(name = "ship_to_account_id")       private UUID shipToAccountId;
    @Column(name = "original_csm_id")          private UUID originalCsmId;
    @Column(name = "original_owner_id")        private UUID originalOwnerId;

    // ── Opportunity counts ────────────────────────────────────
    @Column(name = "open_renewal_opps")            private BigDecimal openRenewalOpps;
    @Column(name = "closed_won_renewal_opps")      private BigDecimal closedWonRenewalOpps;
    @Column(name = "closed_lost_renewal_opps")     private BigDecimal closedLostRenewalOpps;
    @Column(name = "number_of_contracts")          private BigDecimal numberOfContracts;

    // ── Formula / text fields ─────────────────────────────────
    @Column(name = "primary_contact_name")     private String primaryContactName;
    @Column(name = "primary_cs_manager_name")  private String primaryCsManagerName;
    @Column(name = "department")               private String department;
    @Column(name = "open_contract_in_kl")      private String openContractInKl;
    @Column(name = "show_access_method")       private String showAccessMethod;
    @Column(name = "profit_center_text")       private String profitCenterText;
    @Column(name = "liable_office_text")       private String liableOfficeText;
}
