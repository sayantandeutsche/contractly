package com.crm.repository;
import com.crm.entity.Contract;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import java.util.UUID;
public interface ContractRepository extends JpaRepository<Contract, UUID> {
    Page<Contract> findByTenantIdAndDeletedFalse(UUID tenantId, Pageable pageable);
    java.util.Optional<Contract> findByIdAndTenantIdAndDeletedFalse(UUID id, UUID tenantId);
}
