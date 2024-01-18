package com.loth.plsql.controller;

import com.loth.plsql.dto.ResetPasswordDTO;
import com.loth.plsql.service.PasswordResetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class PasswordResetController {

    private final PasswordResetService passwordResetService;

    @Autowired
    public PasswordResetController(PasswordResetService passwordResetService) {
        this.passwordResetService = passwordResetService;
    }

    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(@RequestBody ResetPasswordDTO resetPassword) {
        try {
            passwordResetService.resetPassword(resetPassword.getEmail());
            return new ResponseEntity<>("Password reset initiated", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Password reset failed: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/reset-code-check")
    public ResponseEntity<String> resetCodeCheck(@RequestBody ResetPasswordDTO resetPassword) {
        try {
            passwordResetService.resetCodeCheck(resetPassword.getResetCode(), resetPassword.getNewPassword(), resetPassword.getEmail());
            return new ResponseEntity<>("Password reset successful", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Password reset failed: " + e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }
}
