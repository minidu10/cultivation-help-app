package com.cultivation.app.service;

import java.time.LocalDateTime;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.cultivation.app.dto.AuthResponse;
import com.cultivation.app.dto.ChangePasswordRequest;
import com.cultivation.app.dto.DeleteAccountRequest;
import com.cultivation.app.dto.LoginRequest;
import com.cultivation.app.dto.RegisterRequest;
import com.cultivation.app.dto.UserResponse;
import com.cultivation.app.dto.UserUpdateRequest;
import com.cultivation.app.entity.EmailVerification.Purpose;
import com.cultivation.app.entity.User;
import com.cultivation.app.exception.ApiException;
import com.cultivation.app.repository.UserRepository;

@Service
public class UserService {

    private static final String THEME_LIGHT = "LIGHT";
    private static final String THEME_DARK = "DARK";

    private final UserRepository userRepository;
    private final AuthTokenService authTokenService;
    private final VerificationService verificationService;
    private final MailService mailService;
    private final GoogleAuthService googleAuthService;
    private final AccountDeletionService accountDeletionService;
    private final BCryptPasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository,
                       AuthTokenService authTokenService,
                       VerificationService verificationService,
                       MailService mailService,
                       GoogleAuthService googleAuthService,
                       AccountDeletionService accountDeletionService) {
        this.userRepository = userRepository;
        this.authTokenService = authTokenService;
        this.verificationService = verificationService;
        this.mailService = mailService;
        this.googleAuthService = googleAuthService;
        this.accountDeletionService = accountDeletionService;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {

        String email = request.getEmail().trim().toLowerCase();

        if (userRepository.existsByEmail(email)) {
            throw new ApiException(HttpStatus.CONFLICT, "Email already registered");
        }

        // The frontend enforces the step order, but anyone can POST straight
        // here, so the confirmed code is re-checked and then spent.
        verificationService.consume(email, Purpose.REGISTRATION);

        PasswordPolicy.validate(request.getPassword());

        User user = new User();
        user.setFullName(request.getFullName());
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(request.getPassword())); // hashed!
        user.setPhone(request.getPhone());
        user.setCity(request.getCity());
        user.setThemePreference(THEME_LIGHT);
        user.setDesktopMode(false);

        userRepository.save(user);
        mailService.sendWelcome(user.getEmail(), user.getFullName());

        return authTokenService.issue(user);
    }

    public AuthResponse login(LoginRequest request) {

        // One message for both cases: separate errors would tell an attacker
        // which email addresses have accounts.
        User user = userRepository.findByEmail(request.getEmail().trim().toLowerCase())
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Invalid email or password"));

        // Google-only accounts have no password at all. Saying so plainly is
        // fine here: the caller already proved they know a registered email,
        // and the alternative is an NPE inside the encoder.
        if (user.getPassword() == null) {
            throw new ApiException(HttpStatus.UNAUTHORIZED,
                "This account uses Google Sign-In. Use the Google button, or reset your password to set one.");
        }

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid email or password");
        }

        return authTokenService.issue(user);
    }

    @Transactional
    public void resetPassword(String rawEmail, String newPassword) {
        String email = rawEmail.trim().toLowerCase();

        verificationService.consume(email, Purpose.PASSWORD_RESET);
        PasswordPolicy.validate(newPassword);

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Invalid reset request"));

        user.setPassword(passwordEncoder.encode(newPassword));
        // Evicts any token issued before now - including one an attacker holds.
        user.setPasswordChangedAt(LocalDateTime.now());
        userRepository.save(user);
        authTokenService.revokeAll(user);
    }

    /**
     * Change the password while signed in. Every other session is signed out,
     * and this one gets a fresh token pair so the user is not bounced to the
     * login screen for doing the right thing.
     */
    @Transactional
    public AuthResponse changePassword(User currentUser, ChangePasswordRequest request) {
        User user = findUser(currentUser);

        // A Google-only account has no current password to prove. Letting a
        // bare session set one would let a stolen token take the account over,
        // so those users go through the emailed reset code instead.
        if (user.getPassword() == null) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                "This account has no password yet. Use Forgot password to set one.");
        }
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Current password is incorrect");
        }
        PasswordPolicy.validate(request.getNewPassword());

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setPasswordChangedAt(LocalDateTime.now());
        userRepository.save(user);

        authTokenService.revokeAll(user);
        return authTokenService.issue(user);
    }

    /**
     * Permanently deletes the account and every record in it. Required by the
     * app stores for any app that lets people sign up.
     */
    @Transactional
    public void deleteAccount(User currentUser, DeleteAccountRequest request) {
        User user = findUser(currentUser);
        String password = request == null ? null : request.getPassword();
        String googleCredential = request == null ? null : request.getGoogleCredential();

        if (password != null && !password.isBlank()) {
            if (user.getPassword() == null || !passwordEncoder.matches(password, user.getPassword())) {
                throw new ApiException(HttpStatus.FORBIDDEN, "Password is incorrect");
            }
        } else if (googleCredential != null && !googleCredential.isBlank()) {
            googleAuthService.verifyOwnership(user, googleCredential);
        } else {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                user.getPassword() == null
                    ? "Confirm with Google to delete your account"
                    : "Enter your password to delete your account");
        }

        accountDeletionService.deleteEverything(user);
    }

    public UserResponse getMe(User currentUser) {
        return mapToUserResponse(findUser(currentUser));
    }

    public UserResponse updateMe(User currentUser, UserUpdateRequest request) {
        User user = findUser(currentUser);

        if (request.getFullName() != null && !request.getFullName().isBlank()) {
            user.setFullName(request.getFullName().trim());
        }
        if (request.getPhone() != null) {
            user.setPhone(request.getPhone().trim());
        }
        if (request.getCity() != null) {
            user.setCity(request.getCity().trim());
        }
        if (request.getThemePreference() != null) {
            user.setThemePreference(normalizeTheme(request.getThemePreference()));
        }
        if (request.getDesktopMode() != null) {
            user.setDesktopMode(request.getDesktopMode());
        }
        if (request.getReminderEmailsEnabled() != null) {
            user.setReminderEmailsEnabled(request.getReminderEmailsEnabled());
        }

        User saved = userRepository.save(user);
        return mapToUserResponse(saved);
    }

    private User findUser(User currentUser) {
        return userRepository.findById(currentUser.getId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found"));
    }

    private static String normalizeTheme(String value) {
        String normalized = value.trim().toUpperCase();
        return THEME_DARK.equals(normalized) ? THEME_DARK : THEME_LIGHT;
    }

    private static UserResponse mapToUserResponse(User user) {
        return new UserResponse(
            user.getId(),
            user.getFullName(),
            user.getEmail(),
            user.getPhone(),
            user.getCity(),
            user.getThemePreference(),
            user.getDesktopMode(),
            user.getReminderEmailsEnabled(),
            user.getCreatedAt(),
            user.getAuthProvider(),
            user.getPassword() != null,
            user.getGoogleId() != null
        );
    }
}
