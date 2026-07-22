package com.crm.service;

import com.crm.config.TenantContext;
import com.crm.dto.*;
import com.crm.entity.Product;
import com.crm.exception.ResourceNotFoundException;
import com.crm.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.UUID;

@Service @RequiredArgsConstructor
public class ProductService {

    private final ProductRepository repo;

    @Transactional(readOnly = true)
    public PageResponse<ProductDto> list(int page, int size, String sort) {
        UUID tid = UUID.fromString(TenantContext.get());
        Pageable pg = PageRequest.of(page, size, Sort.by(Sort.Direction.ASC, "name"));
        Page<Product> result = repo.findByTenantIdAndDeletedFalse(tid, pg);
        return new PageResponse<>(
            result.getContent().stream().map(this::toDto).toList(),
            page, size, result.getTotalElements(), result.getTotalPages(), result.isLast()
        );
    }

    @Transactional(readOnly = true)
    public ProductDto get(UUID id) {
        UUID tid = UUID.fromString(TenantContext.get());
        return repo.findByIdAndTenantIdAndDeletedFalse(id, tid)
            .map(this::toDto)
            .orElseThrow(() -> new ResourceNotFoundException("Product", id.toString()));
    }

    @Transactional
    public ProductDto create(CreateProductRequest req) {
        UUID tid = UUID.fromString(TenantContext.get());
        Product p = new Product();
        p.setTenantId(tid);
        p.setName(req.getName());
        p.setProductCode(req.getProductCode());
        p.setDescription(req.getDescription());
        p.setFamily(req.getFamily());
        p.setIsActive(req.getIsActive() != null ? req.getIsActive() : true);
        p.setQuantityUnitOfMeasure(req.getQuantityUnitOfMeasure());
        p.setStockKeepingUnit(req.getStockKeepingUnit());
        p.setDisplayUrl(req.getDisplayUrl());
        p.setExternalId(req.getExternalId());
        p.setDeleted(false);
        return toDto(repo.save(p));
    }

    private ProductDto toDto(Product p) {
        return ProductDto.builder()
            .id(p.getId())
            .name(p.getName())
            .productCode(p.getProductCode())
            .description(p.getDescription())
            .family(p.getFamily())
            .isActive(p.getIsActive())
            .quantityUnitOfMeasure(p.getQuantityUnitOfMeasure())
            .stockKeepingUnit(p.getStockKeepingUnit())
            .displayUrl(p.getDisplayUrl())
            .externalId(p.getExternalId())
            .createdAt(p.getCreatedAt())
            .updatedAt(p.getUpdatedAt())
            .build();
    }
}
