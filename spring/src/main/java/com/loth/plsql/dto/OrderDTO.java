package com.loth.plsql.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class OrderDTO {

    private String token;
    private int paymentOptionId;
    private int orderId;
    private String trackingCode;
    private String shippingCompanyName;

}
