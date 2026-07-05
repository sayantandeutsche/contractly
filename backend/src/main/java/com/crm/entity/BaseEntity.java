package com.crm.entity;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.*;
import java.util.UUID;
@MappedSuperclass @Getter @Setter
public abstract class BaseEntity {
    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;
    @Column(name = "tenant_id", nullable = false, updatable = false)
    private UUID tenantId;
    @Column(name = "is_deleted") private Boolean deleted = false;
    @Column(name = "deleted_at") private OffsetDateTime deletedAt;
    @CreationTimestamp @Column(name = "created_at", updatable = false) private OffsetDateTime createdAt;
    @UpdateTimestamp @Column(name = "updated_at") private OffsetDateTime updatedAt;
}
