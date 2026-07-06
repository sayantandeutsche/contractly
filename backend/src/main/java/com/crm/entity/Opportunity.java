package com.crm.entity;

import com.crm.converter.PostgresEnumType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Type;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "opportunity", schema = "crm")
@Getter @Setter @NoArgsConstructor
public class Opportunity extends BaseEntity {

    // ── Identity ─────────────────────────────────────────────
    private String name;
    private String description;
    @Column(name = "opportunity_description") private String opportunityDescription;
    @Column(name = "next_step")               private String nextStep;
    @Column(name = "running_number")          private String runningNumber;

    // ── Stage & forecast (Postgres enum columns) ──────────────
    @Column(name = "stage_name")        @Type(PostgresEnumType.class) private String stageName;
    @Column(name = "forecast_category") @Type(PostgresEnumType.class) private String forecastCategory;
    @Column(name = "forecast_category_name") @Type(PostgresEnumType.class) private String forecastCategoryName;
    private BigDecimal probability;
    @Column(name = "push_count")        private Integer pushCount = 0;
    @Column(name = "is_won")            private Boolean won = false;
    @Column(name = "is_closed")         private Boolean closed = false;
    @Column(name = "is_private")        private Boolean isPrivate = false;

    // ── Type / classification (Postgres enum columns) ─────────
    @Column(name = "type")                   @Type(PostgresEnumType.class) private String type;
    @Column(name = "account_booking_status") @Type(PostgresEnumType.class) private String accountBookingStatus;
    @Column(name = "lead_source")            @Type(PostgresEnumType.class) private String leadSource;
    @Column(name = "industry_type")          @Type(PostgresEnumType.class) private String industryType;
    @Column(name = "deal_type")              @Type(PostgresEnumType.class) private String dealType;
    @Column(name = "platform")               @Type(PostgresEnumType.class) private String platform;
    @Column(name = "profit_center")          @Type(PostgresEnumType.class) private String profitCenter;
    @Column(name = "primary_product")        @Type(PostgresEnumType.class) private String primaryProduct;
    @Column(name = "product_of_interest")    @Type(PostgresEnumType.class) private String productOfInterest;
    @Column(name = "original_service_level") @Type(PostgresEnumType.class) private String originalServiceLevel;
    @Column(name = "clearing_house")         @Type(PostgresEnumType.class) private String clearingHouse;
    @Column(name = "business_language")      @Type(PostgresEnumType.class) private String businessLanguage;
    @Column(name = "renewal_sentiment")      @Type(PostgresEnumType.class) private String renewalSentiment;
    @Column(name = "onboarding_sentiment")   @Type(PostgresEnumType.class) private String onboardingSentiment;
    @Column(name = "auto_renewal")           @Type(PostgresEnumType.class) private String autoRenewal;
    @Column(name = "billing_frequency")      @Type(PostgresEnumType.class) private String billingFrequency;
    @Column(name = "payment_terms")          @Type(PostgresEnumType.class) private String paymentTerms;
    @Column(name = "agreement_form")         @Type(PostgresEnumType.class) private String agreementForm;
    @Column(name = "invoice_post_date_support")@Type(PostgresEnumType.class) private String invoicePostDateSupport;
    @Column(name = "liable_office")          @Type(PostgresEnumType.class) private String liableOffice;
    @Column(name = "approval_status")        @Type(PostgresEnumType.class) private String approvalStatus;
    @Column(name = "closing_reason")         @Type(PostgresEnumType.class) private String closingReason;
    @Column(name = "closing_reason_detail")  @Type(PostgresEnumType.class) private String closingReasonDetail;
    @Column(name = "currency_iso_code")      @Type(PostgresEnumType.class) private String currencyIsoCode;
    @Column(name = "po_needed")              @Type(PostgresEnumType.class) private String poNeeded;
    @Column(name = "transfer_status_abt")    @Type(PostgresEnumType.class) private String transferStatusAbt;
    @Column(name = "ast_status")             @Type(PostgresEnumType.class) private String astStatus;
    @Column(name = "paid_accounts_in_company")@Type(PostgresEnumType.class) private String paidAccountsInCompany;

    // ── Plain VARCHAR fields ───────────────────────────────────
    @Column(name = "sales_team_text")         private String salesTeamText;
    @Column(name = "po_number")               private String poNumber;
    @Column(name = "billing_email")           private String billingEmail;
    @Column(name = "billing_street")          private String billingStreet;
    @Column(name = "billing_city")            private String billingCity;
    @Column(name = "billing_state_code")      private String billingStateCode;
    @Column(name = "billing_postal_code")     private String billingPostalCode;
    @Column(name = "billing_country_code")    private String billingCountryCode;

