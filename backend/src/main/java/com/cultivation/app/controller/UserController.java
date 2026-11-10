package com.cultivation.app.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cultivation.app.dto.AuthResponse;
import com.cultivation.app.dto.ChangePasswordRequest;
import com.cultivation.app.dto.DeleteAccountRequest;
import com.cultivation.app.dto.UserResponse;
import com.cultivation.app.dto.UserUpdateRequest;
import com.cultivation.app.entity.User;
import com.cultivation.app.service.UserService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/users")
@Tag(name = "Users", description = "User profile and settings")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/me")
    @Operation(summary = "Get my profile and settings")
    public ResponseEntity<UserResponse> getMe(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(userService.getMe(currentUser));
    }

    @PutMapping("/me")
    @Operation(summary = "Update my profile and settings")
    public ResponseEntity<UserResponse> updateMe(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody UserUpdateRequest request) {
        return ResponseEntity.ok(userService.updateMe(currentUser, request));
    }

    @PostMapping("/me/password")
    @Operation(summary = "Change my password; other sessions are signed out")
    public ResponseEntity<AuthResponse> changePassword(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody ChangePasswordRequest request) {
        return ResponseEntity.ok(userService.changePassword(currentUser, request));
    }

    @DeleteMapping("/me")
    @Operation(summary = "Permanently delete my account and all of its data")
    public ResponseEntity<Void> deleteMe(
            @AuthenticationPrincipal User currentUser,
            @RequestBody(required = false) DeleteAccountRequest request) {
        userService.deleteAccount(currentUser, request);
        return ResponseEntity.noContent().build();
    }
}
