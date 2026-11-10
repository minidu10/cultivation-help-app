package com.cultivation.app.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.HexFormat;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.cultivation.app.dto.AuthResponse;
import com.cultivation.app.entity.RefreshToken;
import com.cultivation.app.entity.User;
import com.cultivation.app.exception.ApiException;
import com.cultivation.app.repository.RefreshTokenRepository;
import com.cultivation.app.security.JwtUtil;

/**
 * Issues the access/refresh token pair and rotates it.
 *
 * Access tokens are short-lived JWTs checked without a database hit. Refresh
 * tokens are random, stored only as a hash, and single-use: each refresh
 * spends the presented token and returns its successor. If a spent token is
 * ever presented again, someone has a copy, and the entire family is revoked.
 */
@Service
public class AuthTokenService {

    private static final Logger log = LoggerFactory.getLogger(AuthTokenService.class);
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String SESSION_ENDED = "Your session has ended. Please sign in again.";

    private final JwtUtil jwtUtil;
    private final RefreshTokenRepository refreshTokenRepository;
    private final Duration refreshTtl;

    public AuthTokenService(JwtUtil jwtUtil,
                            RefreshTokenRepository refreshTokenRepository,
                            @Value("${app.jwt.refresh-days:30}") long refreshDays) {
        this.jwtUtil = jwtUtil;
        this.refreshTokenRepository = refreshTokenRepository;
        this.refreshTtl = Duration.ofDays(refreshDays);
    }

    /** A new sign-in: starts a fresh token family. */
    @Transactional
    public AuthResponse issue(User user) {
        return respond(user, mint(user, UUID.randomUUID()));
    }

    /**
     * Exchanges a refresh token for a new pair.
     *
     * noRollbackFor matters for the reuse case: the family revocation must
     * commit even though the request then fails. With the default rollback the
     * thief's copy would be rejected once and the stolen chain would live on.
     */
    @Transactional(noRollbackFor = ApiException.class)
    public AuthResponse refresh(String rawToken) {
        RefreshToken token = refreshTokenRepository.findByTokenHashForUpdate(hash(rawToken))
            .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, SESSION_ENDED));

        if (token.getRevokedAt() != null || token.isExpired()) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, SESSION_ENDED);
        }

        if (token.getUsedAt() != null) {
            refreshTokenRepository.revokeFamily(token.getFamilyId(), LocalDateTime.now());
            log.warn("Refresh token reuse detected for user {}; family {} revoked",
                     token.getUser().getId(), token.getFamilyId());
            throw new ApiException(HttpStatus.UNAUTHORIZED, SESSION_ENDED);
        }

        token.setUsedAt(LocalDateTime.now());
        User user = token.getUser();
        return respond(user, mint(user, token.getFamilyId()));
    }

    /** Sign out on this device. Unknown or already revoked tokens are ignored. */
    @Transactional
    public void revoke(String rawToken) {
        if (rawToken == null || rawToken.isBlank()) {
            return;
        }
        refreshTokenRepository.findByTokenHash(hash(rawToken))
            .ifPresent(token -> refreshTokenRepository.revokeFamily(token.getFamilyId(), LocalDateTime.now()));
    }

    /** Sign out everywhere: password reset, password change. */
    @Transactional
    public void revokeAll(User user) {
        refreshTokenRepository.revokeAllForUser(user.getId(), LocalDateTime.now());
    }

    /** Spent and expired rows are only useful briefly, for reuse detection. */
    @Scheduled(cron = "${app.jwt.refresh-cleanup-cron:0 30 3 * * *}")
    @Transactional
    public void purgeExpired() {
        int removed = refreshTokenRepository.deleteExpiredBefore(LocalDateTime.now().minusDays(1));
        if (removed > 0) {
            log.info("Purged {} expired refresh token(s)", removed);
        }
    }

    private String mint(User user, UUID familyId) {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String raw = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        refreshTokenRepository.save(
            new RefreshToken(user, hash(raw), familyId, LocalDateTime.now().plus(refreshTtl)));
        return raw;
    }

    private AuthResponse respond(User user, String refreshToken) {
        return new AuthResponse(
            jwtUtil.generateToken(user.getEmail()),
            refreshToken,
            jwtUtil.getExpirationSeconds(),
            user.getEmail(),
            user.getFullName(),
            user.getCity(),
            user.getThemePreference(),
            user.getDesktopMode());
    }

    /** The token is 256 random bits, so an unsalted hash cannot be brute-forced. */
    private static String hash(String rawToken) {
        if (rawToken == null || rawToken.isBlank()) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, SESSION_ENDED);
        }
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                .digest(rawToken.trim().getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 unavailable", ex);
        }
    }
}
