package com.loth.plsql.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class UserFavoriteDTO {

    private String token;
    private int productId;
}
