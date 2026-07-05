package com.crm.controller;
import com.crm.dto.AccountDto;
import com.crm.dto.PageResponse;
import com.crm.service.AccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;
@RestController
@RequestMapping("/v1/accounts")
@RequiredArgsConstructor
public class AccountController {
    private final AccountService service;
    @GetMapping
    public ResponseEntity<PageResponse<AccountDto>> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "25") int size,
            @RequestParam(defaultValue = "createdAt") String sort) {
        return ResponseEntity.ok(service.list(page, size, sort));
    }
    @GetMapping("/{id}")
    public ResponseEntity<AccountDto> get(@PathVariable UUID id) {
        return ResponseEntity.ok(service.get(id));
    }
}
