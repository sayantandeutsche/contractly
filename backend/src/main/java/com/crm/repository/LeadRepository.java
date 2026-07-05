package com.crm.repository;
import com.crm.entity.Lead;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import java.util.UUID;
public interface LeadRepository extends JpaRepository<Lead, UUID> {
    Page<Lead> findByTenantIdAndDeletedFalse(UUID tenantId, Pageable pageable);
    java.util.Optional<Lead> findByIdAndTenantIdAndDeletedFalse(UUID id, UUID tenantId);
}
