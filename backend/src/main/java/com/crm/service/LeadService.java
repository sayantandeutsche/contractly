package com.crm.service;
import com.crm.config.TenantContext;
import com.crm.dto.*;
import com.crm.entity.Lead;
import com.crm.exception.ResourceNotFoundException;
import com.crm.repository.LeadRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.UUID;
@Service @RequiredArgsConstructor
public class LeadService {
    private final LeadRepository repo;
    @Transactional(readOnly = true)
    public PageResponse<LeadDto> list(int page, int size, String sort) {
        UUID tid = UUID.fromString(TenantContext.get());
        Pageable pg = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Lead> result = repo.findByTenantIdAndDeletedFalse(tid, pg);
        return new PageResponse<>(result.getContent().stream().map(this::toDto).toList(),
            page, size, result.getTotalElements(), result.getTotalPages(), result.isLast());
    }
    @Transactional(readOnly = true)
    public LeadDto get(UUID id) {
        UUID tid = UUID.fromString(TenantContext.get());
        return repo.findByIdAndTenantIdAndDeletedFalse(id, tid)
            .map(this::toDto)
            .orElseThrow(() -> new ResourceNotFoundException("Lead", id.toString()));
    }
    private LeadDto toDto(Lead l) {
        return LeadDto.builder()
            .id(l.getId())
            .salutation(l.getSalutation())
            .firstName(l.getFirstName())
            .lastName(l.getLastName())
            .name(l.getName())
            .title(l.getTitle())
            .company(l.getCompany())
            .email(l.getEmail())
            .phone(l.getPhone())
            .mobilePhone(l.getMobilePhone())
            .website(l.getWebsite())
            .city(l.getCity())
            .state(l.getState())
            .country(l.getCountry())
            .countryCode(l.getCountryCode())
            .status(l.getStatus())
            .leadSource(l.getLeadSource())
            .leadCategory(l.getLeadCategory())
            .rating(l.getRating())
            .industry(l.getIndustry())
            .department(l.getDepartment())
            .roleLevel(l.getRoleLevel())
            .platform(l.getPlatform())
            .profitCenter(l.getProfitCenter())
            .productOfInterest(l.getProductOfInterest())
            .subscriptionStatus(l.getSubscriptionStatus())
            .leadStatusCdp(l.getLeadStatusCdp())
            .unqualifyReason(l.getUnqualifyReason())
            .annualRevenue(l.getAnnualRevenue())
            .numberOfEmployees(l.getNumberOfEmployees())
            .numberOfEmployeesRange(l.getNumberOfEmployeesRange())
            .revenueRange(l.getRevenueRange())
            .companyScore(l.getCompanyScore())
            .personScore(l.getPersonScore())
            .converted(l.getConverted())
            .convertedDate(l.getConvertedDate())
            .nextSteps(l.getNextSteps())
            .outreachActivelySequenced(l.getOutreachActivelySequenced())
            .outreachCurrentSequenceName(l.getOutreachCurrentSequenceName())
            .outreachCurrentSequenceStatus(l.getOutreachCurrentSequenceStatus())
            .enriched(l.getEnriched())
            .enrichedDate(l.getEnrichedDate())
            .domain(l.getDomain())
            .timestampNew(l.getTimestampNew())
            .timestampMql(l.getTimestampMql())
            .timestampQualification(l.getTimestampQualification())
            .lastActivityDate(l.getLastActivityDate())
            .lastMeaningfulConnect(l.getLastMeaningfulConnect())
            .ownerId(l.getOwnerId())
            .description(l.getDescription())
            .createdAt(l.getCreatedAt())
            .updatedAt(l.getUpdatedAt())
            .build();
    }
}
