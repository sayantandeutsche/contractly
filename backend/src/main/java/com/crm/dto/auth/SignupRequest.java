package com.crm.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class SignupRequest {
    @NotBlank
    private String organizationName;

    @NotBlank
    private String firstName;

    @NotBlank
    private String lastName;

    @NotBlank @Email
    private String email;

    @NotBlank @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;
}
