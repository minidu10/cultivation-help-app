package com.cultivation.app.service;

import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.auth.oauth2.ServiceAccountCredentials;

/**
 * OAuth access tokens for the FCM HTTP v1 API, from a Firebase service account.
 *
 * {@code FIREBASE_CREDENTIALS} holds either the service account JSON itself
 * or a path to it. Unset means push is switched off, not that the app fails:
 * like every other integration here, it is optional.
 */
@Component
public class FcmAccessTokens {

    private static final Logger log = LoggerFactory.getLogger(FcmAccessTokens.class);
    private static final List<String> SCOPES = List.of("https://www.googleapis.com/auth/firebase.messaging");

    private final GoogleCredentials credentials;
    private final String projectId;

    public FcmAccessTokens(@Value("${app.push.credentials:}") String credentialsSetting,
                           @Value("${app.push.project-id:}") String projectIdSetting) {
        GoogleCredentials loaded = load(credentialsSetting);
        this.credentials = loaded;
        String fromAccount = loaded instanceof ServiceAccountCredentials sa ? sa.getProjectId() : null;
        this.projectId = projectIdSetting != null && !projectIdSetting.isBlank() ? projectIdSetting.trim() : fromAccount;
    }

    public boolean isConfigured() {
        return credentials != null && projectId != null && !projectId.isBlank();
    }

    public String projectId() {
        return projectId;
    }

    /** A current access token; the library refreshes it shortly before it expires. */
    public Optional<String> accessToken() {
        if (credentials == null) {
            return Optional.empty();
        }
        try {
            credentials.refreshIfExpired();
            return Optional.ofNullable(credentials.getAccessToken()).map(t -> t.getTokenValue());
        } catch (IOException ex) {
            log.warn("Could not get an FCM access token: {}", ex.getMessage());
            return Optional.empty();
        }
    }

    private static GoogleCredentials load(String setting) {
        if (setting == null || setting.isBlank()) {
            return null;
        }
        String value = setting.trim();
        try (InputStream in = value.startsWith("{")
                ? new ByteArrayInputStream(value.getBytes(StandardCharsets.UTF_8))
                : new FileInputStream(value)) {
            return GoogleCredentials.fromStream(in).createScoped(SCOPES);
        } catch (IOException ex) {
            log.error("FIREBASE_CREDENTIALS is set but could not be read; push is off: {}", ex.getMessage());
            return null;
        }
    }
}
