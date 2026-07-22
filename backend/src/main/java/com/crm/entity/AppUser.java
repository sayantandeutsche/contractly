package com.crm.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * Maps to crm.app_user (04_core_tables.sql + 10_auth_columns.sql).
 * One row per licensed user of a tenant; auth_provider distinguishes
 * email/password ("local") accounts from Google-linked accounts.
 */
@Entity
@Table(name = "app_user", schema = "crm")
@Getter @Setter @NoArgsConstructor
public class AppUser {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "tenant_id", nullable = false, updatable = false)
    private UUID tenantId;

    private String email;

    @Column(name = "first_name") private String firstName;
    @Column(name = "last_name")  private String lastName;
    private String title;

    @Column(name = "is_active") private Boolean isActive = true;
    @Column(name = "is_admin")  private Boolean isAdmin = false;
    private String profile = "Standard User";

    @Column(name = "last_login_at") private OffsetDateTime lastLoginAt;

    @Column(name = "password_hash") private String passwordHash;
    @Column(name = "auth_provider") private String authProvider = "local";
    @Column(name = "google_sub")    private String googleSub;
    @Column(name = "avatar_url")    private String avatarUrl;

    @CreationTimestamp @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @UpdateTimestamp @Column(name = "updated_at")
    private OffsetDateTime updatedAt;
}
