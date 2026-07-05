package com.crm.controller;
import com.crm.dto.OpportunityDto;
import com.crm.dto.PageResponse;
import com.crm.service.OpportunityService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;
@RestController
@RequestMapping("/v1/opportunitys")
@RequiredArgsConstructor
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
}
