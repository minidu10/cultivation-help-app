package com.cultivation.app.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String fullName;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    /** Null for accounts created through Google that never set a password. */
    @Column
    private String password;

    @Column(length = 20)
    private String phone;

    @Column(length = 100)
    private String city;

    @Column(name = "theme_preference", nullable = false, length = 20)
    private String themePreference = "LIGHT";

    @Column(name = "desktop_mode", nullable = false)
    private Boolean desktopMode = false;

    /** LOCAL or GOOGLE - how the account was first created. */
    @Column(name = "auth_provider", nullable = false, length = 20)
    private String authProvider = "LOCAL";

    /** Google's stable subject claim. Null for email/password accounts. */
    @Column(name = "google_id", length = 64)
    private String googleId;

    /** Opt-out for the daily reminder digest, controlled from Settings. */
    @Column(name = "reminder_emails_enabled", nullable = false)
    private Boolean reminderEmailsEnabled = true;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }

    // --- Getters and Setters ---

    public Long getId() { return id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getThemePreference() { return themePreference; }
    public void setThemePreference(String themePreference) { this.themePreference = themePreference; }

    public Boolean getDesktopMode() { return desktopMode; }
    public void setDesktopMode(Boolean desktopMode) { this.desktopMode = desktopMode; }

    public String getAuthProvider() { return authProvider; }
    public void setAuthProvider(String authProvider) { this.authProvider = authProvider; }

    public String getGoogleId() { return googleId; }
    public void setGoogleId(String googleId) { this.googleId = googleId; }

    public Boolean getReminderEmailsEnabled() { return reminderEmailsEnabled; }
    public void setReminderEmailsEnabled(Boolean reminderEmailsEnabled) { this.reminderEmailsEnabled = reminderEmailsEnabled; }

    public LocalDateTime getCreatedAt() { return createdAt; }
}