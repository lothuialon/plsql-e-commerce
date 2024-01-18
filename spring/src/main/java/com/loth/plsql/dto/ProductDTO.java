package com.loth.plsql.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ProductDTO {

    private int categoryId;
    private String title;
    private String description;
    private int quantity;
    private double price;
}
