package com.crm.repository;
import com.crm.entity.Opportunity;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import java.util.UUID;
public interface OpportunityRepository extends JpaRepository<Opportunity, UUID> {
    Page<Opportunity> findByTenantIdAndDeletedFalse(UUID tenantId, Pageable pageable);
    java.util.Optional<Opportunity> findByIdAndTenantIdAndDeletedFalse(UUID id, UUID tenantId);
}
