package com.cultivation.app.service;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.cultivation.app.dto.AuthResponse;
import com.cultivation.app.dto.LoginRequest;
import com.cultivation.app.dto.RegisterRequest;
import com.cultivation.app.dto.UserResponse;
import com.cultivation.app.dto.UserUpdateRequest;
import com.cultivation.app.entity.EmailVerification.Purpose;
import com.cultivation.app.entity.User;
import com.cultivation.app.exception.ApiException;
import com.cultivation.app.repository.UserRepository;
import com.cultivation.app.security.JwtUtil;

@Service
public class UserService {

    private static final String THEME_LIGHT = "LIGHT";
    private static final String THEME_DARK = "DARK";

    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;
    private final VerificationService verificationService;
    private final MailService mailService;
    private final BCryptPasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository,
                       JwtUtil jwtUtil,
                       VerificationService verificationService,
                       MailService mailService) {
        this.userRepository = userRepository;
        this.jwtUtil = jwtUtil;
        this.verificationService = verificationService;
        this.mailService = mailService;
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

        String token = jwtUtil.generateToken(user.getEmail());
        return new AuthResponse(
            token,
            user.getEmail(),
            user.getFullName(),
            user.getCity(),
            user.getThemePreference(),
            user.getDesktopMode()
        );
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

        String token = jwtUtil.generateToken(user.getEmail());
        return new AuthResponse(
            token,
            user.getEmail(),
            user.getFullName(),
            user.getCity(),
            user.getThemePreference(),
            user.getDesktopMode()
        );
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
        user.setPasswordChangedAt(java.time.LocalDateTime.now());
        userRepository.save(user);
    }

    public UserResponse getMe(User currentUser) {
        User user = userRepository.findById(currentUser.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));
        return mapToUserResponse(user);
    }

    public UserResponse updateMe(User currentUser, UserUpdateRequest request) {
        User user = userRepository.findById(currentUser.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));

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
            user.getCreatedAt()
        );
    }
}