package com.cultivation.app.dto;

public class AuthResponse {

    private String token;
    private String email;
    private String fullName;
    private String city;
    private String themePreference;
    private Boolean desktopMode;

    public AuthResponse(
            String token,
            String email,
            String fullName,
            String city,
            String themePreference,
            Boolean desktopMode) {
        this.token = token;
        this.email = email;
        this.fullName = fullName;
        this.city = city;
        this.themePreference = themePreference;
        this.desktopMode = desktopMode;
    }

    public String getToken() { return token; }
    public String getEmail() { return email; }
    public String getFullName() { return fullName; }
    public String getCity() { return city; }
    public String getThemePreference() { return themePreference; }
    public Boolean getDesktopMode() { return desktopMode; }
}