package com.cultivation.app.dto;

/**
 * Public auth configuration the login and register pages need before a user
 * has signed in. Served from the backend rather than baked into the frontend
 * bundle, so the client id is one entry in .env and changing it needs no rebuild.
 */
public class AuthConfigResponse {

    private final String googleClientId;
    private final boolean googleEnabled;

    public AuthConfigResponse(String googleClientId) {
        this.googleClientId = googleClientId == null ? "" : googleClientId;
        this.googleEnabled = !this.googleClientId.isBlank();
    }

    public String getGoogleClientId() { return googleClientId; }
    public boolean isGoogleEnabled() { return googleEnabled; }
}
