package com.loth.plsql.controller;

import com.loth.plsql.dto.OrderDTO;
import com.loth.plsql.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1")
public class OrderController {

    private final OrderService orderService;

    @Autowired
    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @PostMapping("/purchase-cart")
    public ResponseEntity<String> purchaseCart(@RequestBody OrderDTO order) {
        try {
            orderService.purchaseCart(order.getToken(), order.getPaymentOptionId());
            return new ResponseEntity<>("Cart purchased successfully", HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>("Failed to purchase cart: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/update-tracking")
    public ResponseEntity<String> updateTracking(@RequestBody OrderDTO order) {
        try {
            orderService.updateTracking(order.getOrderId(), order.getTrackingCode(), order.getShippingCompanyName());
            return new ResponseEntity<>("Order tracking updated successfully", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Failed to update order tracking: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/cancel-order")
    public ResponseEntity<String> cancelOrder(@RequestBody OrderDTO order) {
        try {
            orderService.cancelOrder(order.getToken(), order.getOrderId());
            return new ResponseEntity<>("Order cancelled successfully", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Failed to cancel order: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }
}
