package com.crm.repository;
import com.crm.entity.Account;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import java.util.UUID;
public interface AccountRepository extends JpaRepository<Account, UUID> {
    Page<Account> findByTenantIdAndDeletedFalse(UUID tenantId, Pageable pageable);
    java.util.Optional<Account> findByIdAndTenantIdAndDeletedFalse(UUID id, UUID tenantId);
}
