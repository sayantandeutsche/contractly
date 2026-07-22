package com.crm.dto;

import lombok.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class ProductDto {
    private UUID id;
    private String name;
    private String productCode;
    private String description;
    private String family;
    private Boolean isActive;
    private String quantityUnitOfMeasure;
    private String stockKeepingUnit;
    private String displayUrl;
    private String externalId;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;
}
