package com.loth.plsql.dto;


import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class CartDTO {

    private String token;
    private int productId;
    private int quantity;

}

