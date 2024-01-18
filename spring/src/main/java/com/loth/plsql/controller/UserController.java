package com.loth.plsql.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.loth.plsql.dto.TokenDTO;
import com.loth.plsql.dto.UserDTO;
import com.loth.plsql.service.UserService;


@RestController
@RequestMapping("/api/v1")
public class UserController {

    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

 @PostMapping("/authenticate")
 public ResponseEntity<String> authenticateUser(@RequestBody UserDTO user) {

    try {
        System.out.println("Received UserDTO: " + user);
        String token = userService.authenticateUser(user.getEmail(), user.getPassword());
        return new ResponseEntity<>("Token: " + token, HttpStatus.OK);
    } catch (DataAccessException e) {
        return new ResponseEntity<>("Authentication failed: " + e.getMessage(), HttpStatus.BAD_REQUEST);
    }

}

@PostMapping("/register")
public ResponseEntity<String> registerUser(@RequestBody UserDTO user) {
    try {
        //System.out.println("Received UserDTO: " + user);
        userService.registerUser(user.getFirstName(), user.getLastName(), user.getEmail(), user.getPassword());
        return new ResponseEntity<>("User registered successfully", HttpStatus.CREATED);
    } catch (DataAccessException e) {
        return new ResponseEntity<>("Registration failed: " + e.getMessage(), HttpStatus.BAD_REQUEST);
    }
}



@PostMapping("/logout")
public ResponseEntity<String> logout(@RequestBody TokenDTO token) {
    try {
        userService.logout(token.getToken());
        return new ResponseEntity<>("", HttpStatus.OK);
    } catch (DataAccessException e) {
        return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
}

}