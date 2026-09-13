package com.cultivation.app.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.HexFormat;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.cultivation.app.entity.EmailVerification;
import com.cultivation.app.entity.EmailVerification.Purpose;
import com.cultivation.app.exception.ApiException;
import com.cultivation.app.repository.EmailVerificationRepository;

/**
 * Issues and checks the 6-digit codes used for registration and password reset.
 *
 * A 6-digit code is only a million possibilities, so it is brute-forceable
 * unless it is short-lived, attempt-limited and single-use. All three are
 * enforced here rather than being left to callers.
 */
@Service
public class VerificationService {

    private static final Logger log = LoggerFactory.getLogger(VerificationService.class);
    private static final SecureRandom RANDOM = new SecureRandom();

    private final EmailVerificationRepository repository;
    private final MailService mailService;

    private final int codeTtlMinutes;
    private final int maxAttempts;
    private final int resendCooldownSeconds;
    private final int completionWindowMinutes;

    public VerificationService(EmailVerificationRepository repository,
                               MailService mailService,
                               @Value("${app.verification.code-ttl-minutes}") int codeTtlMinutes,
                               @Value("${app.verification.max-attempts}") int maxAttempts,
                               @Value("${app.verification.resend-cooldown-seconds}") int resendCooldownSeconds,
                               @Value("${app.verification.completion-window-minutes}") int completionWindowMinutes) {
        this.repository = repository;
        this.mailService = mailService;
        this.codeTtlMinutes = codeTtlMinutes;
        this.maxAttempts = maxAttempts;
        this.resendCooldownSeconds = resendCooldownSeconds;
        this.completionWindowMinutes = completionWindowMinutes;
    }

    /**
     * Issues a fresh code and emails it. Any previous code for the same
     * email/purpose is retired first, so only the newest one can ever work.
     */
    @Transactional
    public void issueCode(String rawEmail, Purpose purpose) {
        String email = normalize(rawEmail);

        repository.findFirstByEmailAndPurposeOrderByCreatedAtDesc(email, purpose)
            .filter(previous -> previous.getCreatedAt()
                    .isAfter(LocalDateTime.now().minusSeconds(resendCooldownSeconds)))
            .ifPresent(previous -> {
                throw new ApiException(HttpStatus.TOO_MANY_REQUESTS,
                    "Please wait " + resendCooldownSeconds + " seconds before requesting another code");
            });

        repository.consumeOutstanding(email, purpose);

        // nextInt(900000) + 100000 keeps it exactly 6 digits — no leading zeros
        // to be lost when the code is rendered or typed back in.
        String code = String.valueOf(RANDOM.nextInt(900_000) + 100_000);

        EmailVerification verification = new EmailVerification();
        verification.setEmail(email);
        verification.setCodeHash(hash(email, code));
        verification.setPurpose(purpose);
        verification.setExpiresAt(LocalDateTime.now().plusMinutes(codeTtlMinutes));
        repository.save(verification);

        if (purpose == Purpose.PASSWORD_RESET) {
            mailService.sendPasswordResetCode(email, code);
        } else {
            mailService.sendVerificationCode(email, code);
        }
        log.info("Issued {} code for {}", purpose, email);
    }

    /**
     * Checks a submitted code and marks the verification confirmed.
     * Every wrong guess is counted; once the limit is hit the code is dead
     * and a new one has to be requested.
     *
     * noRollbackFor is essential: ApiException extends RuntimeException, so the
     * default rollback would undo the incremented attempt counter on every
     * wrong guess and the limit would never be reached.
     */
    @Transactional(noRollbackFor = ApiException.class)
    public void confirmCode(String rawEmail, String code, Purpose purpose) {
        String email = normalize(rawEmail);

        EmailVerification verification = repository
            .findFirstByEmailAndPurposeOrderByCreatedAtDesc(email, purpose)
            .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST,
                "No code was requested for this email"));

        if (verification.isConsumed()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "This code has already been used");
        }
        if (verification.isExpired()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "This code has expired. Request a new one.");
        }
        if (verification.getAttempts() >= maxAttempts) {
            throw new ApiException(HttpStatus.TOO_MANY_REQUESTS,
                "Too many incorrect attempts. Request a new code.");
        }

        if (!constantTimeEquals(verification.getCodeHash(), hash(email, code == null ? "" : code.trim()))) {
            verification.setAttempts(verification.getAttempts() + 1);
            repository.save(verification);
            int remaining = maxAttempts - verification.getAttempts();
            throw new ApiException(HttpStatus.BAD_REQUEST, remaining > 0
                ? "Incorrect code. " + remaining + " attempt(s) remaining."
                : "Incorrect code. Request a new one.");
        }

        verification.setVerifiedAt(LocalDateTime.now());
        repository.save(verification);
        log.info("Confirmed {} code for {}", purpose, email);
    }

    /**
     * Spends the verification so it cannot be reused for a second account.
     * Called by register() and resetPassword() — the frontend enforcing the
     * step order is not enough, since anyone can POST here directly.
     */
    @Transactional
    public void consume(String rawEmail, Purpose purpose) {
        EmailVerification verification = findUsable(rawEmail, purpose)
            .orElseThrow(() -> new ApiException(HttpStatus.FORBIDDEN,
                "Email not verified. Request a code and confirm it first."));
        verification.setConsumedAt(LocalDateTime.now());
        repository.save(verification);
    }

    private Optional<EmailVerification> findUsable(String rawEmail, Purpose purpose) {
        return repository.findUsableVerification(
            normalize(rawEmail),
            purpose,
            LocalDateTime.now().minusMinutes(completionWindowMinutes));
    }

    private static String normalize(String email) {
        if (email == null || email.isBlank()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Email is required");
        }
        return email.trim().toLowerCase();
    }

    /**
     * The code is never stored. Hashing it with the email as a prefix means a
     * leaked table cannot be reversed with a plain rainbow table of the one
     * million possible codes.
     */
    private static String hash(String email, String code) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] out = digest.digest((email + ":" + code).getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(out);
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 unavailable", ex);
        }
    }

    private static boolean constantTimeEquals(String a, String b) {
        return MessageDigest.isEqual(
            a.getBytes(StandardCharsets.UTF_8),
            b.getBytes(StandardCharsets.UTF_8));
    }
}
