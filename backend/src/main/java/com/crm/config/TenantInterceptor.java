package com.crm.config;

import jakarta.persistence.*;
import org.hibernate.resource.jdbc.spi.StatementInspector;
import org.springframework.stereotype.Component;

/**
 * Executes SET LOCAL app.current_tenant_id before each JPA transaction
 * so Postgres RLS policies are enforced automatically.
 */
@Component
public class TenantInterceptor implements StatementInspector {

    @PersistenceContext
    private EntityManager em;

    @Override
    public String inspect(String sql) {
        String tid = TenantContext.get();
        if (tid != null && em != null) {
            em.createNativeQuery(
                "SET LOCAL app.current_tenant_id = '" + tid + "'"
            ).executeUpdate();
        }
        if (TenantContext.isBypass() && em != null) {
            em.createNativeQuery(
                "SET LOCAL app.bypass_tenant_check = 'on'"
            ).executeUpdate();
        }
        return sql;
    }
}
