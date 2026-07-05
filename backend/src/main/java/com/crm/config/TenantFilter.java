package com.crm.config;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import java.io.IOException;

/**
 * Resolves tenant from request header X-Tenant-ID (or falls back to default).
 * Sets Postgres session variable app.current_tenant_id via EntityManager.
 */
@Component
@Order(1)
public class TenantFilter implements Filter {

    @Value("${app.default-tenant-id}")
    private String defaultTenantId;

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest http = (HttpServletRequest) req;
        String tenantId = http.getHeader("X-Tenant-ID");
        if (tenantId == null || tenantId.isBlank()) tenantId = defaultTenantId;
        TenantContext.set(tenantId);
        try {
            chain.doFilter(req, res);
        } finally {
            TenantContext.clear();
        }
    }
}
