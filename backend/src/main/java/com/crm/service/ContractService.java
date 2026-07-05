package com.crm.service;
import com.crm.config.TenantContext;
import com.crm.dto.*;
import com.crm.entity.Contract;
import com.crm.exception.ResourceNotFoundException;
import com.crm.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.UUID;
@Service @RequiredArgsConstructor
public class ContractService {
    private final ContractRepository repo;
    private final AccountRepository accountRepo;
    @Transactional(readOnly = true)
    public PageResponse<ContractDto> list(int page, int size, String sort) {
        UUID tid = UUID.fromString(TenantContext.get());
        Pageable pg = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Contract> result = repo.findByTenantIdAndDeletedFalse(tid, pg);
        return new PageResponse<>(result.getContent().stream().map(c -> toDto(c, tid)).toList(),
            page, size, result.getTotalElements(), result.getTotalPages(), result.isLast());
    }
    @Transactional(readOnly = true)
    public ContractDto get(UUID id) {
        UUID tid = UUID.fromString(TenantContext.get());
        return repo.findByIdAndTenantIdAndDeletedFalse(id, tid)
            .map(c -> toDto(c, tid))
            .orElseThrow(() -> new ResourceNotFoundException("Contract", id.toString()));
    }
    private ContractDto toDto(Contract c, UUID tid) {
        String accountName = c.getAccountId() != null
            ? accountRepo.findByIdAndTenantIdAndDeletedFalse(c.getAccountId(), tid)
                .map(a -> a.getName()).orElse(null)
            : null;
        return ContractDto.builder()
            .id(c.getId())
            .contractNumber(c.getContractNumber())
            .name(c.getName())
            .offerNumber(c.getOfferNumber())
            .legacyId(c.getLegacyId())
            .description(c.getDescription())
            .specialTerms(c.getSpecialTerms())
            .status(c.getStatus())
            .statusCode(c.getStatusCode())
            .contractActive(c.getContractActive())
            .cancellationStatus(c.getCancellationStatus())
            .terminationStatus(c.getTerminationStatus())
            .startDate(c.getStartDate())
            .endDate(c.getEndDate())
            .contractTerm(c.getContractTerm())
            .activatedDate(c.getActivatedDate())
            .companySignedDate(c.getCompanySignedDate())
            .customerSignedDate(c.getCustomerSignedDate())
            .customerSignedTitle(c.getCustomerSignedTitle())
            .cancellationDate(c.getCancellationDate())
            .terminationDate(c.getTerminationDate())
            .noticePeriodStart(c.getNoticePeriodStart())
            .noticePeriodInDays(c.getNoticePeriodInDays())
            .accountBookingStatus(c.getAccountBookingStatus())
            .dealType(c.getDealType())
            .industryType(c.getIndustryType())
            .primaryProduct(c.getPrimaryProduct())
            .serviceLevel(c.getServiceLevel())
            .originalServiceLevel(c.getOriginalServiceLevel())
            .profitCenter(c.getProfitCenter())
            .platform(c.getPlatform())
            .clearingHouse(c.getClearingHouse())
            .businessLanguage(c.getBusinessLanguage())
            .annualizedRevenue(c.getAnnualizedRevenue())
            .monthlyRevenue(c.getMonthlyRevenue())
            .newBusinessRevenue(c.getNewBusinessRevenue())
            .existingBusinessRevenue(c.getExistingBusinessRevenue())
            .totalAmount(c.getTotalAmount())
            .remainingBalance(c.getRemainingBalance())
            .renewalPriceIncreasePct(c.getRenewalPriceIncreasePct())
            .currencyIsoCode(c.getCurrencyIsoCode())
            .billingFrequency(c.getBillingFrequency())
            .billingEmail(c.getBillingEmail())
            .paymentTerms(c.getPaymentTerms())
            .paymentStatus(c.getPaymentStatus())
            .poNumber(c.getPoNumber())
            .agreementForm(c.getAgreementForm())
            .billingStreet(c.getBillingStreet())
            .billingCity(c.getBillingCity())
            .billingState(c.getBillingState())
            .billingPostalCode(c.getBillingPostalCode())
            .billingCountry(c.getBillingCountry())
            .billingCountryCode(c.getBillingCountryCode())
            .shippingCity(c.getShippingCity())
            .shippingCountry(c.getShippingCountry())
            .seats(c.getSeats())
            .totalPurchasedHours(c.getTotalPurchasedHours())
            .totalRemainingHours(c.getTotalRemainingHours())
            .totalPurchasedCredit(c.getTotalPurchasedCredit())
            .totalRemainingCredit(c.getTotalRemainingCredit())
            .contentViewsLast90(c.getContentViewsLast90())
            .downloadsLast90(c.getDownloadsLast90())
            .activeUsersLast90(c.getActiveUsersLast90())
            .healthscore(c.getHealthscore())
            .cancellationReason(c.getCancellationReason())
            .terminationReason(c.getTerminationReason())
            .terminationComments(c.getTerminationComments())
            .liableOffice(c.getLiableOffice())
            .userIntegrationStatus(c.getUserIntegrationStatus())
            .isAutoRenewal(c.getIsAutoRenewal())
            .isGlobal(c.getIsGlobal())
            .isTrial(c.getIsTrial())
            .hasConnect(c.getHasConnect())
            .serviceLevelOverridden(c.getServiceLevelOverridden())
            .excludeFromUserSync(c.getExcludeFromUserSync())
            .openRenewalOpps(c.getOpenRenewalOpps())
            .closedWonRenewalOpps(c.getClosedWonRenewalOpps())
            .numberOfContracts(c.getNumberOfContracts())
            .accountId(c.getAccountId())
            .accountName(accountName)
            .ownerId(c.getOwnerId())
            .opportunityId(c.getOpportunityId())
            .primaryContactId(c.getPrimaryContactId())
            .primaryContactName(c.getPrimaryContactName())
            .primaryCsManagerId(c.getPrimaryCsManagerId())
            .primaryCsManagerName(c.getPrimaryCsManagerName())
            .sourceContractId(c.getSourceContractId())
            .followUpContractId(c.getFollowUpContractId())
            .pricebook2Id(c.getPricebook2Id())
            .salesTeamText(c.getSalesTeamText())
            .createdAt(c.getCreatedAt())
            .updatedAt(c.getUpdatedAt())
            .build();
    }
}