    // ── Financials ────────────────────────────────────────────
    private BigDecimal amount;
    @Column(name = "annual_recurring_revenue")    private BigDecimal annualRecurringRevenue;
    @Column(name = "monthly_recurring_revenue")   private BigDecimal monthlyRecurringRevenue;
    @Column(name = "expected_revenue")            private BigDecimal expectedRevenue;
    @Column(name = "new_business_revenue")        private BigDecimal newBusinessRevenue;
    @Column(name = "existing_business_revenue")   private BigDecimal existingBusinessRevenue;
    @Column(name = "remaining_balance")           private BigDecimal remainingBalance;
    @Column(name = "renewal_price_increase_pct")  private BigDecimal renewalPriceIncreasePct;
    @Column(name = "number_of_users_seats_booked")private BigDecimal numberOfUsersSeatsBooked;

    // ── Dates ─────────────────────────────────────────────────
    @Column(name = "close_date")              private LocalDate closeDate;
    @Column(name = "start_date")              private LocalDate startDate;
    @Column(name = "end_date")                private LocalDate endDate;
    @Column(name = "calculated_end_date")     private LocalDate calculatedEndDate;
    @Column(name = "forecast_date")           private LocalDate forecastDate;
    @Column(name = "quote_validity_date")     private LocalDate quoteValidityDate;
    @Column(name = "date_won")                private LocalDate dateWon;
    @Column(name = "last_activity_date")      private LocalDate lastActivityDate;
    @Column(name = "last_meaningful_connect") private LocalDate lastMeaningfulConnect;
    @Column(name = "last_stage_change_date")  private OffsetDateTime lastStageChangeDate;

    // ── Stage timestamps ──────────────────────────────────────
    @Column(name = "timestamp_activation")    private OffsetDateTime timestampActivation;
    @Column(name = "timestamp_discovery")     private OffsetDateTime timestampDiscovery;
    @Column(name = "timestamp_offer_creation")private OffsetDateTime timestampOfferCreation;
    @Column(name = "timestamp_negotiation")   private OffsetDateTime timestampNegotiation;
    @Column(name = "timestamp_finalisation")  private OffsetDateTime timestampFinalisation;
    @Column(name = "timestamp_closed")        private OffsetDateTime timestampClosed;

    // ── Contract / term ───────────────────────────────────────
    @Column(name = "contract_duration")       private BigDecimal contractDuration;
    @Column(name = "term_in_months")          private BigDecimal termInMonths;
    @Column(name = "notice_period_in_days")   private BigDecimal noticePeriodInDays;
    @Column(name = "is_auto_renewal")         private Boolean isAutoRenewal = false;

    // ── Approval / flags ──────────────────────────────────────
    @Column(name = "approval_needed")         private Boolean approvalNeeded = false;
    @Column(name = "has_connect_product")     private Boolean hasConnectProduct = false;
    @Column(name = "is_connect_only")         private Boolean isConnectOnly = false;
    @Column(name = "is_trial")                private Boolean isTrial = false;
    @Column(name = "is_win_back")             private Boolean isWinBack = false;
    @Column(name = "is_global")               private Boolean isGlobal = false;
    @Column(name = "is_split")                private Boolean isSplit = false;
    @Column(name = "discovery_completed")     private Boolean discoveryCompleted = false;
    @Column(name = "budget_confirmed")        private Boolean budgetConfirmed = false;
    @Column(name = "has_open_activity")       private Boolean hasOpenActivity = false;
    @Column(name = "has_opportunity_line_item")private Boolean hasOpportunityLineItem = false;

    // ── Metrics ───────────────────────────────────────────────
    @Column(name = "iq_score")                private Integer iqScore;
    @Column(name = "opportunity_age")         private BigDecimal opportunityAge;
    @Column(name = "fiscal")                  private String fiscal;
    @Column(name = "fiscal_quarter")          private Integer fiscalQuarter;
    @Column(name = "fiscal_year")             private Integer fiscalYear;

    // ── Relationships ─────────────────────────────────────────
    @Column(name = "account_id")              private UUID accountId;
    @Column(name = "owner_id")                private UUID ownerId;
    @Column(name = "contact_id")              private UUID contactId;
    @Column(name = "primary_contact_id")      private UUID primaryContactId;
    @Column(name = "contract_id")             private UUID contractId;
    @Column(name = "client_success_manager_id")private UUID clientSuccessManagerId;
    @Column(name = "sales_representative_id") private UUID salesRepresentativeId;
    @Column(name = "pricebook2_id")           private UUID pricebook2Id;

    // ── Formula / text ────────────────────────────────────────
    @Column(name = "account_country")         private String accountCountry;
    @Column(name = "competitor_information")  private String competitorInformation;
    @Column(name = "qualified_by")            private String qualifiedBy;
    @Column(name = "qualified_by_role")       private String qualifiedByRole;
    @Column(name = "owner_profit_center")     private String ownerProfitCenter;
    @Column(name = "pricebook_name")          private String pricebookName;
    @Column(name = "primary_contact_name")    private String primaryContactName;
    @Column(name = "risk_status")             private String riskStatus;
}
