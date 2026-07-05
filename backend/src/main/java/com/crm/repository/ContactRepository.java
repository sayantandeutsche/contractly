package com.crm.repository;
import com.crm.entity.Contact;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import java.util.UUID;
public interface ContactRepository extends JpaRepository<Contact, UUID> {
    Page<Contact> findByTenantIdAndDeletedFalse(UUID tenantId, Pageable pageable);
    java.util.Optional<Contact> findByIdAndTenantIdAndDeletedFalse(UUID id, UUID tenantId);
}
