package com.loth.plsql.controller;

import com.loth.plsql.dto.ProductDTO;
import com.loth.plsql.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1")
public class ProductController {

    private final ProductService productService;

    @Autowired
    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @PostMapping("/insert-product")
    public ResponseEntity<String> insertProduct(@RequestBody ProductDTO product) {
        try {
            productService.insertProduct(product.getCategoryId(), product.getTitle(), product.getDescription(), product.getQuantity(), product.getPrice());
            return new ResponseEntity<>("Product inserted successfully", HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>("Product insertion failed: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/delete-product/{productId}")
    public ResponseEntity<String> deleteProduct(@PathVariable int productId) {
        try {
            productService.deleteProduct(productId);
            return new ResponseEntity<>("Product deleted successfully", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Product deletion failed: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/filter-product")
    public ResponseEntity<List<Map<String, Object>>> filterProduct(@RequestParam int categoryId, @RequestParam String orderBy, @RequestParam int pageSize, @RequestParam int pageNumber, @RequestParam String sort) {
        try {
            System.out.println(categoryId);
            List<Map<String, Object>> products = productService.filterProduct(categoryId, orderBy, pageSize, pageNumber, sort);
            return new ResponseEntity<>(products, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }
}
