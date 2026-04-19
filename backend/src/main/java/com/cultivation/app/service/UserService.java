package com.cultivation.app.service;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.cultivation.app.dto.AuthResponse;
import com.cultivation.app.dto.LoginRequest;
import com.cultivation.app.dto.RegisterRequest;
import com.cultivation.app.dto.UserResponse;
import com.cultivation.app.dto.UserUpdateRequest;
import com.cultivation.app.entity.User;
import com.cultivation.app.repository.UserRepository;
import com.cultivation.app.security.JwtUtil;

@Service
public class UserService {

    private static final String THEME_LIGHT = "LIGHT";
    private static final String THEME_DARK = "DARK";

    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;
    private final BCryptPasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.jwtUtil = jwtUtil;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }

    public AuthResponse register(RegisterRequest request) {

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered");
        }

        User user = new User();
        user.setFullName(request.getFullName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword())); // hashed!
        user.setPhone(request.getPhone());
        user.setCity(request.getCity());
        user.setThemePreference(THEME_LIGHT);
        user.setDesktopMode(false);

        userRepository.save(user);

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

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("Wrong password");
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
            user.getCreatedAt()
        );
    }
}