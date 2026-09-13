package com.cultivation.app.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cultivation.app.dto.AuthResponse;
import com.cultivation.app.dto.LoginRequest;
import com.cultivation.app.dto.MessageResponse;
import com.cultivation.app.dto.RegisterRequest;
import com.cultivation.app.dto.ResetPasswordRequest;
import com.cultivation.app.dto.SendCodeRequest;
import com.cultivation.app.dto.VerifyCodeRequest;
import com.cultivation.app.entity.EmailVerification.Purpose;
import com.cultivation.app.exception.ApiException;
import com.cultivation.app.repository.UserRepository;
import com.cultivation.app.service.UserService;
import com.cultivation.app.service.VerificationService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication", description = "Registration, login, email verification and password reset")
public class AuthController {

    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    private final UserService userService;
    private final VerificationService verificationService;
    private final UserRepository userRepository;

    public AuthController(UserService userService,
                          VerificationService verificationService,
                          UserRepository userRepository) {
        this.userService = userService;
        this.verificationService = verificationService;
        this.userRepository = userRepository;
    }

    // ------------------------------------------------------------ registration

    @PostMapping("/send-code")
    @Operation(summary = "Email a 6-digit verification code to a prospective user")
    public ResponseEntity<MessageResponse> sendCode(@Valid @RequestBody SendCodeRequest request) {
        String email = request.getEmail().trim().toLowerCase();

        // Registration is the one place where reporting "already registered" is
        // correct: the signup form has to tell the user to log in instead.
        if (userRepository.existsByEmail(email)) {
            throw new ApiException(org.springframework.http.HttpStatus.CONFLICT,
                "This email is already registered. Try logging in instead.");
        }

        verificationService.issueCode(email, Purpose.REGISTRATION);
        return ResponseEntity.ok(new MessageResponse("Verification code sent to " + email));
    }

    @PostMapping("/verify-code")
    @Operation(summary = "Confirm the registration code before completing signup")
    public ResponseEntity<MessageResponse> verifyCode(@Valid @RequestBody VerifyCodeRequest request) {
        verificationService.confirmCode(request.getEmail(), request.getCode(), Purpose.REGISTRATION);
        return ResponseEntity.ok(new MessageResponse("Email verified. You can now complete registration."));
    }

    @PostMapping("/register")
    @Operation(summary = "Create the account once the email has been verified")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(userService.register(request));
    }

    @PostMapping("/login")
    @Operation(summary = "Log in and receive a JWT")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(userService.login(request));
    }

    // ---------------------------------------------------------- password reset

    @PostMapping("/forgot-password")
    @Operation(summary = "Email a 6-digit password reset code")
    public ResponseEntity<MessageResponse> forgotPassword(@Valid @RequestBody SendCodeRequest request) {
        String email = request.getEmail().trim().toLowerCase();

        // Always the same answer whether or not the account exists — otherwise
        // this endpoint tells an attacker which emails are registered.
        if (userRepository.existsByEmail(email)) {
            try {
                verificationService.issueCode(email, Purpose.PASSWORD_RESET);
            } catch (ApiException ex) {
                // Includes the resend cooldown. Swallowed for the same reason:
                // a different response here would still leak existence.
                log.debug("Reset code not issued for {}: {}", email, ex.getMessage());
            }
        } else {
            log.debug("Reset requested for unknown email {}", email);
        }

        return ResponseEntity.ok(new MessageResponse(
            "If that email has an account, a reset code has been sent to it."));
    }

    @PostMapping("/reset-password")
    @Operation(summary = "Set a new password using the emailed reset code")
    public ResponseEntity<MessageResponse> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        verificationService.confirmCode(request.getEmail(), request.getCode(), Purpose.PASSWORD_RESET);
        userService.resetPassword(request.getEmail(), request.getNewPassword());
        return ResponseEntity.ok(new MessageResponse("Password updated. You can now log in."));
    }
}
