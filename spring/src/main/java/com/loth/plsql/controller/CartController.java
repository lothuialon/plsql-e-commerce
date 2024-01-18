package com.loth.plsql.controller;

import com.loth.plsql.dto.CartDTO;
import com.loth.plsql.dto.TokenDTO;
import com.loth.plsql.service.CartService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1")
public class CartController {

    private final CartService cartService;

    @Autowired
    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @PostMapping("/add-product-to-cart")
    public ResponseEntity<String> addProductToCart(@RequestBody CartDTO cart) {
        try {
            cartService.addProductToCart(cart.getToken(), cart.getProductId(), cart.getQuantity());
            return new ResponseEntity<>("Product added to cart successfully", HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>("Failed to add product to cart: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/remove-product-from-cart")
    public ResponseEntity<String> removeProductFromCart(@RequestBody CartDTO cart) {
        try {
            cartService.removeProductFromCart(cart.getToken(), cart.getProductId(), cart.getQuantity());
            return new ResponseEntity<>("Product removed from cart successfully", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Failed to remove product from cart: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/remove-all-products-from-cart")
    public ResponseEntity<String> removeAllProductsFromCart(@RequestBody CartDTO cart) {
        try {
            cartService.removeAllProductsFromCart(cart.getToken());
            return new ResponseEntity<>("All products removed from cart successfully", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Failed to remove all products from cart: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/get-cart-information")
    public ResponseEntity<List<Map<String, Object>>> getCartInformation(@RequestBody TokenDTO token) {
        try {
            List<Map<String, Object>> products = cartService.getCartInformation(token.getToken());
            return new ResponseEntity<>(products, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }
}
