package com.cultivation.app.service;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.cultivation.app.dto.AuthResponse;
import com.cultivation.app.entity.User;
import com.cultivation.app.exception.ApiException;
import com.cultivation.app.repository.UserRepository;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;

/**
 * Signs a farmer in with a Google ID token from the browser.
 *
 * The token arriving from the frontend is untrusted input. GoogleIdTokenVerifier
 * checks the signature against Google's published keys and confirms the issuer,
 * audience and expiry — without that, anyone could post a hand-written JSON blob
 * naming any email address and be logged in as that user.
 */
@Service
public class GoogleAuthService {

    private static final Logger log = LoggerFactory.getLogger(GoogleAuthService.class);

    private final UserRepository userRepository;
    private final AuthTokenService authTokenService;
    private final MailService mailService;
    private final String clientId;
    private final GoogleIdTokenVerifier verifier;

    public GoogleAuthService(UserRepository userRepository,
                             AuthTokenService authTokenService,
                             MailService mailService,
                             @Value("${app.google.client-id:}") String clientId,
                             @Value("${app.google.mobile-client-ids:}") String mobileClientIds) {
        this.userRepository = userRepository;
        this.authTokenService = authTokenService;
        this.mailService = mailService;
        this.clientId = clientId;
        this.verifier = clientId.isBlank() ? null : new GoogleIdTokenVerifier.Builder(
                new NetHttpTransport(), GsonFactory.getDefaultInstance())
            .setAudience(audiences(clientId, mobileClientIds))
            .build();
    }

    /**
     * The web client id, plus any Android/iOS client ids. A token is only
     * accepted when it was minted for one of this app's own clients; a token
     * Google issued to some other app must not sign anyone in here.
     */
    private static List<String> audiences(String webClientId, String mobileClientIds) {
        List<String> audiences = new ArrayList<>();
        audiences.add(webClientId);
        Arrays.stream(mobileClientIds.split(","))
            .map(String::trim)
            .filter(id -> !id.isEmpty())
            .forEach(audiences::add);
        return audiences;
    }

    public String getClientId() {
        return clientId;
    }

    @Transactional
    public AuthResponse signIn(String idTokenString) {
        if (verifier == null) {
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE,
                "Google Sign-In is not configured on this server");
        }

        Payload payload = verify(idTokenString);

        String googleId = payload.getSubject();
        String email = payload.getEmail() == null ? null : payload.getEmail().toLowerCase();
        boolean emailVerified = Boolean.TRUE.equals(payload.getEmailVerified());
        String name = (String) payload.get("name");

        if (email == null || email.isBlank()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Google account has no email address");
        }

        // Returning user: matched on the Google subject, which never changes
        // even if they change the email on their Google account.
        User user = userRepository.findByGoogleId(googleId).orElse(null);

        if (user == null) {
            User existing = userRepository.findByEmail(email).orElse(null);
            if (existing != null) {
                // Linking an existing password account to Google is only safe
                // when Google vouches for the address. Without that check,
                // an unverified Google account could claim someone's email.
                if (!emailVerified) {
                    throw new ApiException(HttpStatus.FORBIDDEN,
                        "Your Google account email is not verified. Sign in with your password instead.");
                }
                existing.setGoogleId(googleId);
                user = userRepository.save(existing);
                log.info("Linked Google account to existing user {}", email);
            } else {
                if (!emailVerified) {
                    throw new ApiException(HttpStatus.FORBIDDEN,
                        "Your Google account email is not verified.");
                }
                user = createUser(googleId, email, name);
            }
        }

        return authTokenService.issue(user);
    }

    /**
     * Re-authentication for a Google-only account, which has no password to
     * ask for: proves the person holding the session can still sign in to the
     * Google account linked to it. Used before irreversible actions such as
     * deleting the account.
     */
    public void verifyOwnership(User user, String idTokenString) {
        if (verifier == null) {
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE,
                "Google Sign-In is not configured on this server");
        }
        Payload payload = verify(idTokenString);
        if (user.getGoogleId() == null || !user.getGoogleId().equals(payload.getSubject())) {
            throw new ApiException(HttpStatus.FORBIDDEN,
                "That Google account is not the one linked to this profile");
        }
    }

    private Payload verify(String idTokenString) {
        if (idTokenString == null || idTokenString.isBlank()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Missing Google credential");
        }
        try {
            GoogleIdToken idToken = verifier.verify(idTokenString);
            if (idToken == null) {
                throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid Google credential");
            }
            return idToken.getPayload();
        } catch (GeneralSecurityException | IOException ex) {
            log.warn("Google token verification failed: {}", ex.getMessage());
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Could not verify Google credential");
        } catch (IllegalArgumentException ex) {
            // A string that is not a well-formed JWT never reaches signature
            // checking; without this it would surface as a 500.
            log.warn("Malformed Google credential: {}", ex.getMessage());
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid Google credential");
        }
    }

    /**
     * No password is set: the account is Google-only until the farmer chooses
     * one through the password reset flow, after which both work.
     */
    private User createUser(String googleId, String email, String name) {
        User user = new User();
        user.setGoogleId(googleId);
        user.setEmail(email);
        user.setFullName(name == null || name.isBlank() ? email.split("@")[0] : name);
        user.setAuthProvider("GOOGLE");
        user.setThemePreference("LIGHT");
        user.setDesktopMode(false);
        user.setReminderEmailsEnabled(true);

        User saved = userRepository.save(user);
        // Google has already proven the address, so no verification code is
        // needed — straight to the welcome message.
        mailService.sendWelcome(saved.getEmail(), saved.getFullName());
        log.info("Created account for {} via Google", email);
        return saved;
    }
}
