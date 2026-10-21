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
    private Boolean reminderEmailsEnabled;
    private LocalDateTime createdAt;

    /** LOCAL or GOOGLE: how the account was first created. */
    private String authProvider;

    /**
     * Whether a password is set. A Google-only account has none, so a client
     * asks it to confirm with Google instead before changing or deleting.
     */
    private boolean hasPassword;

    /** Whether a Google account is linked, so Google can be used to confirm. */
    private boolean googleLinked;

    // Constructor
    public UserResponse(Long id, String fullName, String email,
                        String phone,
                        String city,
                        String themePreference,
                        Boolean desktopMode,
                        Boolean reminderEmailsEnabled,
                        LocalDateTime createdAt,
                        String authProvider,
                        boolean hasPassword,
                        boolean googleLinked) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.city = city;
        this.themePreference = themePreference;
        this.desktopMode = desktopMode;
        this.reminderEmailsEnabled = reminderEmailsEnabled;
        this.createdAt = createdAt;
        this.authProvider = authProvider;
        this.hasPassword = hasPassword;
        this.googleLinked = googleLinked;
    }

    // Getters
    public Long getId() { return id; }
    public String getFullName() { return fullName; }
    public String getEmail() { return email; }
    public String getPhone() { return phone; }
    public String getCity() { return city; }
    public String getThemePreference() { return themePreference; }
    public Boolean getDesktopMode() { return desktopMode; }
    public Boolean getReminderEmailsEnabled() { return reminderEmailsEnabled; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public String getAuthProvider() { return authProvider; }
    public boolean isHasPassword() { return hasPassword; }
    public boolean isGoogleLinked() { return googleLinked; }
}
