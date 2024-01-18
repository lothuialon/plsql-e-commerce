package com.loth.plsql.controller;

import com.loth.plsql.dto.TokenDTO;
import com.loth.plsql.dto.UserFavoriteDTO;
import com.loth.plsql.service.UserFavoriteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1")
public class UserFavoriteController {

    private final UserFavoriteService userFavoriteService;

    @Autowired
    public UserFavoriteController(UserFavoriteService userFavoriteService) {
        this.userFavoriteService = userFavoriteService;
    }

    @PostMapping("/add-favorite")
    public ResponseEntity<String> addFavorite(@RequestBody UserFavoriteDTO userFavorite) {
        try {
            userFavoriteService.addFavorite(userFavorite.getToken(), userFavorite.getProductId());
            return new ResponseEntity<>("Product added to favorites successfully", HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>("Failed to add product to favorites: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/remove-favorite")
    public ResponseEntity<String> removeFavorite(@RequestBody UserFavoriteDTO userFavorite) {
        try {
            userFavoriteService.removeFavorite(userFavorite.getToken(), userFavorite.getProductId());
            return new ResponseEntity<>("Product removed from favorites successfully", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Failed to remove product from favorites: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/get-favorites")
    public ResponseEntity<List<Map<String, Object>>> getFavorites(@RequestBody TokenDTO token) {
        try {
            List<Map<String, Object>> favorites = userFavoriteService.getFavorites(token.getToken());
            return new ResponseEntity<>(favorites, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }
}

