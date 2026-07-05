package com.crm.controller;
import com.crm.dto.ContactDto;
import com.crm.dto.PageResponse;
import com.crm.service.ContactService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.UUID;
@RestController
@RequestMapping("/v1/contacts")
@RequiredArgsConstructor
public class ContactController {
    private final ContactService service;
    @GetMapping
    public ResponseEntity<PageResponse<ContactDto>> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "25") int size,
            @RequestParam(defaultValue = "createdAt") String sort) {
        return ResponseEntity.ok(service.list(page, size, sort));
    }
    @GetMapping("/{id}")
    public ResponseEntity<ContactDto> get(@PathVariable UUID id) {
        return ResponseEntity.ok(service.get(id));
    }
}
