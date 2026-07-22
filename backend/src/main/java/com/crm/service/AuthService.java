package com.crm.service;

import com.crm.config.TenantContext;
import com.crm.dto.auth.GoogleLoginRequest;
import com.crm.dto.auth.LoginRequest;
import com.crm.dto.auth.SignupRequest;
import com.crm.entity.AppUser;
import com.crm.entity.Tenant;
import com.crm.exception.DuplicateEmailException;
import com.crm.exception.InvalidCredentialsException;
import com.crm.repository.AppUserRepository;
import com.crm.repository.TenantRepository;
import com.crm.security.AuthenticatedUser;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.UUID;

/**
 * Signup provisions a brand-new tenant (organization) with the signing-up
 * person as its first, admin user — later users of that org join via an
 * invite flow (not built yet). Login/Google-login resolve an existing
 * user's tenant from their identity, never from client input.
 *
 * All three entry points run with TenantContext bypass on: at this point
 * in the request no tenant is known yet, so the normal RLS tenant filter
 * (see 10_auth_columns.sql) would hide every row, including the one
 * we're trying to find or the tenant we're trying to create.
 */
@Service
@RequiredArgsConstructor
public class AuthService {

    private final AppUserRepository appUserRepository;
    private final TenantRepository tenantRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${google.client-id}")
    private String googleClientId;

    private GoogleIdTokenVerifier googleVerifier;

    @PostConstruct
    private void init() {
        googleVerifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), GsonFactory.getDefaultInstance())
                .setAudience(Collections.singletonList(googleClientId))
                .build();
    }

    @Transactional
    public AuthenticatedUser signup(SignupRequest req) {
        TenantContext.setBypass(true);
        try {
            String email = req.getEmail().trim().toLowerCase();
            if (appUserRepository.findByEmail(email).isPresent()) {
                throw new DuplicateEmailException(email);
            }

            Tenant tenant = new Tenant();
            tenant.setName(req.getOrganizationName());
            tenant.setSlug(slugify(req.getOrganizationName()));
            tenant = tenantRepository.save(tenant);

            AppUser user = new AppUser();
            user.setTenantId(tenant.getId());
            user.setEmail(email);
            user.setFirstName(req.getFirstName());
            user.setLastName(req.getLastName());
            user.setPasswordHash(passwordEncoder.encode(req.getPassword()));
            user.setAuthProvider("local");
            user.setIsAdmin(true);
            user.setLastLoginAt(OffsetDateTime.now());
            user = appUserRepository.save(user);

            return toAuthenticatedUser(user);
        } finally {
            TenantContext.setBypass(false);
        }
    }

    @Transactional
    public AuthenticatedUser login(LoginRequest req) {
        TenantContext.setBypass(true);
        try {
            String email = req.getEmail().trim().toLowerCase();
            AppUser user = appUserRepository.findByEmail(email)
                    .orElseThrow(InvalidCredentialsException::new);

            if (!"local".equals(user.getAuthProvider()) || user.getPasswordHash() == null
                    || !passwordEncoder.matches(req.getPassword(), user.getPasswordHash())) {
                throw new InvalidCredentialsException();
            }

            user.setLastLoginAt(OffsetDateTime.now());
            user = appUserRepository.save(user);
            return toAuthenticatedUser(user);
        } finally {
            TenantContext.setBypass(false);
        }
    }

    @Transactional
    public AuthenticatedUser googleLogin(GoogleLoginRequest req) {
        GoogleIdToken.Payload payload = verifyGoogleToken(req.getIdToken());
        if (payload.getEmail() == null) {
            throw new InvalidCredentialsException();
        }
        String sub = payload.getSubject();
        String email = payload.getEmail().trim().toLowerCase();

        TenantContext.setBypass(true);
        try {
            AppUser user = appUserRepository.findByGoogleSub(sub).orElse(null);

            if (user == null) {
                user = appUserRepository.findByEmail(email).orElse(null);
                if (user != null) {
                    // Existing local-auth account signing in with Google for the first time.
                    user.setGoogleSub(sub);
                } else {
                    String firstName = (String) payload.get("given_name");
                    String lastName = (String) payload.get("family_name");

                    Tenant tenant = new Tenant();
                    tenant.setName((firstName != null ? firstName : email) + "'s Organization");
                    tenant.setSlug(slugify(tenant.getName()));
                    tenant = tenantRepository.save(tenant);

                    user = new AppUser();
                    user.setTenantId(tenant.getId());
                    user.setEmail(email);
                    user.setFirstName(firstName);
                    user.setLastName(lastName);
                    user.setAuthProvider("google");
                    user.setGoogleSub(sub);
                    user.setAvatarUrl((String) payload.get("picture"));
                    user.setIsAdmin(true);
                }
            }

            user.setLastLoginAt(OffsetDateTime.now());
            user = appUserRepository.save(user);
            return toAuthenticatedUser(user);
        } finally {
            TenantContext.setBypass(false);
        }
    }

    private GoogleIdToken.Payload verifyGoogleToken(String idTokenString) {
        try {
            GoogleIdToken idToken = googleVerifier.verify(idTokenString);
            if (idToken == null) throw new InvalidCredentialsException();
            return idToken.getPayload();
        } catch (InvalidCredentialsException e) {
            throw e;
        } catch (Exception e) {
            throw new InvalidCredentialsException();
        }
    }

    private AuthenticatedUser toAuthenticatedUser(AppUser user) {
        return new AuthenticatedUser(
                user.getId(),
                user.getTenantId(),
                user.getEmail(),
                user.getFirstName(),
                user.getLastName(),
                Boolean.TRUE.equals(user.getIsAdmin())
        );
    }

    private String slugify(String name) {
        String base = name == null ? "org" : name.toLowerCase().trim()
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("(^-+|-+$)", "");
        if (base.isBlank()) base = "org";
        return base + "-" + UUID.randomUUID().toString().substring(0, 8);
    }
}
