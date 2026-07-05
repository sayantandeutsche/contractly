package com.crm.service;
import com.crm.config.TenantContext;
import com.crm.dto.*;
import com.crm.entity.Account;
import com.crm.exception.ResourceNotFoundException;
import com.crm.repository.AccountRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.UUID;
@Service @RequiredArgsConstructor
public class AccountService {
    private final AccountRepository repo;
    @Transactional(readOnly = true)
    public PageResponse<AccountDto> list(int page, int size, String sort) {
        UUID tid = UUID.fromString(TenantContext.get());
        Pageable pg = PageRequest.of(page, size, Sort.by(
            sort.startsWith("-") ? Sort.Direction.DESC : Sort.Direction.ASC,
            sort.replaceFirst("^-", "")));
        Page<Account> result = repo.findByTenantIdAndDeletedFalse(tid, pg);
        return new PageResponse<>(result.getContent().stream().map(this::toDto).toList(),
            page, size, result.getTotalElements(), result.getTotalPages(), result.isLast());
    }
    @Transactional(readOnly = true)
    public AccountDto get(UUID id) {
        UUID tid = UUID.fromString(TenantContext.get());
        return repo.findByIdAndTenantIdAndDeletedFalse(id, tid)
            .map(this::toDto)
            .orElseThrow(() -> new ResourceNotFoundException("Account", id.toString()));
    }
    private AccountDto toDto(Account a) {
        return AccountDto.builder()
            .id(a.getId())
            .name(a.getName())
            .accountNumber(a.getAccountNumber())
            .type(a.getType())
            .industry(a.getIndustry())
            .subIndustry(a.getSubIndustry())
            .customerStatus(a.getCustomerStatus())
            .customerCategory(a.getCustomerCategory())
            .segment(a.getSegment())
            .profitCenter(a.getProfitCenter())
            .platform(a.getPlatform())
            .subscriptionStatus(a.getSubscriptionStatus())
            .healthscore(a.getHealthscore())
            .strategicPotential(a.getStrategicPotential())
            .phone(a.getPhone())
            .fax(a.getFax())
            .website(a.getWebsite())
            .accountEmail(a.getAccountEmail())
            .billingStreet(a.getBillingStreet())
            .billingCity(a.getBillingCity())
            .billingState(a.getBillingState())
            .billingPostalCode(a.getBillingPostalCode())
            .billingCountry(a.getBillingCountry())
            .billingCountryCode(a.getBillingCountryCode())
            .shippingCity(a.getShippingCity())
            .shippingCountry(a.getShippingCountry())
            .annualRevenue(a.getAnnualRevenue())
            .annualizedRevenue(a.getAnnualizedRevenue())
            .monthlyRevenue(a.getMonthlyRevenue())
            .numberOfEmployees(a.getNumberOfEmployees())
            .numberOfEmployeesRange(a.getNumberOfEmployeesRange())
            .fteSize(a.getFteSize())
            .currencyIsoCode(a.getCurrencyIsoCode())
            .rating(a.getRating())
            .accountSource(a.getAccountSource())
            .ownership(a.getOwnership())
            .description(a.getDescription())
            .customerId(a.getCustomerId())
            .domain(a.getDomain())
            .isActiveSubscription(a.getIsActiveSubscription())
            .churnRisk(a.getChurnRisk())
            .ownerId(a.getOwnerId())
            .parentId(a.getParentId())
            .clientSuccessManagerId(a.getClientSuccessManagerId())
            .salesRepresentativeId(a.getSalesRepresentativeId())
            .createdAt(a.getCreatedAt())
            .updatedAt(a.getUpdatedAt())
            .build();
    }
}
