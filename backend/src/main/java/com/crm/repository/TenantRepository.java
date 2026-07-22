package com.crm.repository;

import com.crm.entity.Tenant;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface TenantRepository extends JpaRepository<Tenant, UUID> {
}
