package com.crm.dto.auth;

import com.crm.security.AuthenticatedUser;
import lombok.Builder;
import lombok.Getter;

import java.util.UUID;

@Getter
@Builder
public class UserDto {
    private UUID id;
    private UUID tenantId;
    private String email;
    private String firstName;
    private String lastName;
    private boolean admin;

    public static UserDto from(AuthenticatedUser u) {
        return UserDto.builder()
                .id(u.userId())
                .tenantId(u.tenantId())
                .email(u.email())
                .firstName(u.firstName())
                .lastName(u.lastName())
                .admin(u.isAdmin())
                .build();
    }
}
