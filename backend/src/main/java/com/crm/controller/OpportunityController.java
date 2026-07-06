package com.crm.controller;

import com.crm.dto.*;
import com.crm.service.OpportunityService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;

@RestController @RequestMapping("/v1/opportunities") @RequiredArgsConstructor
public class OpportunityController {
    private final OpportunityService service;

    @GetMapping
    public ResponseEntity<PageResponse<OpportunityDto>> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "25") int size,
            @RequestParam(defaultValue = "createdAt") String sort) {
        return ResponseEntity.ok(service.list(page, size, sort));
    }

    @GetMapping("/{id}")
    public ResponseEntity<OpportunityDto> get(@PathVariable UUID id) {
        return ResponseEntity.ok(service.get(id));
    }

    @PostMapping
    public ResponseEntity<OpportunityDto> create(@Valid @RequestBody CreateOpportunityRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(req));
    }
}
