package com.crm.service;

import com.crm.config.TenantContext;
import com.crm.dto.*;
import com.crm.entity.Opportunity;
import com.crm.exception.ResourceNotFoundException;
import com.crm.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.UUID;

@Service @RequiredArgsConstructor
public class OpportunityService {
    private final OpportunityRepository repo;
    private final AccountRepository accountRepo;

    @Transactional(readOnly = true)
    public PageResponse<OpportunityDto> list(int page, int size, String sort) {
        UUID tid = UUID.fromString(TenantContext.get());
        Pageable pg = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "closeDate"));
        Page<Opportunity> result = repo.findByTenantIdAndDeletedFalse(tid, pg);
        return new PageResponse<>(result.getContent().stream().map(o -> toDto(o, tid)).toList(),
                page, size, result.getTotalElements(), result.getTotalPages(), result.isLast());
    }

    @Transactional(readOnly = true)
    public OpportunityDto get(UUID id) {
        UUID tid = UUID.fromString(TenantContext.get());
        return repo.findByIdAndTenantIdAndDeletedFalse(id, tid)
                .map(o -> toDto(o, tid))
                .orElseThrow(() -> new ResourceNotFoundException("Opportunity", id.toString()));
    }

    @Transactional
    public OpportunityDto create(CreateOpportunityRequest req) {
        UUID tid = UUID.fromString(TenantContext.get());
        Opportunity o = new Opportunity();
        o.setTenantId(tid);
        // Step 1 — Info
        o.setName(req.getName());
        o.setType(req.getType());
        o.setStageName(req.getStageName() != null ? req.getStageName() : "New");
        o.setForecastCategory(req.getForecastCategory() != null ? req.getForecastCategory() : "Pipeline");
        o.setProbability(req.getProbability());
        o.setLeadSource(req.getLeadSource());
        o.setPrimaryProduct(req.getPrimaryProduct());
        o.setProductOfInterest(req.getProductOfInterest());
        o.setPlatform(req.getPlatform());
        o.setProfitCenter(req.getProfitCenter());
        o.setClearingHouse(req.getClearingHouse());
        o.setBusinessLanguage(req.getBusinessLanguage());
        o.setDealType(req.getDealType());
        o.setAccountId(req.getAccountId());
        o.setNextStep(req.getNextStep());
        o.setDescription(req.getDescription());
        // Step 2 — Financials
        o.setAmount(req.getAmount());
        o.setAnnualRecurringRevenue(req.getAnnualRecurringRevenue());
        o.setMonthlyRecurringRevenue(req.getMonthlyRecurringRevenue());
        o.setExpectedRevenue(req.getExpectedRevenue());
        o.setCurrencyIsoCode(req.getCurrencyIsoCode() != null ? req.getCurrencyIsoCode() : "USD");
        o.setBillingFrequency(req.getBillingFrequency());
        o.setPaymentTerms(req.getPaymentTerms());
        o.setAgreementForm(req.getAgreementForm());
        o.setPoNumber(req.getPoNumber());
        o.setTermInMonths(req.getTermInMonths());
        o.setNoticePeriodInDays(req.getNoticePeriodInDays());
        o.setAutoRenewal(req.getAutoRenewal());
        o.setBillingEmail(req.getBillingEmail());
        // Step 3 — Dates
        o.setCloseDate(req.getCloseDate());
        o.setStartDate(req.getStartDate());
        o.setEndDate(req.getEndDate());
        o.setForecastDate(req.getForecastDate());
        o.setQuoteValidityDate(req.getQuoteValidityDate());
        o.setWon(false);
        o.setClosed(false);
        o.setDeleted(false);
        return toDto(repo.save(o), tid);
    }

    private OpportunityDto toDto(Opportunity o, UUID tid) {
        String accountName = o.getAccountId() != null
                ? accountRepo.findByIdAndTenantIdAndDeletedFalse(o.getAccountId(), tid)
                .map(a -> a.getName()).orElse(null) : null;
        return OpportunityDto.builder()
                .id(o.getId()).name(o.getName()).description(o.getDescription())
                .type(o.getType()).accountBookingStatus(o.getAccountBookingStatus())
                .leadSource(o.getLeadSource()).stageName(o.getStageName())
                .forecastCategory(o.getForecastCategory()).forecastCategoryName(o.getForecastCategoryName())
                .probability(o.getProbability()).pushCount(o.getPushCount())
                .amount(o.getAmount()).annualRecurringRevenue(o.getAnnualRecurringRevenue())
                .monthlyRecurringRevenue(o.getMonthlyRecurringRevenue())
                .expectedRevenue(o.getExpectedRevenue()).newBusinessRevenue(o.getNewBusinessRevenue())
                .remainingBalance(o.getRemainingBalance()).currencyIsoCode(o.getCurrencyIsoCode())
                .renewalPriceIncreasePct(o.getRenewalPriceIncreasePct())
                .closeDate(o.getCloseDate()).startDate(o.getStartDate()).endDate(o.getEndDate())
                .forecastDate(o.getForecastDate()).quoteValidityDate(o.getQuoteValidityDate())
                .dateWon(o.getDateWon()).lastActivityDate(o.getLastActivityDate())
                .lastStageChangeDate(o.getLastStageChangeDate())
                .timestampActivation(o.getTimestampActivation()).timestampDiscovery(o.getTimestampDiscovery())
                .timestampNegotiation(o.getTimestampNegotiation()).timestampFinalisation(o.getTimestampFinalisation())
                .timestampClosed(o.getTimestampClosed()).contractDuration(o.getContractDuration())
                .termInMonths(o.getTermInMonths()).autoRenewal(o.getAutoRenewal())
                .billingFrequency(o.getBillingFrequency()).paymentTerms(o.getPaymentTerms())
                .poNumber(o.getPoNumber()).agreementForm(o.getAgreementForm())
                .billingEmail(o.getBillingEmail()).billingCity(o.getBillingCity())
                .billingCountryCode(o.getBillingCountryCode()).dealType(o.getDealType())
                .platform(o.getPlatform()).profitCenter(o.getProfitCenter())
                .primaryProduct(o.getPrimaryProduct()).productOfInterest(o.getProductOfInterest())
                .clearingHouse(o.getClearingHouse()).renewalSentiment(o.getRenewalSentiment())
                .approvalStatus(o.getApprovalStatus()).closingReason(o.getClosingReason())
                .closingReasonDetail(o.getClosingReasonDetail()).won(o.getWon()).closed(o.getClosed())
                .isPrivate(o.getIsPrivate()).isAutoRenewal(o.getIsAutoRenewal())
                .isTrial(o.getIsTrial()).isWinBack(o.getIsWinBack()).isGlobal(o.getIsGlobal())
                .hasConnectProduct(o.getHasConnectProduct()).discoveryCompleted(o.getDiscoveryCompleted())
                .budgetConfirmed(o.getBudgetConfirmed()).iqScore(o.getIqScore())
                .fiscal(o.getFiscal()).fiscalQuarter(o.getFiscalQuarter()).fiscalYear(o.getFiscalYear())
                .accountId(o.getAccountId()).accountName(accountName).ownerId(o.getOwnerId())
                .primaryContactId(o.getPrimaryContactId()).primaryContactName(o.getPrimaryContactName())
                .clientSuccessManagerId(o.getClientSuccessManagerId()).pricebook2Id(o.getPricebook2Id())
                .pricebookName(o.getPricebookName()).salesTeamText(o.getSalesTeamText())
                .ownerProfitCenter(o.getOwnerProfitCenter()).accountCountry(o.getAccountCountry())
                .nextStep(o.getNextStep()).createdAt(o.getCreatedAt()).updatedAt(o.getUpdatedAt()).build();
    }
}
