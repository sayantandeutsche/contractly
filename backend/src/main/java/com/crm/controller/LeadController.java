package com.crm.controller;
import com.crm.dto.LeadDto;
import com.crm.dto.PageResponse;
import com.crm.service.LeadService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;
@RestController
@RequestMapping("/v1/leads")
@RequiredArgsConstructor
public class LeadController {
    private final LeadService service;
    @GetMapping
    public ResponseEntity<PageResponse<LeadDto>> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "25") int size,
            @RequestParam(defaultValue = "createdAt") String sort) {
        return ResponseEntity.ok(service.list(page, size, sort));
    }
    @GetMapping("/{id}")
    public ResponseEntity<LeadDto> get(@PathVariable UUID id) {
        return ResponseEntity.ok(service.get(id));
    }
}
