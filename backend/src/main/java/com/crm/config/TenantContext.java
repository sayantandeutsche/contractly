package com.crm.config;

/**
 * Thread-local holder for the current tenant ID.
 * Set by TenantFilter at the start of every request.
 */
public class TenantContext {
    private static final ThreadLocal<String> CURRENT = new ThreadLocal<>();

    public static void set(String tenantId) { CURRENT.set(tenantId); }
    public static String get()              { return CURRENT.get(); }
    public static void clear()              { CURRENT.remove(); }
}
