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
    private OpportunityDto toDto(Opportunity o, UUID tid) {
        String accountName = o.getAccountId() != null
            ? accountRepo.findByIdAndTenantIdAndDeletedFalse(o.getAccountId(), tid)
                .map(a -> a.getName()).orElse(null)
            : null;
        return OpportunityDto.builder()
            .id(o.getId())
            .name(o.getName())
            .description(o.getDescription())
            .type(o.getType())
            .accountBookingStatus(o.getAccountBookingStatus())
            .leadSource(o.getLeadSource())
            .stageName(o.getStageName())
            .forecastCategory(o.getForecastCategory())
            .forecastCategoryName(o.getForecastCategoryName())
            .probability(o.getProbability())
            .pushCount(o.getPushCount())
            .amount(o.getAmount())
            .annualRecurringRevenue(o.getAnnualRecurringRevenue())
            .monthlyRecurringRevenue(o.getMonthlyRecurringRevenue())
            .expectedRevenue(o.getExpectedRevenue())
            .newBusinessRevenue(o.getNewBusinessRevenue())
            .remainingBalance(o.getRemainingBalance())
            .currencyIsoCode(o.getCurrencyIsoCode())
            .renewalPriceIncreasePct(o.getRenewalPriceIncreasePct())
            .closeDate(o.getCloseDate())
            .startDate(o.getStartDate())
            .endDate(o.getEndDate())
            .forecastDate(o.getForecastDate())
            .quoteValidityDate(o.getQuoteValidityDate())
            .dateWon(o.getDateWon())
            .lastActivityDate(o.getLastActivityDate())
            .lastStageChangeDate(o.getLastStageChangeDate())
            .timestampActivation(o.getTimestampActivation())
            .timestampDiscovery(o.getTimestampDiscovery())
            .timestampNegotiation(o.getTimestampNegotiation())
            .timestampFinalisation(o.getTimestampFinalisation())
            .timestampClosed(o.getTimestampClosed())
            .contractDuration(o.getContractDuration())
            .termInMonths(o.getTermInMonths())
            .autoRenewal(o.getAutoRenewal())
            .billingFrequency(o.getBillingFrequency())
            .paymentTerms(o.getPaymentTerms())
            .poNumber(o.getPoNumber())
            .agreementForm(o.getAgreementForm())
            .billingEmail(o.getBillingEmail())
            .billingCity(o.getBillingCity())
            .billingCountryCode(o.getBillingCountryCode())
            .dealType(o.getDealType())
            .platform(o.getPlatform())
            .profitCenter(o.getProfitCenter())
            .primaryProduct(o.getPrimaryProduct())
            .productOfInterest(o.getProductOfInterest())
            .clearingHouse(o.getClearingHouse())
            .renewalSentiment(o.getRenewalSentiment())
            .approvalStatus(o.getApprovalStatus())
            .closingReason(o.getClosingReason())
            .closingReasonDetail(o.getClosingReasonDetail())
            .won(o.getWon())
            .closed(o.getClosed())
            .isPrivate(o.getIsPrivate())
            .isAutoRenewal(o.getIsAutoRenewal())
            .isTrial(o.getIsTrial())
            .isWinBack(o.getIsWinBack())
            .isGlobal(o.getIsGlobal())
            .hasConnectProduct(o.getHasConnectProduct())
            .discoveryCompleted(o.getDiscoveryCompleted())
            .budgetConfirmed(o.getBudgetConfirmed())
            .iqScore(o.getIqScore())
            .fiscal(o.getFiscal())
            .fiscalQuarter(o.getFiscalQuarter())
            .fiscalYear(o.getFiscalYear())
            .accountId(o.getAccountId())
            .accountName(accountName)
            .ownerId(o.getOwnerId())
            .primaryContactId(o.getPrimaryContactId())
            .primaryContactName(o.getPrimaryContactName())
            .clientSuccessManagerId(o.getClientSuccessManagerId())
            .pricebook2Id(o.getPricebook2Id())
            .pricebookName(o.getPricebookName())
            .salesTeamText(o.getSalesTeamText())
            .ownerProfitCenter(o.getOwnerProfitCenter())
            .accountCountry(o.getAccountCountry())
            .nextStep(o.getNextStep())
            .createdAt(o.getCreatedAt())
            .updatedAt(o.getUpdatedAt())
            .build();
    }
}
