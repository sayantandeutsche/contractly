package com.crm.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class CreateProductRequest {

    @NotBlank(message = "Product name is required")
    @Size(max = 255)
    private String name;

    private String productCode;
    private String description;
    private String family;
    private Boolean isActive;
    private String quantityUnitOfMeasure;
    private String stockKeepingUnit;
    private String displayUrl;
    private String externalId;
}
