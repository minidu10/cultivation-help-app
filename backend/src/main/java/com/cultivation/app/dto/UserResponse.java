package com.cultivation.app.dto;

import java.time.LocalDateTime;

public class UserResponse {

    private Long id;
    private String fullName;
    private String email;
    private String phone;
    private String city;
    private String themePreference;
    private Boolean desktopMode;
    private LocalDateTime createdAt;

    // Constructor
    public UserResponse(Long id, String fullName, String email,
                        String phone,
                        String city,
                        String themePreference,
                        Boolean desktopMode,
                        LocalDateTime createdAt) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.city = city;
        this.themePreference = themePreference;
        this.desktopMode = desktopMode;
        this.createdAt = createdAt;
    }

    // Getters
    public Long getId() { return id; }
    public String getFullName() { return fullName; }
    public String getEmail() { return email; }
    public String getPhone() { return phone; }
    public String getCity() { return city; }
    public String getThemePreference() { return themePreference; }
    public Boolean getDesktopMode() { return desktopMode; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}