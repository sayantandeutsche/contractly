package com.crm.config;

/**
 * Thread-local holder for the current tenant ID.
 * Set by JwtAuthFilter (from the verified JWT) or TenantFilter (fallback).
 */
public class TenantContext {
    private static final ThreadLocal<String> CURRENT = new ThreadLocal<>();
    private static final ThreadLocal<Boolean> BYPASS = new ThreadLocal<>();

    public static void set(String tenantId) { CURRENT.set(tenantId); }
    public static String get()              { return CURRENT.get(); }
    public static void clear()              { CURRENT.remove(); BYPASS.remove(); }

    /**
     * Signup/login must look up a user (or create a tenant) before any
     * tenant context exists. Only AuthService may set this — it is never
     * derived from client input — and it only widens RLS visibility for
     * the duration of that one pre-auth lookup/creation.
     */
    public static void setBypass(boolean bypass) { BYPASS.set(bypass); }
    public static boolean isBypass()             { return Boolean.TRUE.equals(BYPASS.get()); }
}
