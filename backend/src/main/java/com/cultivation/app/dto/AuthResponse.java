package com.cultivation.app.dto;

public class AuthResponse {

    /** Short-lived JWT sent as "Authorization: Bearer ...". */
    private String token;

    /** Single-use token for POST /api/auth/refresh once the JWT expires. */
    private String refreshToken;

    /** Lifetime of {@link #token} in seconds, so a client can refresh ahead of time. */
    private long expiresIn;

    private String email;
    private String fullName;
    private String city;
    private String themePreference;
    private Boolean desktopMode;

    public AuthResponse(
            String token,
            String refreshToken,
            long expiresIn,
            String email,
            String fullName,
            String city,
            String themePreference,
            Boolean desktopMode) {
        this.token = token;
        this.refreshToken = refreshToken;
        this.expiresIn = expiresIn;
        this.email = email;
        this.fullName = fullName;
        this.city = city;
        this.themePreference = themePreference;
        this.desktopMode = desktopMode;
    }

    public String getToken() { return token; }
    public String getRefreshToken() { return refreshToken; }
    public long getExpiresIn() { return expiresIn; }
    public String getEmail() { return email; }
    public String getFullName() { return fullName; }
    public String getCity() { return city; }
    public String getThemePreference() { return themePreference; }
    public Boolean getDesktopMode() { return desktopMode; }
}
