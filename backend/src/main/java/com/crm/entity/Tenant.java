package com.crm.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * Maps to crm.tenant (04_core_tables.sql) — one row per customer organization.
 */
@Entity
@Table(name = "tenant", schema = "crm")
@Getter @Setter @NoArgsConstructor
public class Tenant {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    private String name;
    private String slug;
    private String plan = "starter";

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "max_users")
    private Integer maxUsers = 10;

    @CreationTimestamp @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @UpdateTimestamp @Column(name = "updated_at")
    private OffsetDateTime updatedAt;
}
