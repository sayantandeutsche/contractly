package com.crm.repository;

import com.crm.entity.Product;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import java.util.Optional;
import java.util.UUID;

public interface ProductRepository extends JpaRepository<Product, UUID> {
    Page<Product> findByTenantIdAndDeletedFalse(UUID tenantId, Pageable pageable);
    Optional<Product> findByIdAndTenantIdAndDeletedFalse(UUID id, UUID tenantId);
}
