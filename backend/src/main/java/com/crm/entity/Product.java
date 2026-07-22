package com.crm.entity;

import com.crm.converter.PostgresEnumType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Type;

@Entity
@Table(name = "product", schema = "crm")
@Getter @Setter @NoArgsConstructor
public class Product extends BaseEntity {

    private String name;

    @Column(name = "product_code")
    private String productCode;

    private String description;

    @Column(name = "family")
    @Type(PostgresEnumType.class)
    private String family;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "quantity_unit_of_measure")
    private String quantityUnitOfMeasure;

    @Column(name = "stock_keeping_unit")
    private String stockKeepingUnit;

    @Column(name = "display_url")
    private String displayUrl;

    @Column(name = "external_id")
    private String externalId;
}
