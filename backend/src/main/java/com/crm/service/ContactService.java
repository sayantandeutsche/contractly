package com.crm.service;
import com.crm.config.TenantContext;
import com.crm.dto.*;
import com.crm.entity.Contact;
import com.crm.exception.ResourceNotFoundException;
import com.crm.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.UUID;
@Service @RequiredArgsConstructor
public class ContactService {
    private final ContactRepository repo;
    private final AccountRepository accountRepo;
    @Transactional(readOnly = true)
    public PageResponse<ContactDto> list(int page, int size, String sort) {
        UUID tid = UUID.fromString(TenantContext.get());
        Pageable pg = PageRequest.of(page, size, Sort.by(Sort.Direction.ASC, "lastName"));
        Page<Contact> result = repo.findByTenantIdAndDeletedFalse(tid, pg);
        return new PageResponse<>(result.getContent().stream().map(c -> toDto(c, tid)).toList(),
            page, size, result.getTotalElements(), result.getTotalPages(), result.isLast());
    }
    @Transactional(readOnly = true)
    public ContactDto get(UUID id) {
        UUID tid = UUID.fromString(TenantContext.get());
        return repo.findByIdAndTenantIdAndDeletedFalse(id, tid)
            .map(c -> toDto(c, tid))
            .orElseThrow(() -> new ResourceNotFoundException("Contact", id.toString()));
    }
    private ContactDto toDto(Contact c, UUID tid) {
        String accountName = c.getAccountId() != null
            ? accountRepo.findByIdAndTenantIdAndDeletedFalse(c.getAccountId(), tid)
                .map(a -> a.getName()).orElse(null)
            : null;
        return ContactDto.builder()
            .id(c.getId())
            .salutation(c.getSalutation())
            .firstName(c.getFirstName())
            .lastName(c.getLastName())
            .name(c.getName())
            .title(c.getTitle())
            .titleType(c.getTitleType())
            .academicTitle(c.getAcademicTitle())
            .departmentPicklist(c.getDepartmentPicklist())
            .department(c.getDepartment())
            .roleLevel(c.getRoleLevel())
            .email(c.getEmail())
            .email2(c.getEmail2())
            .phone(c.getPhone())
            .mobilePhone(c.getMobilePhone())
            .homePhone(c.getHomePhone())
            .doNotCall(c.getDoNotCall())
            .hasOptedOutOfEmail(c.getHasOptedOutOfEmail())
            .unsubscribed(c.getUnsubscribed())
            .linkedin(c.getLinkedin())
            .mailingStreet(c.getMailingStreet())
            .mailingCity(c.getMailingCity())
            .mailingState(c.getMailingState())
            .mailingPostalCode(c.getMailingPostalCode())
            .mailingCountry(c.getMailingCountry())
            .mailingCountryCode(c.getMailingCountryCode())
            .leadSource(c.getLeadSource())
            .contactSource(c.getContactSource())
            .platform(c.getPlatform())
            .productOfInterest(c.getProductOfInterest())
            .subscriptionStatus(c.getSubscriptionStatus())
            .userStatus(c.getUserStatus())
            .licenseType(c.getLicenseType())
            .licenseIsActive(c.getLicenseIsActive())
            .currencyIsoCode(c.getCurrencyIsoCode())
            .activeDaysLast90(c.getActiveDaysLast90())
            .contentViewsLast90(c.getContentViewsLast90())
            .wasActiveLast90(c.getWasActiveLast90())
            .lastActiveDate(c.getLastActiveDate())
            .accountId(c.getAccountId())
            .accountName(accountName)
            .ownerId(c.getOwnerId())
            .description(c.getDescription())
            .convertedFromLead(c.getConvertedFromLead())
            .createdAt(c.getCreatedAt())
            .updatedAt(c.getUpdatedAt())
            .build();
    }
}
