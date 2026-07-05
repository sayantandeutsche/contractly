package com.crm.controller;
import com.crm.dto.ContractDto;
import com.crm.dto.PageResponse;
import com.crm.service.ContractService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;
@RestController
@RequestMapping("/v1/contracts")
@RequiredArgsConstructor
public class ContractController {
    private final ContractService service;
    @GetMapping
    public ResponseEntity<PageResponse<ContractDto>> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "25") int size,
            @RequestParam(defaultValue = "createdAt") String sort) {
        return ResponseEntity.ok(service.list(page, size, sort));
    }
    @GetMapping("/{id}")
    public ResponseEntity<ContractDto> get(@PathVariable UUID id) {
        return ResponseEntity.ok(service.get(id));
    }
}
