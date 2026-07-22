package com.crm.security;

import java.util.UUID;

/**
 * Principal carried in the Spring Security context for every authenticated
 * request. Decoded straight from the verified JWT — no DB hit needed.
 */
public record AuthenticatedUser(
        UUID userId,
        UUID tenantId,
        String email,
        String firstName,
        String lastName,
        boolean isAdmin
) {}
