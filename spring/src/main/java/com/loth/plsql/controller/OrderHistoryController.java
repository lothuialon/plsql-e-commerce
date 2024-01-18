package com.loth.plsql.controller;

import com.loth.plsql.dto.TokenDTO;
import com.loth.plsql.service.OrderHistoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1")
public class OrderHistoryController {

    private final OrderHistoryService orderHistoryService;

    @Autowired
    public OrderHistoryController(OrderHistoryService orderHistoryService) {
        this.orderHistoryService = orderHistoryService;
    }

    @GetMapping("/get-order-history")
    public ResponseEntity<List<Map<String, Object>>> getOrderHistory(@RequestBody TokenDTO token) {
        try {
            List<Map<String, Object>> orderHistory = orderHistoryService.getOrderHistory(token.getToken());
            return new ResponseEntity<>(orderHistory, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/export-order-history")
    public ResponseEntity<String> exportOrderHistory(@RequestBody TokenDTO token) {
        try {
            orderHistoryService.exportOrderHistory(token.getToken());
            return new ResponseEntity<>("Order history exported successfully", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Failed to export order history: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }
}
