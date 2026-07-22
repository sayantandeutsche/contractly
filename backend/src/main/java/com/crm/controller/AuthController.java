package com.crm.controller;

import com.crm.dto.auth.GoogleLoginRequest;
import com.crm.dto.auth.LoginRequest;
import com.crm.dto.auth.SignupRequest;
import com.crm.dto.auth.UserDto;
import com.crm.security.AuthenticatedUser;
import com.crm.security.JwtAuthFilter;
import com.crm.security.JwtService;
import com.crm.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final JwtService jwtService;

    @Value("${cookie.secure}")
    private boolean cookieSecure;

    @PostMapping("/signup")
    public ResponseEntity<UserDto> signup(@Valid @RequestBody SignupRequest req) {
        return withSession(authService.signup(req));
    }

    @PostMapping("/login")
    public ResponseEntity<UserDto> login(@Valid @RequestBody LoginRequest req) {
        return withSession(authService.login(req));
    }

    @PostMapping("/google")
    public ResponseEntity<UserDto> google(@Valid @RequestBody GoogleLoginRequest req) {
        return withSession(authService.googleLogin(req));
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout() {
        ResponseCookie cleared = ResponseCookie.from(JwtAuthFilter.COOKIE_NAME, "")
                .httpOnly(true).secure(cookieSecure).sameSite("Lax").path("/").maxAge(0)
                .build();
        return ResponseEntity.noContent().header(HttpHeaders.SET_COOKIE, cleared.toString()).build();
    }

    @GetMapping("/me")
    public ResponseEntity<UserDto> me(Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof AuthenticatedUser user)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        return ResponseEntity.ok(UserDto.from(user));
    }

    private ResponseEntity<UserDto> withSession(AuthenticatedUser user) {
        String token = jwtService.issue(user);
        ResponseCookie cookie = ResponseCookie.from(JwtAuthFilter.COOKIE_NAME, token)
                .httpOnly(true).secure(cookieSecure).sameSite("Lax").path("/")
                .maxAge(jwtService.expirationSeconds())
                .build();
        return ResponseEntity.ok().header(HttpHeaders.SET_COOKIE, cookie.toString()).body(UserDto.from(user));
    }
}
